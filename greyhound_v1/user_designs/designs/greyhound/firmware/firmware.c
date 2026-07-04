// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>

#include "bsp/soc.h"
#include "peripheral.h"
#include "xif.h"

#define F_CPU 50000000

void wait_nop(uint16_t wait) {
  for (uint16_t  i = 0; i < wait; i++) {
    asm volatile ("nop");
  }
}

uint32_t custom_instruction(uint32_t op1, uint32_t op2) {
  uint32_t ret;
  
  __asm__ volatile (".insn r 0x5b, 0, 13, %0, %1, %2" : "=r" (ret)
                                                      : "r"  (op1),
                                                        "r"  (op2));

  return ret;
}

// This is a minimum example to get the CPU <--> eFPGA interfaces going. For further drivers and examples check out the greyhound-v1 repo.
// Write the bitstream via the CPU and then write some values to the GPIOs
int main()
{
  // Write bitstream to output 8 bit with the peripheral
  for (uint32_t i = 0; i < sizeof(peripheral_bitstream)/sizeof(uint32_t); i++) {
    *REG_BITSTREAM = peripheral_bitstream[i];
  }

  // Test Peripheral by writing an 8 bit value. Bitstream will write the value through to the GPIOs
  *REG_XIF_OR_PERIPH = 1; // Set CPU_IF to peripheral
  wait_nop(0x100);
  *((int*)FABRIC_BASE) = 0x0;
  wait_nop(0x100);
  *((int*)FABRIC_BASE) = 0xdeadbeef;
  wait_nop(0x100);
  *((int*)FABRIC_BASE) = 0xc0ffee;
  wait_nop(0x100);
  *((int*)FABRIC_BASE) = 0xcafebabe;
  wait_nop(0x100);
  *((int*)FABRIC_BASE) = 0x7eeee7;
  wait_nop(0x100);

  // Write bitstream to output 8 bit with the xif
  for (uint32_t i = 0; i < sizeof(xif_bitstream)/sizeof(uint32_t); i++) {
    *REG_BITSTREAM = xif_bitstream[i];
  }

  // Test xif by writing some values. Bitstream will combine op1 and 2 into a single 8 bit value on the GPIOs
  *REG_XIF_OR_PERIPH = 0; // Set CPU_IF to xif
  wait_nop(0x100);
  custom_instruction(0x0, 0x0);
  wait_nop(0x100);
  custom_instruction(0xbeef, 0xdead);
  wait_nop(0x100);
  custom_instruction(0xfee, 0xc0f);
  wait_nop(0x100);
  custom_instruction(0xbabe, 0xcafe);
  wait_nop(0x100);
  custom_instruction(0xee7, 0x7ee);
  wait_nop(0x100);

  return 0;
}
