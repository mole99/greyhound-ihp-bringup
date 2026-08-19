// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>

#include <soc.h>
#include <vga_framebuffer_periph/vga_framebuffer_periph.h>

#define F_CPU 25175000 // Use VGA frequency

#define WIDTH 640/4
#define HEIGHT 480/4

void wait_nop(uint32_t wait) {
  for (uint32_t i=0; i < wait; i++) {
    asm volatile ("nop");
  }
}

void set_pixel(int x, int y, uint8_t pixel) {
  *(volatile uint8_t*)(FABRIC_BASE + x + y*WIDTH) = pixel;
}

void clear(uint8_t pixel) {
  for (int i=0; i<WIDTH*HEIGHT; i++) {
    *(volatile uint8_t*)(FABRIC_BASE + i) = pixel;
  }
}

int main()
{
  // Write bitstream to eFPGA
  for (uint32_t i = 0; i < sizeof(vga_framebuffer_periph_bitstream)/sizeof(uint32_t); i++) {
    *REG_BITSTREAM = vga_framebuffer_periph_bitstream[i];
  }

  *REG_XIF_OR_PERIPH = 1; // Set CPU_IF to peripheral
  
  *(REG_PERIPH_BASE + 0) = 0xFF; // 4 white pixel
  
  wait_nop(F_CPU/4);

  clear(0x03); // blue
  wait_nop(F_CPU/20);
  clear(0x0C); // green
  wait_nop(F_CPU/20);
  clear(0x30); // red
  wait_nop(F_CPU/20);
  clear(0xFF);
  wait_nop(F_CPU/4);
  
  // 16 Mbit PSRAM, 24 bits address room
  int x = 0;
  int y = 0;
  
  #define BLOCK_SIZE 32
  #define WORD_SIZE 4
  #define BITS_IN_BYTE 8
  
  for (int i=0; i<16777216/BITS_IN_BYTE/WORD_SIZE/BLOCK_SIZE; i++) {
      bool failure = false;
      
      for (int j=0; j<1024; j++) {
          *((volatile int*)(PSRAM_BASE) + i*BLOCK_SIZE + j) = 0xDEADBEEF + i;
      }
      
      for (int j=0; j<1024; j++) {
          if (*((volatile int*)(PSRAM_BASE) + i*BLOCK_SIZE + j) != 0xDEADBEEF + i) {
            failure = true;
          }
      }
  
      if (failure) {
          set_pixel(x, y, 0x30); // red
      } else {
          set_pixel(x, y, 0x0C); // green
      }
  
      x++;
      if (x >= 160) {
          y++;
          x=0;
      }
  }
  
  while (1);

  return 0;
}
