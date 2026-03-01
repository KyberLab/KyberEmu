#!/bin/bash
#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#
# Design Description:
# This script is used to manage network configurations for KyberVirt-AArch64,
# including NAT network, bridge network, and DHCP service.
# Main functional modules:
# 1. NAT network management (start/stop)
# 2. Network connectivity testing (NAT/bridge)
# 3. DHCP server management (start/stop)
#
# Design Principles:
# - Modular design: Each function is encapsulated as an independent function
# - Configuration flexibility: Supports command line parameters to customize network configuration
# - Error handling: Provides clear error messages and status feedback
# - Code reuse: Extracts common functions as separate functions
#
# Usage:
# 1. Start NAT network: sudo ./virt-net.sh start
# 2. Stop NAT network: sudo ./virt-net.sh stop
# 3. Test NAT network: sudo ./virt-net.sh test-nat
# 4. Test bridge network: sudo ./virt-net.sh test-br
# 5. Start DHCP server: sudo ./virt-net.sh start-dhcp
# 6. Stop DHCP server: sudo ./virt-net.sh stop-dhcp
# 7. View help information: ./virt-net.sh --help
#
# Notes:
# - This script requires root privileges to execute
# - Some commands (such as iptables, dnsmasq) need to be installed in the system
# - Network configuration may affect system network, please ensure you understand the operations before use


# Default parameters
NETPRE=192.168.66
SUBNET=${NETPRE}.0
NETGW=${NETPRE}.99
NETBEG=${NETPRE}.128
NETEND=${NETPRE}.192
NETBR=nat0

TESTIP=114.114.114.114
BRNAME=br0
TESTVETH=tve
TESTADDR=95
TESTNS=test-ns


# Function to display usage
usage() {
    echo "Usage: $0 [options] <start|stop|test-nat|test-br|start-dhcp|stop-dhcp>"
    echo ""
    echo "Options:"
    echo "  --netpre <value>    Network prefix (default: 192.168.66)"
    echo "  --subnet <value>    Subnet (default: <netpre>.0)"
    echo "  --netgw <value>     Network gateway (default: <netpre>.99)"
    echo "  --netbeg <value>    DHCP range start (default: <netpre>.128)"
    echo "  --netend <value>    DHCP range end (default: <netpre>.192)"
    echo "  --netbr <value>     Network bridge name (default: nat0)"
    echo "  --testip <value>    Test IP address for ping test (default: 114.114.114.114)"
    echo "  --brname <value>    Bridge name for test-br (default: br0)"
    echo "  --testveth <value>  Test veth name prefix (default: tve)"
    echo "  --testaddr <value>  Test address suffix (default: 95)"
    echo "  -h, --help          Display this help message"
    echo ""
    echo "Commands:"
    echo "  start               Start NAT network"
    echo "  stop                Stop NAT network"
    echo "  test-nat            Test NAT network connectivity"
    echo "  test-br             Test bridge network connectivity"
    echo "  start-dhcp          Start DHCP server on existing bridge"
    echo "  stop-dhcp           Stop DHCP server"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --netpre)
                NETPRE=$2
                SUBNET=${NETPRE}.0
                NETGW=${NETPRE}.99
                NETBEG=${NETPRE}.128
                NETEND=${NETPRE}.192
                shift 2
                ;;
            --subnet)
                SUBNET=$2
                shift 2
                ;;
            --netgw)
                NETGW=$2
                shift 2
                ;;
            --netbeg)
                NETBEG=$2
                shift 2
                ;;
            --netend)
                NETEND=$2
                shift 2
                ;;
            --netbr)
                NETBR=$2
                shift 2
                ;;
            --testip)
                TESTIP=$2
                shift 2
                ;;
            --brname)
                BRNAME=$2
                shift 2
                ;;
            --testveth)
                TESTVETH=$2
                shift 2
                ;;
            --testaddr)
                TESTADDR=$2
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            start|stop|test-nat|test-br|start-dhcp|stop-dhcp)
                COMMAND=$1
                shift
                ;;
            *)
                echo "Error: Unknown argument $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Function to start dnsmasq server
