#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




ifneq ($(QEMU_STORAGE_TYPE),none)

QEMU_RUN_DEPENDS			+= $(QEMU_DISK_FILES)


ifeq ($(QEMU_STORAGE_TYPE),mmio)

QEMU_STORAGE_DEVICE			:= virtio-blk-device

define qemu_virtio_blk_bus
,bus=virtio-mmio-bus.$(1)
endef

QEMU_STORAGE_DISK1_BUS_ADDR	?= 5
QEMU_STORAGE_DISK2_BUS_ADDR	?= 6
QEMU_STORAGE_DISK3_BUS_ADDR	?= 7


else

ifeq ($(QEMU_STORAGE_TYPE),pcie)

QEMU_STORAGE_DEVICE			:= virtio-blk

define qemu_virtio_blk_bus
,bus=pcie.0,addr=$(1)
endef

QEMU_STORAGE_DISK1_BUS_ADDR	?= 0x11
QEMU_STORAGE_DISK2_BUS_ADDR	?= 0x12
QEMU_STORAGE_DISK3_BUS_ADDR	?= 0x13


else

ifeq ($(QEMU_STORAGE_TYPE),ide)

QEMU_STORAGE_DEVICE			:= ide-hd

else

ifeq ($(QEMU_STORAGE_TYPE),scsi)

QEMU_STORAGE_DEVICE			:= scsi-hd


else

$(error invalid storage type "$(QEMU_STORAGE_TYPE)")


endif # ($(QEMU_STORAGE_TYPE),scsi)
endif # ($(QEMU_STORAGE_TYPE),ide)
endif # ($(QEMU_STORAGE_TYPE),pcie)
endif # ($(QEMU_STORAGE_TYPE),mmio)


QEMU_RUN_ARGS		+= \
	-device $(QEMU_STORAGE_DEVICE),drive=block1$(call qemu_virtio_blk_bus,$(QEMU_STORAGE_DISK1_BUS_ADDR)) \
	-drive file=$(QEMU_DISK1_FILE),format=qcow2,id=block1,if=none \
	-device $(QEMU_STORAGE_DEVICE),drive=block2$(call qemu_virtio_blk_bus,$(QEMU_STORAGE_DISK2_BUS_ADDR)) \
	-drive file=$(QEMU_DISK2_FILE),format=qcow2,id=block2,if=none \
	-device $(QEMU_STORAGE_DEVICE),drive=block3$(call qemu_virtio_blk_bus,$(QEMU_STORAGE_DISK3_BUS_ADDR)) \
	-drive file=$(QEMU_DISK3_FILE),format=qcow2,id=block3,if=none

endif # ($(QEMU_STORAGE_TYPE),none)


ifneq ($(QEMU_SHARE_ENABLE),)

QEMU_RUN_ARGS		+= \
	-fsdev local,id=fsdev0,path=${QEMU_SHARE_PATH},security_model=none \
	-device virtio-9p,fsdev=fsdev0,mount_tag=host

endif

