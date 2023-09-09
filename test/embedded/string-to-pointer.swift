// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -target arm64-apple-none-macho -Xcc -D__MACH__ -Xcc -D__arm64__ -Xcc -D__APPLE__ %s -enable-experimental-feature Embedded -c -o %t/a.o
// RUN: %target-clang %t/a.o -o %t/a.out -Wl,-dead_strip -Wl,-why_live,'_$sSi6signumSiyF'
// RUN: %target-run %t/a.out | %FileCheck %s

// REQUIRES: executable_test

@_silgen_name("putchar")
func puts(_: UnsafePointer<CChar>) -> CInt

puts("Hello World")
// CHECK: Hello World
