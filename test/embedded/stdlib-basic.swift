// RUN: %target-swift-frontend -target armv7-apple-none-macho -Xcc -D__MACH__ -emit-ir %s -nostdimport -I /Users/kuba/swift-github-main/build/Ninja-RelWithDebInfoAssert/swift-macosx-arm64/lib/swift/embedded -enable-experimental-feature Embedded

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
