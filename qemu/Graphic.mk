#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




ifeq ($(QEMU_GRAPHIC_TYPE),none)
#QEMU_GRAPHIC_ARGS			+= -nographic
endif # ($(QEMU_GRAPHIC_TYPE),none)


ifeq ($(QEMU_GRAPHIC_TYPE),fb)
QEMU_GRAPHIC_ARGS 			+= -device ramfb
endif # ($(QEMU_GRAPHIC_TYPE),fb)


QEMU_VIRTIO_GPU_OPTS		?= xres=1920,yres=1080


# 2D MMIO
ifeq ($(QEMU_GRAPHIC_TYPE),mmio)
QEMU_GRAPHIC_ARGS 			+= -display sdl
QEMU_GRAPHIC_ARGS 			+= -device virtio-gpu-device,$(QEMU_VIRTIO_GPU_OPTS),bus=virtio-mmio-bus.11
endif # ($(QEMU_GRAPHIC_TYPE),mmio)


# 2D PCIE
ifeq ($(QEMU_GRAPHIC_TYPE),pcie)
QEMU_GRAPHIC_ARGS 			+= -device virtio-gpu,$(QEMU_VIRTIO_GPU_OPTS)
endif # ($(QEMU_GRAPHIC_TYPE),pcie)



ifneq ($(filter %-virgl,$(QEMU_GRAPHIC_TYPE)),)

QEMU_GRAPHIC_ARGS 			+= -display sdl,gl=on

QEMU_VIRGL_PATH				?= /usr/local/virgl

#QEMU_GRAPHIC_ENV			+= export PATH=$(QEMU_VIRGL_PATH)/bin:${PATH};
QEMU_GRAPHIC_ENV			+= export LD_LIBRARY_PATH=$(QEMU_VIRGL_PATH)/lib/x86_64-linux-gnu;


# 3D VirPipe
ifeq ($(QEMU_VIRGL_DRIVER),virpipe)
QEMU_GRAPHIC_ENV			+= export LIBGL_ALWAYS_SOFTWARE=1;
QEMU_GRAPHIC_ENV			+= export GALLIUM_DRIVER=virpipe;
endif # ($(QEMU_VIRGL_DRIVER),virpipe)


# 3D MMIO
ifeq ($(QEMU_GRAPHIC_TYPE),mmio-virgl)
QEMU_GRAPHIC_ARGS 			+= -device virtio-gpu-gl-device,$(QEMU_VIRTIO_GPU_OPTS),bus=virtio-mmio-bus.11
endif # ($(QEMU_GRAPHIC_TYPE),mmio-virgl)


# 3D PCIE
ifeq ($(QEMU_GRAPHIC_TYPE),pcie-virgl)
QEMU_GRAPHIC_ARGS 			+= -device virtio-gpu-gl,$(QEMU_VIRTIO_GPU_OPTS)
endif # ($(QEMU_GRAPHIC_TYPE),pcie-virgl)

endif # ($(filter %-virgl,$(QEMU_GRAPHIC_TYPE)),)



QEMU_RUN_ARGS 				+= $(QEMU_GRAPHIC_ARGS)
QEMU_RUN_ENV				+= $(QEMU_GRAPHIC_ENV)