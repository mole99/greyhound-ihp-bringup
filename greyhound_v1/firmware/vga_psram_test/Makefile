RISCV_EXE_PREFIX ?= riscv32-none-elf-
RISCV_CC         ?= gcc
RISCV_GCC = $(RISCV_EXE_PREFIX)$(RISCV_CC)
RISCV_AR = $(RISCV_EXE_PREFIX)ar
RISCV_MARCH ?= rv32imac_zicntr_zicsr_zifencei_zihpm_zca_zcb_zcmp_zcmt_zba_zbb_zbc_zbs
PYTHON ?= python3
SRC = vga_psram_test.c
OBJ = vga_psram_test.o

CFLAGS += -Os -g -static -Wall -Wextra -pedantic
CFLAGS += -mabi=ilp32 -march=$(RISCV_MARCH)
CFLAGS += -I ../bsp -I ../bsp/drivers/EF_UART -I ../../user_designs/designs/greyhound/

TARGET = vga_psram_test
ELF_TARGET = $(TARGET).elf
BIN_TARGET = $(TARGET).bin
HEX_TARGET= $(TARGET).hex

BSP_PATH = ../bsp
LINKER_SCRIPT = $(BSP_PATH)/link.ld

LDFLAGS += -T $(LINKER_SCRIPT) -nostartfiles
LDFLAGS += -L$(ENV_DIR) --specs=nano.specs

all: $(BIN_TARGET)

%.o : %.c
	$(RISCV_GCC) $(CFLAGS) -c $< -o $@

$(ELF_TARGET): $(OBJ) compile-bsp
	$(RISCV_GCC) $(CFLAGS) $< -L$(BSP_PATH) -l:bsp.a -o $@ $(LDFLAGS)

$(BIN_TARGET): $(ELF_TARGET)
	$(RISCV_EXE_PREFIX)objcopy -O binary $< $@

$(HEX_TARGET): $(BIN_TARGET)
	$(PYTHON) ../makehex.py $< $@

dump: $(ELF_TARGET)
	$(RISCV_EXE_PREFIX)objdump -d -x $<
.phony: dump

copy: $(BIN_TARGET)
	cp $(BIN_TARGET) ../../board/firmware/$(BIN_TARGET)
.phony: copy

help:
	@echo "Commands special to firmware:"
	@echo " vars            ... Make c compiler variables"
	@echo " bsp             ... Build c dependencies"
.phony: help

compile-bsp:
	cd $(BSP_PATH); make
.phony: compile-bsp

clean:
	rm -f $(OBJ) $(ELF_TARGET) $(BIN_TARGET)
	cd $(BSP_PATH); make clean
.phony:clean

vars:
	@echo "make variables:"
	@echo "   CV_SW_TOOLCHAIN  = $(CV_SW_TOOLCHAIN)"
	@echo "   RISCV            = $(RISCV)"
	@echo "   RISCV_EXE_PREFIX = $(RISCV_EXE_PREFIX)"
	@echo "   RISCV_GCC        = $(RISCV_GCC)"
	@echo "   RISCV_MARCH      = $(RISCV_MARCH)"
	@echo "   CFLAGS           = $(CFLAGS)"
	cd $(BSP_PATH); make vars
.phony: vars