start_dnsmasq() {
    local bridge=$1
    local gateway=$2
    local dhcp_start=$3
    local dhcp_end=$4
    
    dnsmasq --strict-order \
        --except-interface=lo \
        --interface=${bridge} \
        --listen-address=${gateway} \
        --bind-interfaces \
        --dhcp-range=${dhcp_start},${dhcp_end} \
        --conf-file="" \
        --pid-file=/var/run/${bridge}-dhcp.pid \
        --dhcp-leasefile=/var/run/${bridge}-dhcp.leases \
        --dhcp-no-override
}

# Function to stop dnsmasq server
stop_dnsmasq() {
    local bridge=$1
    
    if [ -f /var/run/${bridge}-dhcp.pid ]; then
        kill -9 `cat /var/run/${bridge}-dhcp.pid`
        return 0
    fi
    return 1
}

# Function to create veth pair and test connectivity
create_veth_and_test() {
    local veth_prefix=$1
    local bridge=$2
    local ip_address=$3
    local gateway=$4
    local test_ip=$5
    
    # Create veth pair
    ip link add ${veth_prefix}-out type veth peer name ${veth_prefix}-in
    ip link set dev ${veth_prefix}-out master ${bridge}
    ip link set dev ${veth_prefix}-out up
    
    # Configure namespace
    ip link set ${veth_prefix}-in netns ${TESTNS}
    ip netns exec ${TESTNS} ip link set dev ${veth_prefix}-in up
    ip netns exec ${TESTNS} ip addr add ${ip_address} dev ${veth_prefix}-in
    ip netns exec ${TESTNS} ifconfig
    
    # Set up routing
    ip netns exec ${TESTNS} route add default gw ${gateway}
    ip netns exec ${TESTNS} route -n
    
    # Test connectivity
    echo "Pinging gateway ${gateway}..."
    ip netns exec ${TESTNS} ping -c 4 ${gateway}
    
    echo "Pinging test IP ${test_ip}..."
    ip netns exec ${TESTNS} ping -c 4 ${test_ip}
    
    # Cleanup
    ip link delete ${veth_prefix}-out
}

# Function to start NAT network
start_nat() {
    echo "Starting NAT network..."
    
    # Create bridge
    ip link add name ${NETBR} type bridge
    ip link set dev ${NETBR} up
    ip addr add ${NETGW}/24 dev ${NETBR}
    
    # Set up iptables
    iptables -t nat -A POSTROUTING -s ${SUBNET}/24 ! -d ${SUBNET}/24 -j MASQUERADE
    
    # Start dnsmasq
    start_dnsmasq ${NETBR} ${NETGW} ${NETBEG} ${NETEND}
    
    echo "NAT network started successfully"
}

# Function to stop NAT network
stop_nat() {
    echo "Stopping NAT network..."
    
    # Kill dnsmasq, remove iptables rule, and delete bridge
    stop_dnsmasq ${NETBR}
    iptables -t nat -D POSTROUTING -s ${SUBNET}/24 ! -d ${SUBNET}/24 -j MASQUERADE 2>/dev/null
    ip link delete ${NETBR} 2>/dev/null
    
    echo "NAT network stopped successfully"
}

# Function to test NAT network
test_nat() {
    echo "Testing NAT network..."
    
    TESTVE=test-ve
    
    # Create network namespace
    ip netns add ${TESTNS}
    
    # Create veth pair and test connectivity
    create_veth_and_test ${TESTVE} ${NETBR} ${NETPRE}.95/24 ${NETGW} ${TESTIP}
    
    # Cleanup
    ip netns delete ${TESTNS}
    
    echo "NAT network test completed"
}

