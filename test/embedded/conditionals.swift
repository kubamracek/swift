// RUN: %target-swift-emit-ir %s -parse-stdlib | %FileCheck %s
// RUN: %target-swift-emit-ir %s -parse-stdlib -enable-experimental-feature Embedded | %FileCheck %s --check-prefix EMBEDDED

#if _mode(_Embedded)
public func embedded() { }
#else
public func regular() { }
#endif

// CHECK:    define swiftcc void @"$s12conditionals7regularyyF"()
// EMBEDDED: define swiftcc void @"$s12conditionals8embeddedyyF"()
