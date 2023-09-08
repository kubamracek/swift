// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -lto=llvm-full -Osize -target arm64-apple-none-macho -Xcc -D__MACH__ -Xcc -D__arm64__ -Xcc -D__APPLE__ %s -enable-experimental-feature Embedded -emit-bc -o %t/a.o
// RUN: %target-clang %t/a.o -o %t/a.out -Wl,-dead_strip -Wl,-why_live,'_$sSi6signumSiyF'
// RUN: %target-run %t/a.out | %FileCheck %s

// REQUIRES: executable_test

@_silgen_name("putchar")
func putchar(_: UInt8)

public func print(_ s: StaticString, terminator: StaticString = "\n") {
  var p = s.utf8Start
  while p.pointee != 0 {
    putchar(p.pointee)
    p += 1
  }
  p = terminator.utf8Start
  while p.pointee != 0 {
    putchar(p.pointee)
    p += 1
  }
}

print("Hello, Embedded Swift!")
// CHECK: Hello, Embedded Swift!
