#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




QEMU_IMAGE_PATH				:= $(OUTPUT_ROOT_PATH)


QEMU_DISK_PARTS				:= \
	-n 1:0:+512M -c 1:"boot" -t 1:ef00 \
	-n 2:0:+10G -c 2:"$(patsubst $(QEMU_IMAGE_PATH)/%.$(QEMU_DISK_FORMAT),%,$<)" -t 2:8300

QEMU_DISK1_FILE				:= $(QEMU_IMAGE_PATH)/$(QEMU_DISK1_NAME).$(QEMU_DISK_FORMAT)
QEMU_DISK2_FILE				:= $(QEMU_IMAGE_PATH)/$(QEMU_DISK2_NAME).$(QEMU_DISK_FORMAT)
QEMU_DISK3_FILE				:= $(QEMU_IMAGE_PATH)/$(QEMU_DISK3_NAME).$(QEMU_DISK_FORMAT)

QEMU_DISK_FILES				:= $(QEMU_DISK1_FILE) $(QEMU_DISK2_FILE) $(QEMU_DISK3_FILE)
QEMU_DISK_BASES				:= $(patsubst $(QEMU_IMAGE_PATH)/%.$(QEMU_DISK_FORMAT),$(QEMU_IMAGE_PATH)/%_base.$(QEMU_DISK_FORMAT),$(QEMU_DISK_FILES))


qemu_nbd_load : 
	$(Q)-sudo modprobe nbd max_part=8 > /dev/null 2>&1; exit 0
	$(Q)-sudo mknod $(QEMU_DISK_NBD_PATH) b 43 0 > /dev/null 2>&1; exit 0


qemu_nbd_mount : 
	$(Q)sudo bash -c "export PATH=$${PATH}; $(QEMU_NBD_BIN) --connect=$(QEMU_DISK_NBD_PATH) $(QEMU_DISK_BASE_FILE)"


qemu_nbd_umount : 
	$(Q)sudo bash -c "export PATH=$${PATH}; $(QEMU_NBD_BIN) --disconnect $(QEMU_DISK_NBD_PATH)"


qemu_disk_create : $(QEMU_IMAGE_PATH)
	$(Q)$(QEMU_IMAGE_BIN) create -f $(QEMU_DISK_FORMAT) $(QEMU_DISK_BASE_FILE) $(QEMU_DISK_SIZE)
	$(Q)$(QEMU_IMAGE_BIN) info $(QEMU_DISK_BASE_FILE)


qemu_disk_part : $(QEMU_DISK_NBD_PATH)
	$(Q)sudo sgdisk $< --zap-all --clear --mbrtogpt
	$(Q)sudo sgdisk $< $(QEMU_DISK_PARTS)
	$(Q)sudo sgdisk $< -p


qemu_disk_format : $(QEMU_DISK_NBD_PATH)
	$(Q)-lsblk | tr -d "├─" | awk '$$1~"$(QEMU_DISK_NBD_NAME)p" {print "sudo mknod /dev/" $$1 " b " $$2}' | tr : " " | xargs -i bash -c {}
	$(Q)sudo mkfs.vfat -F32 $<p1
	$(Q)sudo mkfs.ext4 $<p2
	$(Q)sudo sgdisk $< -p
	$(Q)-lsblk | tr -d "├─" | awk '$$1~"$(QEMU_DISK_NBD_NAME)p" {print "sudo rm -fv /dev/" $$1}' | tr : " " | xargs -i bash -c {}


$(QEMU_DISK_BASES) : 
	$(Q)$(call xprint_title,	"Create Base Image")
	$(Q)$(call xprint_value,	"Image Path",		$@)
	$(Q)$(MAKE) qemu_nbd_load
	$(Q)-$(MAKE) qemu_nbd_umount
	$(Q)$(MAKE) qemu_disk_create QEMU_DISK_BASE_FILE=$@
	$(Q)$(MAKE) qemu_nbd_mount QEMU_DISK_BASE_FILE=$@
	$(Q)$(MAKE) qemu_disk_part
	$(Q)$(MAKE) qemu_disk_format
	$(Q)$(MAKE) qemu_nbd_umount


$(QEMU_DISK_FILES) : $(QEMU_IMAGE_PATH)/%.$(QEMU_DISK_FORMAT) : $(QEMU_IMAGE_PATH)/%_base.$(QEMU_DISK_FORMAT)
	$(Q)$(call xprint_title,	"Create Overlay Image")
	$(Q)$(call xprint_value,	"Image Path",		$@)
	$(Q)$(QEMU_IMAGE_BIN) create -f $(QEMU_DISK_FORMAT) -b $(notdir $<) -o backing_fmt=$(QEMU_DISK_FORMAT) $@ $(QEMU_DISK_SIZE)
	$(Q)$(QEMU_IMAGE_BIN) info $@

