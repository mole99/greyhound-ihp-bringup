// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>

#include <soc.h>
#include <greyhound_sine_periph/greyhound_sine_periph.h>

#define F_CPU 25175000 // Use VGA frequency

#define NUM_CHARS 32

void wait_nop(uint32_t wait) {
  for (uint32_t i=0; i < wait; i++) {
    asm volatile ("nop");
  }
}

void clear_string() {
    for (int i=0; i<NUM_CHARS; i++) {
        *(REG_PERIPH_BASE + i) = ' ';
    }
}

void write_string(const char* str) {
    int cnt = 0;
    // Check if there's data or too long
    while (str[cnt] != '\0') {
        *(REG_PERIPH_BASE + cnt) = str[cnt];
        cnt++;
    }
}

void write_string_offset(const char* str, int offset) {
    // Check if there's data or too long
    for (int i=0; i<NUM_CHARS; i++) {
        *(REG_PERIPH_BASE + i) = str[(i + offset) % NUM_CHARS];
    }
}

void write_string_delay(const char* str, int delay) {
    int cnt = 0;
    // Check if there's data or too long
    while (str[cnt] != '\0') {
        *(REG_PERIPH_BASE + cnt) = str[cnt];
        cnt++;
        wait_nop(delay);
    }
}


int main()
{
  // Write bitstream to eFPGA
  for (uint32_t i = 0; i < sizeof(greyhound_sine_periph_bitstream)/sizeof(uint32_t); i++) {
    *REG_BITSTREAM = greyhound_sine_periph_bitstream[i];
  }

  *REG_XIF_OR_PERIPH = 1; // Set CPU_IF to peripheral
  
  clear_string();
  
  wait_nop(F_CPU/5);
  
  write_string("HELLO WORLD!");

  wait_nop(F_CPU);
  
  clear_string();
  
  wait_nop(F_CPU/5);
  
  write_string_delay("HOW ARE YOU? WHAT ARE YOU DOING?", F_CPU/40);

  wait_nop(F_CPU/5);

  write_string_delay("IM FINE                      OK ", F_CPU/40);
  
  wait_nop(F_CPU/5);
  
  while (1) {
      for (int i=0; i<NUM_CHARS; i++) {
          write_string_offset("GREYHOUND FOREVER !!!            ", 31-i);
          wait_nop(F_CPU/200);
      }
  }

  return 0;
}
