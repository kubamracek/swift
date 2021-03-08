// TODO: description

// REQUIRES: OS=macosx
// REQUIRES: executable_test

// RUN: echo "-target x86_64-apple-macos11.0 -swift-version 5 -parse-as-library -working-directory %t" >> %t-commonflags

// RUN: %empty-directory(%t)
// RUN: %target-swiftc_driver @%t-commonflags %s -module-name main -o %t/main -lto=llvm-full -Xlinker -lto_library -Xlinker /Users/kuba/swift-github-main/build/Ninja-RelWithDebInfoAssert/llvm-macosx-arm64/lib/libLTO.dylib
// RUN: %target-run %t/main | %FileCheck %s

// RUN: %llvm-nm --defined-only %t/main | %FileCheck %s --check-prefix=NM

// RUN: %target-swift-frontend -emit-bc -primary-file %s -target x86_64-apple-macos11.0 -enable-objc-interop -swift-version 5 -lto=llvm-full -target-sdk-version 11.3 -parse-as-library -module-name main -o %t.o
// RUN: opt -S %t.o -o %t.ll

public class MyClass {
    func foo() { print("MyClass.foo") }
    func bar() { print("MyClass.bar") }
}

public class MyDerivedClass: MyClass {
    override func foo() { print("MyDerivedClass.foo") }
    override func bar() { print("MyDerivedClass.bar") }
}

public protocol MyProtocol {
    func protofoo()
    func protobar()
}

public struct MyStruct: MyProtocol {
    public func protofoo() { print("MyStruct.protofoo") }
    public func protobar() { print("MyStruct.protobar") }
}

public struct MyUnusedStruct: MyProtocol {
    public func protofoo() { print("MyUnusedStruct.protofoo") }
    public func protobar() { print("MyUnusedStruct.protobar") }
}

@_cdecl("main")
func main() -> Int32 {
    let o: MyClass = MyDerivedClass()
    o.foo()
    let p: MyProtocol = MyStruct()
    p.protofoo()
    return 0
}

// CHECK: MyDerivedClass.foo
// CHECK: MyStruct.protofoo

// NM:     $s4main14MyDerivedClassC3fooyyF
// NM-NOT: $s4main14MyDerivedClassC3baryyF
// NM:     $s4main7MyClassC3fooyyF
// NM-NOT: $s4main7MyClassC3baryyF
// NM:     $s4main8MyStructV8protofooyyF
// NM-NOT: $s4main8MyStructV8protobaryyF
