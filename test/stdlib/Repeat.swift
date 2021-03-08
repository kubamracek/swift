// RUN: %target-run-simple-swift(-g)
// REQUIRES: executable_test

import StdlibUnittest

let RepeatTests = TestSuite("Repeated")
RepeatTests.test("repeatElement") {
  let sequence = repeatElement(1, count: 5)
  expectEqual(sequence.count, 5)
  expectEqualSequence(sequence, [1, 1, 1, 1, 1])
  expectEqual(sequence.startIndex, 0)
  expectEqual(sequence.endIndex, 5)
  expectEqual(sequence[0], 1)
}

RepeatTests.test("associated-types") {
  typealias Subject = Repeated<String>
  expectRandomAccessCollectionAssociatedTypes(
      collectionType: Subject.self,
      iteratorType: IndexingIterator<Subject>.self,
      subSequenceType: Slice<Subject>.self,
      indexType: Int.self,
      indicesType: CountableRange<Int>.self)
}

RepeatTests.test("out-of-bounds") {
  let sequence = repeatElement(0, count: 1)
  expectCrashLater()
  _ = sequence[sequence.count]
}

runAllTests()

/*
public protocol SequenceX {
  associatedtype Element
  func count() -> Int
  func get(index: Int) -> Element
}

public struct ArrayX: SequenceX {
  public typealias Element = Int
  public func count() -> Int { return 5 }
  public func get(index: Int) -> Int { return 5 }
}

extension SequenceX where Element: Equatable {
  public func containsX(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    for i in 0 ..< count() {
      if try predicate(get(index: i)) {
        return true
      }
    }
    return false
  }
  
  public func containsX(_ element: Element) -> Bool {
    return self.containsX { $0 == element }
  }
}
let sequence: ArrayX = ArrayX()
_ = sequence.containsX(7)
*/
/*
let sequence = ["a", "b"]
_ = sequence.contains("c")
_ = sequence.contains("c")
_ = sequence.contains("c")
*/
/*
public protocol IteratorProtocolX {
  associatedtype Element
  mutating func next() -> Element?
}

public protocol SequenceX {
  associatedtype Element
  associatedtype Iterator: IteratorProtocolX where Iterator.Element == Element
  func count() -> Int
  func get(index: Int) -> Element
  func iter() -> Iterator
}

public struct ArrayIteratorX: IteratorProtocolX {
  public typealias Element = String
  var count = 5
  public mutating func next() -> String? { count -= 1 ; return count == 0 ? nil : "aaa" }
}

public struct ArrayX: SequenceX {
  public typealias Element = String
  public typealias Iterator = ArrayIteratorX
  public func count() -> Int { return 5 }
  public func get(index: Int) -> String { return "x" }
  public func iter() -> ArrayIteratorX { return ArrayIteratorX() }
}

extension SequenceX where Element: Equatable {
  public func containsX(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    var i = iter()
    while let e = i.next() {
      if try predicate(e) {
        return true
      }
    }
    return false
  }
  
  public func containsX(_ element: Element) -> Bool {
    return self.containsX { $0 == element }
  }
}

let sequence = ArrayX()
_ = sequence.containsX("abc")
*/
