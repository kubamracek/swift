// RUN: %target-run-simple-swift(   -enable-experimental-feature Embedded -wmo -Xfrontend -disable-access-control -runtime-compatibility-version none) | %FileCheck %s
// RUN: %target-run-simple-swift(-O -enable-experimental-feature Embedded -wmo -Xfrontend -disable-access-control -runtime-compatibility-version none) | %FileCheck %s

// REQUIRES: swift_in_compiler
// REQUIRES: executable_test
// REQUIRES: optimized_stdlib
// REQUIRES: OS=macosx || OS=linux-gnu

struct MyStruct {
  var x: Int
  var y: Int
  var z: Int
}

var d: [KeyPath<MyStruct, Int>] = []
d.append(\MyStruct.x)
d.append(\MyStruct.y)
d.append(\MyStruct.z)

var s = MyStruct(x: 10, y: 20, z: 30)
for kp in d {
  print(s[keyPath: kp])
}
// CHECK: 10
// CHECK: 20
// CHECK: 30
