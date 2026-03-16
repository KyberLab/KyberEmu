#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




###############################################################################
# Default Macros


# file_is_exist
# $(1) file path
# return empty if exist.
ifeq ($(origin file_is_exist),undefined)
define file_is_exist
$(shell ls $(1) > /dev/null 2>&1;echo $$? | grep -v 0)
endef
endif


# rule_inc
# $(1) rule file path
ifeq ($(origin rule_inc),undefined)
define rule_inc
$(if $(call file_is_exist,$(1)),$(error Rule File "$(1)" Not Exist !!!),include $(1))
endef
endif


# is_in_docker
# return : empty if in docker
ifeq ($(origin is_in_docker),undefined)
define is_in_docker
$(shell echo `[ ! -f /.dockerenv ]` $$? | grep -v 1)
endef
endif


# cur_dir
# return : current directory path
ifeq ($(origin cur_dir),undefined)
define cur_dir
$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
endef
endif




###############################################################################
# Path Check


ifeq ($(origin EMU_ROOT_PATH),undefined)
#$(warning "EMU_ROOT_PATH has not been defined.")
EMU_ROOT_PATH			:= $(call cur_dir)
#$(warning Define EMU_ROOT_PATH = $(EMU_ROOT_PATH))
endif

ifeq ($(origin OUTPUT_ROOT_PATH),undefined)
OUTPUT_ROOT_PATH		:= $(WORKSPACE_ROOT_PATH)/output
endif


RULES_ROOT_PATH			:= $(EMU_ROOT_PATH)/rules

# Basic Rules
$(eval $(call rule_inc,$(RULES_ROOT_PATH)/Main.mk))



###############################################################################
# Emulator Targets


.PHONY	: run

run		: qemu_run



###############################################################################
# Qemu Basic Config

QEMU_RUN_BIN				?= qemu-system-aarch64
QEMU_IMAGE_BIN				?= qemu-img
QEMU_NBD_BIN				?= qemu-nbd

QEMU_GIC_VER				?= 3

QEMU_MACHINE_TYPE			?= virt,gic-version=$(QEMU_GIC_VER),virtualization=on,iommu=smmuv3

QEMU_CPU_TYPE				?= cortex-a72
QEMU_CPU_NUM				?= 2

QEMU_MEM_SIZE				?= 2G

QEMU_UART_NUM				?= 0



###############################################################################
# Qemu Boot Config

QEMU_BOOT_IMAGE				?= BuildRoot



###############################################################################
# Qemu Terminal Config

QEMU_TERMINAL				:= $(EMU_ROOT_PATH)/scripts/emu-term.py
QEMU_TERM_TYPE				?= none

QEMU_TERM_CLIENT			?= telnet
QEMU_TERM_PROTO				?= telnet
QEMU_TERM_ADDR				?= localhost

QEMU_MONITOR_PORT			?= 30001
QEMU_UART1_PORT				?= 30002
QEMU_UART2_PORT				?= 30003
QEMU_UART3_PORT				?= 30004
QEMU_UART4_PORT				?= 30005

QEMU_MONITOR_TITLE			?= "Monitor"
QEMU_UART1_TITLE			?= "UART1"
QEMU_UART2_TITLE			?= "UART2"
QEMU_UART3_TITLE			?= "UART3"
QEMU_UART4_TITLE			?= "UART4"

QEMU_TMUX_NAME				?= kyberemu
QEMU_TMUX_OPTS				?= tmux set-option -g mouse on;



###############################################################################
# Qemu Graphic Config

QEMU_GRAPHIC_TYPE			?= none



###############################################################################
# Qemu Storage Config

QEMU_STORAGE_TYPE			?= mmio

QEMU_DISK1_NAME				?= vda
QEMU_DISK2_NAME				?= vdb
QEMU_DISK3_NAME				?= vdc

QEMU_DISK_SIZE				?= 30G
QEMU_DISK_FORMAT			?= qcow2
QEMU_DISK_NBD_NAME			?= nbd0
QEMU_DISK_NBD_PATH			?= /dev/$(QEMU_DISK_NBD_NAME)



###############################################################################
# Qemu Share Config

QEMU_SHARE_ENABLE			?= 1
QEMU_SHARE_PATH				?= $(WORKSPACE_ROOT_PATH)



###############################################################################
# Qemu Network Config

QEMU_NETWORK_TYPE			?= mmio

QEMU_TAP_NAME				?= vtap-$(shell date +%m%d)
QEMU_TAP_MAC				?= 00:11:33:55:77:99
QEMU_TAP_USER				?= $(shell id -un)



###############################################################################
# Qemu DTB Config

QEMU_DTB_DUMP				?= 0
QEMU_DTB_FILE				?= $(OUTPUT_ROOT_PATH)/virt-aarch64.dtb



###############################################################################
# Qemu Misc Config

QEMU_EDU_ENABLE				?= 0
QEMU_DEBUG_ENABLE			?= 0



###############################################################################
# Virtual Network Config

