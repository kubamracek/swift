// RUN: %target-run-simple-swift
// REQUIRES: executable_test

import Darwin

let x = 5
let y : Int = x
if let z = y as? AnyHashable {
  exit(0)
} else {
  exit(1)
}
