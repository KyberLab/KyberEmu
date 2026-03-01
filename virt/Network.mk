#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#


.PHONY : network_start network_stop network_test



network_start : 
ifeq ($(shell ip link show $(NETWORK_NAME) > /dev/null 2>&1; $(ECHO) $$?),0)
else
	$(Q)sudo ip link add name $(NETWORK_NAME) type bridge
	$(Q)sudo ip link set dev $(NETWORK_NAME) up
	$(Q)sudo ip addr add $(NETWORK_GATEWAY)/24 dev $(NETWORK_NAME)
	$(Q)sudo iptables -t nat -A POSTROUTING -s $(NETWORK_SUBNET)/24 ! -d $(NETWORK_SUBNET)/24 -j MASQUERADE
	$(Q)sudo sysctl -qw net.ipv4.ip_forward=1
	$(Q)sudo dnsmasq --strict-order \
		--except-interface=lo \
		--interface=$(NETWORK_NAME) \
		--listen-address=$(NETWORK_GATEWAY) \
		--bind-interfaces \
		--dhcp-range=$(NETWORK_BEGIN),$(NETWORK_END) \
		--conf-file="" \
		--pid-file=/var/run/$(NETWORK_NAME)-dhcp.pid \
		--dhcp-leasefile=/var/run/$(NETWORK_NAME)-dhcp.leases \
		--dhcp-no-override
endif
	$(Q)$(call xprint_title,	"Virtual Network")
	$(Q)$(call xprint_value,	"Name",				$(NETWORK_NAME))
	$(Q)$(call xprint_value,	"Subnet",			$(NETWORK_SUBNET))
	$(Q)$(call xprint_value,	"Begin",			$(NETWORK_BEGIN))
	$(Q)$(call xprint_value,	"End",				$(NETWORK_END))
	$(Q)$(call xprint_value,	"Gateway",			$(NETWORK_GATEWAY))



network_stop : 
	$(Q)-sudo kill -9 `cat /var/run/$(NETWORK_NAME)-dhcp.pid`
	$(Q)-sudo iptables -t nat -D POSTROUTING -s $(NETWORK_SUBNET)/24 ! -d $(NETWORK_SUBNET)/24 -j MASQUERADE
	$(Q)-sudo ip link delete $(NETWORK_NAME)



network_test : 
	$(Q)-sudo ip link delete $(NETWORK_VETH)-out > /dev/null 2>&1 | exit 0
	$(Q)-sudo ip netns delete $(NETWORK_NAMESPACE) > /dev/null 2>&1 | exit 0
	$(Q)sudo ip netns add $(NETWORK_NAMESPACE)
	$(Q)sudo ip link add $(NETWORK_VETH)-out type veth peer name $(NETWORK_VETH)-in
	$(Q)sudo ip link set dev $(NETWORK_VETH)-out master $(NETWORK_NAME)
	$(Q)sudo ip link set dev $(NETWORK_VETH)-out up
	$(Q)sudo ip link set $(NETWORK_VETH)-in netns $(NETWORK_NAMESPACE)
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) ip link set dev $(NETWORK_VETH)-in up
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) ip addr add $(NETWORK_PREFIX).95/24 dev $(NETWORK_VETH)-in
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) ifconfig
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) route add default gw $(NETWORK_GATEWAY)
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) route -n
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) ping -c 4 $(NETWORK_GATEWAY)
	$(Q)sudo ip netns exec $(NETWORK_NAMESPACE) ping -c 4 $(NETWORK_TESTIP)
	$(Q)sudo ip link delete $(NETWORK_VETH)-out
	$(Q)sudo ip netns delete $(NETWORK_NAMESPACE)



