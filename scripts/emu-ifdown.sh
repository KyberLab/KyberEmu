#!/bin/bash
#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#

set -ue
switch='nat0'

sudo /usr/sbin/ip link set dev $1 down
sudo /usr/sbin/ip link set dev $1 nomaster

