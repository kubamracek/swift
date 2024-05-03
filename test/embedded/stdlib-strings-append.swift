// RUN: %target-run-simple-swift(-enable-experimental-feature Embedded -parse-as-library -runtime-compatibility-version none -wmo -Xfrontend -enable-strings) | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: optimized_stdlib
// REQUIRES: VENDOR=apple
// REQUIRES: OS=macosx

@main
struct Main {
  static func main() {
    var str = "hello "
    for _ in 0 ..< 4 { str = str + str }
    print(str)
  }
}

// CHECK: hello hello hello hello hello hello hello hello hello hello hello hello hello hello hello hello 
