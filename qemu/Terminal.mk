#                                 KyberBench
# Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
#




QEMU_TERM_PORTS				?= 
# $(QEMU_UART1_PORT)

QEMU_TERM_PORT1				:= $(QEMU_UART2_PORT)
QEMU_TERM_PORT2				:= $(QEMU_UART3_PORT)
QEMU_TERM_PORT3				:= $(QEMU_UART4_PORT)

QEMU_TERM_OPTS				:= ,server,nowait

QEMU_TERM_OPTSS				:= $(QEMU_TERM_OPTS)
QEMU_TERM_OPTS1				:= $(QEMU_TERM_OPTS)
QEMU_TERM_OPTS2				:= $(QEMU_TERM_OPTS)
QEMU_TERM_OPTS3				:= $(QEMU_TERM_OPTS)


ifeq ($(QEMU_TERM_TYPE),none)


QEMU_PRE_RUN				:= \
	$(call xprint_title,	"Enter Console") && \
	$(call xprint_value,	$(QEMU_MONITOR_TITLE),		$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_MONITOR_PORT))


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 1 ];echo $$?),0)

QEMU_PRE_RUN				+= && \
	$(call xprint_value,	$(QEMU_UART1_TITLE),		$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT1))

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 2 ];echo $$?),0)

QEMU_PRE_RUN				+= && \
	$(call xprint_value,	$(QEMU_UART2_TITLE),		$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT2))

endif

ifeq ($(shell [ $(QEMU_UART_NUM) -ge 3 ];echo $$?),0)

QEMU_PRE_RUN				+= && \
	$(call xprint_value,	$(QEMU_UART3_TITLE),		$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT3))

endif

QEMU_POST_RUN				:= 


else


ifeq ($(QEMU_TERM_TYPE),gnome)

ifeq ($(shell [ $(QEMU_UART_NUM) -ge 1 ];echo $$?),0)

QEMU_PRE_RUN				:= \
	nc -z $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT1) || gnome-terminal -t $(QEMU_UART1_TITLE) -- $(QEMU_TERMINAL) $(QEMU_TERM_PORT1)
QEMU_TERM_OPTS1				:= 

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 2 ];echo $$?),0)

QEMU_PRE_RUN				+= && \
	nc -z $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT2) || gnome-terminal -t $(QEMU_UART2_TITLE) -- $(QEMU_TERMINAL) $(QEMU_TERM_PORT2)
QEMU_TERM_OPTS2				:= 

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 3 ];echo $$?),0)

QEMU_PRE_RUN				+= && \
	nc -z $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT3) || gnome-terminal -t $(QEMU_UART3_TITLE) -- $(QEMU_TERMINAL) $(QEMU_TERM_PORT3)
QEMU_TERM_OPTS3				:= 

endif


QEMU_POST_RUN				:= \
	ps -aux | awk '$$12~"$(QEMU_TERMINAL)" {print $$2}' | head -n$(QEMU_UART_NUM) | xargs -i kill -9 {}


else

ifeq ($(QEMU_TERM_TYPE),tmux)

QEMU_PRE_RUN				:= \
	$(call xprint_info,		"Switch Pane : Ctrl + B + Arrow Keys",$(HB_CYAN))


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 1 ];echo $$?),0)

QEMU_POST_RUN				:= \
	tmux split-window -h '$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT1)'

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 2 ];echo $$?),0)

QEMU_POST_RUN				+= && \
	tmux select-pane -t $(QEMU_TMUX_NAME) -L && \
	tmux split-window -v '$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT2)'

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 3 ];echo $$?),0)

QEMU_POST_RUN				+= && \
	tmux select-pane -t $(QEMU_TMUX_NAME) -R && \
	tmux split-window -v '$(QEMU_TERM_CLIENT) $(QEMU_TERM_ADDR) $(QEMU_TERM_PORT3)'

endif


ifneq ($(QEMU_POST_RUN),)

QEMU_POST_RUN				+= && 

endif


QEMU_POST_RUN				+= \
	tmux attach-session -t $(QEMU_TMUX_NAME)


else

$(error invalid terminal type "$(QEMU_TERM_TYPE)")


endif # ($(QEMU_TERM_TYPE),tmux)
endif # ($(QEMU_TERM_TYPE),gnome)
endif # ($(QEMU_TERM_TYPE),none)


QEMU_RUN_ARGS				+= \
	-serial mon:stdio \
	-monitor $(QEMU_TERM_PROTO):$(QEMU_TERM_ADDR):$(QEMU_MONITOR_PORT)$(QEMU_TERM_OPTS)


ifneq ($(QEMU_TERM_PORTS),)

QEMU_RUN_ARGS				+= \
	-serial $(QEMU_TERM_PROTO):$(QEMU_TERM_ADDR):$(QEMU_TERM_PORTS)$(QEMU_TERM_OPTSS)

else

QEMU_RUN_ARGS				+= \
	-serial null

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 1 ];echo $$?),0)

QEMU_RUN_ARGS				+= \
	-serial $(QEMU_TERM_PROTO):$(QEMU_TERM_ADDR):$(QEMU_TERM_PORT1)$(QEMU_TERM_OPTS1)

else

QEMU_RUN_ARGS				+= \
	-serial null

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 2 ];echo $$?),0)

QEMU_RUN_ARGS				+= \
	-serial $(QEMU_TERM_PROTO):$(QEMU_TERM_ADDR):$(QEMU_TERM_PORT2)$(QEMU_TERM_OPTS2)

else

QEMU_RUN_ARGS				+= \
	-serial null

endif


ifeq ($(shell [ $(QEMU_UART_NUM) -ge 3 ];echo $$?),0)

QEMU_RUN_ARGS				+= \
	-serial $(QEMU_TERM_PROTO):$(QEMU_TERM_ADDR):$(QEMU_TERM_PORT3)$(QEMU_TERM_OPTS3)

else

QEMU_RUN_ARGS				+= \
	-serial null

endif