NETWORK_PREFIX				?= 192.168.77
NETWORK_SUBNET				?= $(NETWORK_PREFIX).0
NETWORK_GATEWAY				?= $(NETWORK_PREFIX).66
NETWORK_BEGIN				?= $(NETWORK_PREFIX).128
NETWORK_END					?= $(NETWORK_PREFIX).192
NETWORK_NAME				?= nat0

NETWORK_NAMESPACE			?= test-ns
NETWORK_VETH				?= test-ve
NETWORK_TESTIP				?= 8.8.8.8



###############################################################################
# Image Emulator Config

$(eval $(call rule_inc,$(CONFIG_IMAGE_PATH)/$(QEMU_BOOT_IMAGE)/EmuConfig.mk))



###############################################################################
# Emulator Virtual Environment

$(eval $(call rule_inc,$(EMU_ROOT_PATH)/virt/Network.mk))

$(eval $(call rule_inc,$(EMU_ROOT_PATH)/virt/Image.mk))



###############################################################################
# Emulator Qemu Arguments

QEMU_RUN_ARGS				:= \
	-M $(QEMU_MACHINE_TYPE) \
	-cpu $(QEMU_CPU_TYPE) \
	-smp $(QEMU_CPU_NUM) \
	-m $(QEMU_MEM_SIZE)

# -global arm-smmuv3.stage=2 


QEMU_BOOT_BIN				?= $(IMAGE_BOOT_BIN)



###############################################################################

# Terminal Arguments
$(eval $(call rule_inc,$(EMU_ROOT_PATH)/qemu/Terminal.mk))

# Graphic Device Arguments
$(eval $(call rule_inc,$(EMU_ROOT_PATH)/qemu/Graphic.mk))

# Storage Device Arguments
$(eval $(call rule_inc,$(EMU_ROOT_PATH)/qemu/Storage.mk))

# Network Device Arguments
$(eval $(call rule_inc,$(EMU_ROOT_PATH)/qemu/Network.mk))

# Develop Arguments
$(eval $(call rule_inc,$(EMU_ROOT_PATH)/qemu/Develop.mk))



###############################################################################
# Miscellaneous Arguments

QEMU_RUN_ARGS 				+= -name "KyberBench"

QEMU_RUN_ARGS 				+= -usb
QEMU_RUN_ARGS 				+= -device qemu-xhci
#QEMU_RUN_ARGS 				+= -device usb-host,hostbus=1,hostaddr=1
QEMU_RUN_ARGS 				+= -device usb-mouse
QEMU_RUN_ARGS 				+= -device usb-kbd
QEMU_RUN_ARGS 				+= -device usb-tablet



###############################################################################
# Image Emulator Arguments

QEMU_PRE_RUN				+= $(IMAGE_PRE_RUN)
QEMU_RUN_ARGS				+= $(IMAGE_RUN_ARGS)
QEMU_POST_RUN				+= $(IMAGE_POST_RUN)

QEMU_RUN_ARGS				+= $(QEMU_RUN_EXTRAS)

QEMU_RUN_DEPENDS			+= $(QEMU_TERMINAL)
QEMU_RUN_DEPENDS			+= $(QEMU_BOOT_BIN)



###############################################################################
# Qemu Running Command

QEMU_RUN_CMD				:= $(QEMU_RUN_BIN) $(QEMU_RUN_ARGS)


ifeq ($(QEMU_TERM_TYPE),tmux)
QEMU_RUN_CMD				:= tmux new-session -s $(QEMU_TMUX_NAME) -d '$(QEMU_TMUX_OPTS) $(QEMU_RUN_CMD)' && sleep 1
endif


qemu_run : $(QEMU_RUN_DEPENDS)
	$(Q)$(call xprint_title,	"Qemu Running")
	$(Q)$(call xprint_value,	"Platform",			$(BUILD_PLATFORM))
	$(Q)$(call xprint_value,	"Board",			$(BUILD_BOARD))
	$(Q)$(call xprint_value,	"CPU Type",			$(QEMU_CPU_TYPE))
	$(Q)$(call xprint_value,	"CPU Number",		$(QEMU_CPU_NUM))
	$(Q)$(call xprint_value,	"Memory Size",		$(QEMU_MEM_SIZE))
	$(Q)$(call xprint_value,	"GIC Version",		$(QEMU_GIC_VER))
	$(Q)$(call xprint_value,	"UART Number",		$(QEMU_UART_NUM))
	$(Q)$(call xprint_value,	"Boot Image",		$(QEMU_BOOT_IMAGE))
	$(Q)$(call xprint_value,	"Terminal",			$(QEMU_TERM_TYPE))
	$(Q)$(call xprint_value,	"Storage",			$(QEMU_STORAGE_TYPE))
	$(Q)$(call xprint_value,	"Network",			$(QEMU_NETWORK_TYPE))
	$(Q)$(call xprint_value,	"Graphic",			$(QEMU_GRAPHIC_TYPE))
	$(Q)$(QEMU_PRE_RUN)
	-$(QEMU_RUN_ENV) $(QEMU_RUN_CMD)
	$(Q)$(QEMU_POST_RUN)

