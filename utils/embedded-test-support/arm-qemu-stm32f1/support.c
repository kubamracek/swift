//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#include <stddef.h>
#include <stdint.h>

int main(int argc, char *argv[]);
void qemu_exit(void);
int puts(const char *);

__attribute__((noreturn))
void reset(void) {
  main(0, NULL);
  qemu_exit();
  __builtin_trap();
}

void interrupt(void) {
  puts("INTERRUPT\n");
  qemu_exit();
  while (1) {
  }
}

__attribute__((aligned(4))) char stack[2048];

__attribute((used))
__attribute((section(".vectors"))) void *vector_table[114] = {
    (void *)&stack[2048 - 4],  // initial SP
    reset,                 // Reset

    interrupt,  // NMI
    interrupt,  // HardFault
    interrupt,  // MemManage
    interrupt,  // BusFault
    interrupt,  // UsageFault

    0  // NULL for all the other handlers
};

void qemu_exit() {
  register uintptr_t a asm("r0") = 0x18;
  register uintptr_t b asm("r1") = 0x20026;
  __asm__ volatile("BKPT #0xAB" : : "r"(a), "r"(b));
}

int putchar(int c) {
  // STM32F1 specific location of USART1 and its DR register
  *(volatile uint32_t *)(0x40013800 + 0x04) = c;
  return c;
}
