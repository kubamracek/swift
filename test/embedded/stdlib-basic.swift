// RUN: %target-swift-frontend -target armv7-apple-none-macho -Xcc -D__MACH__ -emit-ir %s -enable-experimental-feature Embedded | %FileCheck %s
// RUN: %target-swift-frontend -target arm64-apple-none-macho -Xcc -D__MACH__ -Xcc -D__arm64__ -Xcc -D__APPLE__ -emit-ir %s -enable-experimental-feature Embedded | %FileCheck %s

// REQUIRES: VENDOR=apple

public func bool() -> Bool {
  return true
}

public func int() -> Int {
  return 42
}

public func ptr(p: UnsafeRawPointer, n: Int) -> UnsafeRawPointer {
  return p.advanced(by: n)
}

public func optional() -> Int? {
  return nil
}

public func staticstring() -> StaticString {
  return "hello"
}