# Function to test bridge network
test_br() {
    echo "Testing bridge network..."
    
    # Get subnet from bridge
    BR_SUBNET=$(ip addr show ${BRNAME} | tr "/" " " |awk '$1=="inet" {print $2}' | awk -F. '{print $1 "." $2 "." $3}')
    GATEWAY=${BR_SUBNET}.2
    
    # Create network namespace
    ip netns add ${TESTNS}
    
    # Create veth pair and test connectivity
    create_veth_and_test ${TESTVETH} ${BRNAME} ${BR_SUBNET}.${TESTADDR}/24 ${GATEWAY} ${TESTIP}
    
    # Cleanup
    ip netns delete ${TESTNS}
    
    echo "Bridge network test completed"
}

# Function to start DHCP server
start_dhcp() {
    echo "Starting DHCP server..."
    
    # Set up iptables rules
    iptables -t filter -I INPUT -i ${NETBR} -j ACCEPT
    iptables -t filter -I OUTPUT -o ${NETBR} -j ACCEPT
    
    # Start dnsmasq
    start_dnsmasq ${NETBR} ${NETGW} ${NETBEG} ${NETEND}
    
    echo "DHCP server started successfully on bridge ${NETBR}"
}

# Function to stop DHCP server
stop_dhcp() {
    echo "Stopping DHCP server..."
    
    # Kill dnsmasq process
    if stop_dnsmasq ${NETBR}; then
        echo "DHCP server process stopped"
    else
        echo "DHCP server pid file not found, skipping process stop"
    fi
    
    # Remove iptables rules
    echo "Removing iptables rules..."
    iptables -t filter -D INPUT -i ${NETBR} -j ACCEPT 2>/dev/null || echo "INPUT rule not found or already removed"
    iptables -t filter -D OUTPUT -o ${NETBR} -j ACCEPT 2>/dev/null || echo "OUTPUT rule not found or already removed"
    
    echo "DHCP server stop completed"
}

# Main function
main() {
    parse_args "$@"
    
    if [ -z "$COMMAND" ]; then
        echo "Error: Command required"
        usage
        exit 1
    fi
    
    # Print configuration information before executing command
    echo "======================================"
    echo "Executing command: $COMMAND"
    echo "======================================"
    echo "Network configuration parameters:"
    echo "  NETPRE: $NETPRE"
    echo "  SUBNET: $SUBNET"
    echo "  NETGW: $NETGW"
    echo "  NETBEG: $NETBEG"
    echo "  NETEND: $NETEND"
    echo "  NETBR: $NETBR"
    echo "  BRNAME: $BRNAME"
    echo "  TESTIP: $TESTIP"
    echo "  TESTVETH: $TESTVETH"
    echo "  TESTADDR: $TESTADDR"
    
    echo ""
    echo "Bridge status:"
    ip link show type bridge 2>/dev/null || echo "  No bridges found"
    
    echo ""
    echo "iptables NAT rules:"
    iptables -t nat -L POSTROUTING -n 2>/dev/null || echo "  Failed to show iptables rules"
    
    echo ""
    echo "iptables filter rules for ${NETBR}:"
    iptables -t filter -L INPUT -n | grep ${NETBR} 2>/dev/null || echo "  No filter rules found for ${NETBR}"
    iptables -t filter -L OUTPUT -n | grep ${NETBR} 2>/dev/null || echo "  No filter rules found for ${NETBR}"
    
    echo ""
    echo "System network interfaces:"
    ip addr show 2>/dev/null | head -30
    echo "======================================"
    echo ""
    
    case $COMMAND in
        start)
            start_nat
            ;;
        stop)
            stop_nat
            ;;
        test-nat)
            test_nat
            ;;
        test-br)
            test_br
            ;;
        start-dhcp)
            start_dhcp
            ;;
        stop-dhcp)
            stop_dhcp
            ;;
        *)
            echo "Error: Unknown command $COMMAND"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"