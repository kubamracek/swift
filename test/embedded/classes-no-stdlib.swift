// RUN: %target-swift-emit-ir %s -parse-stdlib -enable-experimental-feature Embedded -target arm64e-apple-none | %FileCheck %s

// TODO: investigate why windows is generating more metadata.
// XFAIL: OS=windows-msvc

public class MyClass {}

public func foo() -> MyClass {
  return MyClass()
}

// CHECK: xxx
