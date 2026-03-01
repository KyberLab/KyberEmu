#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




###############################################################################
# Dump Qemu DTB File

ifeq ($(QEMU_DTB_DUMP),1)

QEMU_RUN_ARGS		+= \
	-machine dumpdtb=$(QEMU_DTB_FILE)

endif



###############################################################################
# Edu Device Arguments, for SMMU Test

ifeq ($(QEMU_EDU_ENABLE),1)

QEMU_RUN_ARGS		+= \
	-device edu,dma_mask=0xffffffff

endif



###############################################################################
# Debug Arguments

ifeq ($(QEMU_DEBUG_ENABLE),1)

QEMU_RUN_ARGS		+= \
	-s -S

endif

