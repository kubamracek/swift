// TODO: description

// REQUIRES: OS=macosx
// REQUIRES: executable_test

// RUN: rm %t-commonflags
// RUN: echo "-target x86_64-apple-macos11.0 -swift-version 5 -parse-as-library -working-directory %t -Xfrontend -emit-dead-strippable-symbols" >> %t-commonflags
// RUN: echo "-Xlinker -lto_library -Xlinker /Users/kuba/swift-github-main/build/Ninja-RelWithDebInfoAssert/llvm-macosx-arm64/lib/libLTO.dylib" >> %t-commonflags

// RUN: %empty-directory(%t)
// RUN: %target-swiftc_driver @%t-commonflags %s -module-name Library -emit-module     -o %t/Library.swiftmodule -emit-tbd -emit-tbd-path %t/libLibrary.tbd -Xfrontend -tbd-install_name -Xfrontend "%t/libLibrary.dylib" -lto=llvm-full -DLIBRARY
// RUN: %target-swiftc_driver @%t-commonflags %s -module-name Main -I%t -L%t -lLibrary -o %t/main                -lto=llvm-full -DCLIENT

// Now produce the .dylib with just the symbols needed by the client
// RUN: %llvm-nm --undefined-only -m %t/main | grep 'from libLibrary' | awk '{print $3}' > %t/used-symbols
// RUN: %target-swiftc_driver @%t-commonflags %s -module-name Library -emit-library    -o %t/libLibrary.dylib    -lto=llvm-full -DLIBRARY -Xlinker -exported_symbols_list -Xlinker %t/used-symbols -Xlinker -dead_strip -Xfrontend -validate-tbd-against-ir=none

// RUN: %llvm-nm --defined-only %t/libLibrary.dylib | %FileCheck %s --check-prefix=NM
// RUN: %target-run %t/main | %FileCheck %s

#if LIBRARY

public class MyClass {
    public init() {}
    public func foo() { print("MyClass.foo") }
    public func bar() { print("MyClass.bar") }
}

public class MyDerivedClass: MyClass {
    override public func foo() { print("MyDerivedClass.foo") }
    override public func bar() { print("MyDerivedClass.bar") }
}

public protocol MyProtocol {
    func protofoo()
    func protobar()
}

public struct MyStruct: MyProtocol {
    public init() {}
    public func protofoo() { print("MyStruct.protofoo") }
    public func protobar() { print("MyStruct.protobar") }
}

public struct MyUnusedStruct: MyProtocol {
    public init() {}
    public func protofoo() { print("MyUnusedStruct.protofoo") }
    public func protobar() { print("MyUnusedStruct.protobar") }
}

// NM:     $s7Library14MyDerivedClassC3fooyyF
// NM-NOT: $s7Library14MyDerivedClassC3baryyF
// NM:     $s7Library7MyClassC3fooyyF
// NM-NOT: $s7Library7MyClassC3baryyF
// NM:     $s7Library8MyStructV8protofooyyF
// NM-NOT: $s7Library8MyStructV8protobaryyF

#endif

#if CLIENT

import Library

@_cdecl("main")
func main() -> Int32 {
    let o: MyClass = MyDerivedClass()
    o.foo()
    let p: MyProtocol = MyStruct()
    p.protofoo()
    print("Done")
    // CHECK: MyDerivedClass.foo
    // CHECK-NEXT: MyStruct.protofoo
    // CHECK-NEXT: Done
    return 0
}

#endif
