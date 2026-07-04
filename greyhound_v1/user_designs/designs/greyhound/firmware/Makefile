CV_SW_TOOLCHAIN  ?= /opt/riscv
RISCV            ?= $(CV_SW_TOOLCHAIN)
RISCV_EXE_PREFIX ?= $(RISCV)/bin/riscv32-unknown-elf-
RISCV_CC         ?= gcc
RISCV_GCC = $(RISCV_EXE_PREFIX)$(RISCV_CC)
RISCV_AR = $(RISCV_EXE_PREFIX)ar
RISCV_MARCH ?= rv32ima_zicsr #rv32imc_zicsr
SRC = firmware.c
OBJ = firmware.o
CFLAGS ?= -Os -g -static -mabi=ilp32 -march=$(RISCV_MARCH) -Wall -pedantic $(RISCV_CFLAGS) -I ../bsp -I ../bsp/drivers/EF_UART

TARGET = firmware
DESIGNS = peripheral xif

BIT_TO_HEADER ?= ../../../scripts/bit_to_header.py
ELF_TARGET = $(TARGET).elf
BIN_TARGET = $(TARGET).bin

BSP_PATH = bsp
LINKER_SCRIPT = $(BSP_PATH)/link.ld

LDFLAGS += -T $(LINKER_SCRIPT) -nostartfiles
LDFLAGS += -L$(ENV_DIR) --specs=nano.specs

all: $(addsuffix .bit, $(DESIGNS)) $(addsuffix .h, $(DESIGNS)) compile-bsp $(BIN_TARGET)

%.bit: RTL=$<
%.bit: TOP=$(basename $<)
%.bit: %.sv
	$(MAKE) -f ../../../makefile.include synth pnr bitstream hex -e RTL=$(RTL) TOP=$(TOP)

%.h: %.bit
	python3 $(BIT_TO_HEADER) $< $@

%.o : %.c
	$(RISCV_GCC) $(CFLAGS) -c $< -o $@

$(ELF_TARGET): $(OBJ)
	$(RISCV_GCC) $(CFLAGS) $< -L$(BSP_PATH) -l:bsp.a -o $@ $(LDFLAGS)

$(BIN_TARGET): $(ELF_TARGET)
	$(RISCV_EXE_PREFIX)objcopy -O binary $< $@

help:
	$(MAKE) -f ../../../makefile.include help
	@echo "Commands special to firmware:"
	@echo " vars            ... Make c compiler variables"
	@echo " bsp             ... Build c dependencies"
.phony: help

compile-bsp:
	cd bsp; make
.phony: compile-bsp

synth:
	for DESIGN in $(DESIGNS); do \
		$(MAKE) -f ../../../makefile.include synth -e TOP=$$DESIGN; \
		rm -rf $$DESIGN.h; \
	done;
.phony: synth

pnr:
	for DESIGN in $(DESIGNS); do \
		$(MAKE) -f ../../../makefile.include pnr -e TOP=$$DESIGN; \
		rm -rf $$DESIGN.h; \
	done;
.phony: pnr

bitstream:
	for DESIGN in $(DESIGNS); do \
		$(MAKE) -f ../../../makefile.include bitstream -e TOP=$$DESIGN; \
		rm -rf $$DESIGN.h; \
	done;
.phony: bitstream

hex:
	for DESIGN in $(DESIGNS); do \
		$(MAKE) -f ../../../makefile.include hex -e TOP=$$DESIGN; \
		rm -rf $$DESIGN.h; \
	done;
.phony: hex

clean:
	for DESIGN in $(DESIGNS); do \
		$(MAKE) -f ../../../makefile.include clean -e TOP=$$DESIGN; \
		rm -rf $$DESIGN.h; \
	done;

	rm -f $(OBJ) $(ELF_TARGET) $(BIN_TARGET)
	cd bsp; make clean
.phony:clean

vars:
	@echo "make variables:"
	@echo "   CV_SW_TOOLCHAIN  = $(CV_SW_TOOLCHAIN)"
	@echo "   RISCV            = $(RISCV)"
	@echo "   RISCV_EXE_PREFIX = $(RISCV_EXE_PREFIX)"
	@echo "   RISCV_GCC        = $(RISCV_GCC)"
	@echo "   RISCV_MARCH      = $(RISCV_MARCH)"
	@echo "   RISCV_CFLAGS     = $(RISCV_CFLAGS)"
	@echo "   CFLAGS           = $(CFLAGS)"

	cd bsp; make vars
.phony: vars
