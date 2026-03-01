#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




ifeq ($(QEMU_GRAPHIC_TYPE),none)

QEMU_RUN_ARGS				+= -nographic

else # ($(QEMU_GRAPHIC_TYPE),none)

QEMU_RUN_ARGS 				+= -name "KyberBench"

QEMU_RUN_ARGS 				+= -usb
QEMU_RUN_ARGS 				+= -device qemu-xhci
#QEMU_RUN_ARGS 				+= -device usb-host,hostbus=1,hostaddr=1
QEMU_RUN_ARGS 				+= -device usb-mouse
QEMU_RUN_ARGS 				+= -device usb-kbd
QEMU_RUN_ARGS 				+= -device usb-tablet


ifeq ($(QEMU_GRAPHIC_TYPE),fb)

QEMU_RUN_ARGS 				+= -device ramfb

else # ($(QEMU_GRAPHIC_TYPE),fb)

QEMU_VIRTIO_GPU_OPTS		?= xres=1920,yres=1080


ifeq ($(filter %-virgl,$(QEMU_GRAPHIC_TYPE)),)

QEMU_RUN_ARGS 				+= -display sdl

# 2D MMIO

ifeq ($(QEMU_GRAPHIC_TYPE),mmio)

QEMU_RUN_ARGS 				+= -device virtio-gpu-device,$(QEMU_VIRTIO_GPU_OPTS),bus=virtio-mmio-bus.11

endif # ($(QEMU_GRAPHIC_TYPE),mmio)

# 2D PCIE

ifeq ($(QEMU_GRAPHIC_TYPE),pcie)

QEMU_RUN_ARGS 				+= -device virtio-gpu,$(QEMU_VIRTIO_GPU_OPTS)

endif # ($(QEMU_GRAPHIC_TYPE),pcie)

else # ($(filter %-virgl,$(QEMU_GRAPHIC_TYPE)),)

QEMU_VIRGL_PATH				?= /usr/local/virgl

#QEMU_RUN_ENV				:= export PATH=$(QEMU_VIRGL_PATH)/bin:${PATH};
QEMU_RUN_ENV				+= export LD_LIBRARY_PATH=$(QEMU_VIRGL_PATH)/lib/x86_64-linux-gnu;


ifeq ($(QEMU_VIRGL_DRIVER),virpipe)

QEMU_RUN_ENV				+= export LIBGL_ALWAYS_SOFTWARE=1;
QEMU_RUN_ENV				+= export GALLIUM_DRIVER=virpipe;

endif # ($(QEMU_VIRGL_DRIVER),virpipe)

QEMU_RUN_ARGS 				+= -display sdl,gl=on

# 3D MMIO

ifeq ($(QEMU_GRAPHIC_TYPE),mmio-virgl)

QEMU_RUN_ARGS 				+= -device virtio-gpu-gl-device,$(QEMU_VIRTIO_GPU_OPTS),bus=virtio-mmio-bus.11

endif # ($(QEMU_GRAPHIC_TYPE),mmio-virgl)


# 3D PCIE

ifeq ($(QEMU_GRAPHIC_TYPE),pcie-virgl)

QEMU_RUN_ARGS 				+= -device virtio-gpu-gl,$(QEMU_VIRTIO_GPU_OPTS)

endif # ($(QEMU_GRAPHIC_TYPE),pcie-virgl)

endif # ($(filter %-virgl,$(QEMU_GRAPHIC_TYPE)),)

endif # ($(QEMU_GRAPHIC_TYPE),fb)

endif # ($(QEMU_GRAPHIC_TYPE),none)

