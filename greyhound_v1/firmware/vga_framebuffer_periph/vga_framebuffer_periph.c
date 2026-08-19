// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <soc.h>
#include <vga_framebuffer_periph/vga_framebuffer_periph.h>

#include "images/image_1.h"
#include "images/image_2.h"
#include "images/image_3.h"
#include "images/image_1_dither.h"
#include "images/image_2_dither.h"
#include "images/image_3_dither.h"

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

void write_image(const uint8_t image[]) {
  /*for (int i=0; i<WIDTH*HEIGHT/4; i++) {
    *(volatile uint32_t*)(FABRIC_BASE + i) = *((const uint32_t*)image + i);
  }*/
  
  memcpy((uint8_t*)FABRIC_BASE, image, WIDTH*HEIGHT);
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
  clear(0x4C); // green - lsb set
  wait_nop(F_CPU/20);
  clear(0xB0); // red - lsb set
  wait_nop(F_CPU/20);

  while (1) {

    write_image(image_1_data);
    wait_nop(F_CPU);
    write_image(image_1_dither_data);
    wait_nop(F_CPU);
    write_image(image_2_data);
    wait_nop(F_CPU);
    write_image(image_2_dither_data);
    wait_nop(F_CPU);
    write_image(image_3_data);
    wait_nop(F_CPU);
    write_image(image_3_dither_data);
    wait_nop(F_CPU);

  }

  return 0;
}
