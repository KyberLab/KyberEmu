#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




QEMU_TAP_UP		:= $(EMU_ROOT_PATH)/scripts/emu-ifup.sh
QEMU_TAP_DOWN	:= $(EMU_ROOT_PATH)/scripts/emu-ifdown.sh


ifneq ($(QEMU_NETWORK_TYPE),none)

QEMU_RUN_DEPENDS	+= network_start

ifeq ($(QEMU_NETWORK_TYPE),mmio)

QEMU_NETWORK_DEVICE	:= virtio-net-device

QEMU_RUN_ARGS		+= \
	-device $(QEMU_NETWORK_DEVICE),netdev=tap0,mac=$(QEMU_TAP_MAC),bus=virtio-mmio-bus.2

else

ifeq ($(QEMU_NETWORK_TYPE),pcie)

QEMU_NETWORK_DEVICE	:= virtio-net-pci,vectors=32,mq=on

QEMU_RUN_ARGS		+= \
	-device $(QEMU_NETWORK_DEVICE),netdev=tap0,mac=$(QEMU_TAP_MAC) \

else

$(error invalid network type "$(QEMU_NETWORK_TYPE)")

endif # ($(QEMU_NETWORK_TYPE),pcie)
endif # ($(QEMU_NETWORK_TYPE),mmio)



QEMU_RUN_ARGS		+= \
	-netdev tap,ifname=$(QEMU_TAP_NAME),id=tap0,script=$(QEMU_TAP_UP),downscript=$(QEMU_TAP_DOWN)


ifneq ($(QEMU_PRE_RUN),)
QEMU_PRE_RUN		+= && 
endif

QEMU_PRE_RUN		+= \
	sudo /usr/sbin/ip tuntap delete dev $(QEMU_TAP_NAME) mode tap > /dev/null 2>&1; \
	sudo /usr/sbin/ip tuntap add dev $(QEMU_TAP_NAME) mode tap user $(QEMU_TAP_USER)


ifneq ($(QEMU_POST_RUN),)
QEMU_POST_RUN		+= && 
endif


QEMU_POST_RUN		+= \
	sudo /usr/sbin/ip tuntap delete dev $(QEMU_TAP_NAME) mode tap


endif # ($(QEMU_NETWORK_TYPE),none)

