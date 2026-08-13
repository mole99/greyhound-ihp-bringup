// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>

#include <soc.h>
#include <xif_gpio/xif_gpio.h>

#define F_CPU 25175000 // Use VGA frequency

void wait_nop(uint32_t wait) {
  for (uint32_t i = 0; i < wait; i++) {
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

// The xif_gpio peripheral outputs the lower 16 bit of op1 and op2 on the gpios
int main()
{
  // Write bitstream to eFPGA
  for (uint32_t i = 0; i < sizeof(xif_gpio_bitstream)/sizeof(uint32_t); i++) {
    *REG_BITSTREAM = xif_gpio_bitstream[i];
  }

  *REG_XIF_OR_PERIPH = 0; // Set CPU_IF to xif
  
  // 0.41 Hz blinking
  while (1) {
    wait_nop(F_CPU / 10);
    custom_instruction(0x0, 0x0);
    wait_nop(F_CPU / 10);
    custom_instruction(0xbeef, 0xffffffff);
  }

  return 0;
}
