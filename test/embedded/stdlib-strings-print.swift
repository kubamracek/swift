// RUN: %target-run-simple-swift(-enable-experimental-feature Embedded -parse-as-library -runtime-compatibility-version none -wmo -Xfrontend -enable-strings) | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: optimized_stdlib
// REQUIRES: VENDOR=apple
// REQUIRES: OS=macosx

@main
struct Main {
  static func main() {
    let str = "Hello Hello This Is A Long String"
    print(str)
  }
}

// CHECK: Hello Hello This Is A Long String
