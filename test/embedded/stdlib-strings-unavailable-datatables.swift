// RUN: %target-swift-frontend -emit-ir %s -enable-experimental-feature Embedded -enable-strings -verify

// REQUIRES: swift_in_compiler
// REQUIRES: OS=macosx || OS=linux-gnu

public func test1() {
  let string = "string" // ok
  let other = "other" // ok
  let appended = string + other // ok
  _ = appended

  let _ = "aa" == "bb" // error
  let dict: [String:Int] = [:] // error
  _ = dict

  let _ = "aaa".uppercased() // error

  let space: Character = " " // ok
  let split = appended.split(separator: space) // error
  _ = split
}
