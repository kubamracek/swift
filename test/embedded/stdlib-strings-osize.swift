// RUN: %empty-directory(%t)

// RUN: %target-swift-frontend %s -parse-as-library -enable-experimental-feature Embedded -c -o %t/main.o -Osize -enable-strings
// RUN: %target-clang %t/main.o -o %t/a.out -dead_strip -Wl,-map,%t/a.out.map
// RUN: %target-run %t/a.out | %FileCheck %s
// RUN: dsymutil %t/a.out

// REQUIRES: executable_test
// REQUIRES: optimized_stdlib
// REQUIRES: VENDOR=apple
// REQUIRES: OS=macosx

@main
struct Main {
  static func main() {
    let str = "Hello Hello This Is A Long String"
    print(str)
    print(str.uppercased())
    for word in str.split(separator: " ") {
      print(word.lowercased())
    }
  }
}

// CHECK: Hello Hello This Is A Long String
// CHECK: HELLO HELLO THIS IS A LONG STRING
// CHECK: hello
// CHECK: hello
// CHECK: this
// CHECK: is
// CHECK: a
// CHECK: long
// CHECK: string
