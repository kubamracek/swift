//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SwiftShims

public typealias _SwiftStdlibVersion = SwiftShims._SwiftStdlibVersion

@available(_embedded, unavailable)
public struct String: Hashable { 
    public var utf8CString: ContiguousArray<CChar> { fatalError() }
    public init() {}
}

public enum Unicode {}

extension Unicode {
  @frozen
  public struct Scalar: Sendable {
    @usableFromInline
    internal var _value: UInt32

    @inlinable
    internal init(_value: UInt32) {
      self._value = _value
    }
  }
}

extension Unicode.Scalar :
    _ExpressibleByBuiltinUnicodeScalarLiteral,
    ExpressibleByUnicodeScalarLiteral {
  /// A numeric representation of the Unicode scalar.
  @inlinable
  public var value: UInt32 { return _value }

  @_transparent
  public init(_builtinUnicodeScalarLiteral value: Builtin.Int32) {
    self._value = UInt32(value)
  }

  @_transparent
  public init(unicodeScalarLiteral value: Unicode.Scalar) {
    self = value
  }

  @inlinable
  public init?(_ v: UInt32) {
    if (v < 0xD800 || v > 0xDFFF) && v <= 0x10FFFF {
      self._value = v
      return
    }
    return nil
  }

  @inlinable
  public init?(_ v: UInt16) {
    self.init(UInt32(v))
  }

  @inlinable
  public init(_ v: UInt8) {
    self._value = UInt32(v)
  }

  @inlinable
  public init(_ v: Unicode.Scalar) {
    self = v
  }

  @available(_embedded, unavailable)
  public func escaped(asASCII forceASCII: Bool) -> String {
    fatalError()
  }

  @available(_embedded, unavailable)
  internal func _escaped(asASCII forceASCII: Bool) -> String? {
    fatalError()
  }

  @inlinable
  public var isASCII: Bool {
    return value <= 127
  }

  internal var _isPrintableASCII: Bool {
    return (self >= Unicode.Scalar(0o040) && self <= Unicode.Scalar(0o176))
  }
}


// Access the underlying code units
extension Unicode.Scalar {
  // Access the scalar as encoded in UTF-16
  internal func withUTF16CodeUnits<Result>(
    _ body: (UnsafeBufferPointer<UInt16>) throws -> Result
  ) rethrows -> Result {
    fatalError()
  }

  // Access the scalar as encoded in UTF-8
  @inlinable
  internal func withUTF8CodeUnits<Result>(
    _ body: (UnsafeBufferPointer<UInt8>) throws -> Result
  ) rethrows -> Result {
    fatalError()
  }
}

@available(_embedded, unavailable)
extension String: _ExpressibleByBuiltinUnicodeScalarLiteral {
  @_effects(readonly)
  @inlinable @inline(__always)
  public init(_builtinUnicodeScalarLiteral value: Builtin.Int32) { fatalError() }

  @inlinable @inline(__always)
  public init(_ scalar: UInt32) { fatalError() }
}

@available(_embedded, unavailable)
extension String: _ExpressibleByBuiltinExtendedGraphemeClusterLiteral {
  @inlinable @inline(__always)
  @_effects(readonly) @_semantics("string.makeUTF8")
  public init(
    _builtinExtendedGraphemeClusterLiteral start: Builtin.RawPointer,
    utf8CodeUnitCount: Builtin.Word,
    isASCII: Builtin.Int1
  )  { fatalError() }
}

@available(_embedded, unavailable)
extension String: _ExpressibleByBuiltinStringLiteral {
  @inlinable @inline(__always)
  @_effects(readonly) @_semantics("string.makeUTF8")
  public init(
    _builtinStringLiteral start: Builtin.RawPointer,
    utf8CodeUnitCount: Builtin.Word,
    isASCII: Builtin.Int1
    )  { fatalError() }
}

@available(_embedded, unavailable)
extension String: ExpressibleByStringLiteral {
  @inlinable @inline(__always)
  public init(stringLiteral value: String) { fatalError() }
}

@available(_embedded, unavailable)
public protocol CustomStringConvertible {
 var description: String { get }
}

@available(_embedded, unavailable)
public protocol CustomDebugStringConvertible {
  var debugDescription: String { get }
}

@available(_embedded, unavailable)
public struct DefaultStringInterpolation: StringInterpolationProtocol, Sendable {
  public typealias StringLiteralType = String

  public init(literalCapacity: Int, interpolationCount: Int) { fatalError() }
  public mutating func appendLiteral(_ literal: StringLiteralType) { fatalError() }
  public mutating func appendInterpolation<T>(_: T)  { fatalError() }

  internal __consuming func make() -> String {
    fatalError()
  }
}

@available(_embedded, unavailable)
extension String {
  @inlinable
  @_effects(readonly)
  public init(stringInterpolation: DefaultStringInterpolation) {
    fatalError()
  }
}

@available(_embedded, unavailable)
public protocol LosslessStringConvertible: CustomStringConvertible {
  init?(_ description: String)
}

@available(_embedded, unavailable)
public protocol TextOutputStream {
  mutating func _lock()
  mutating func _unlock()
  mutating func write(_ string: String)
  mutating func _writeASCII(_ buffer: UnsafeBufferPointer<UInt8>)
}

@available(_embedded, unavailable)
extension TextOutputStream {
  public mutating func _lock() {}
  public mutating func _unlock() {}

  public mutating func _writeASCII(_ buffer: UnsafeBufferPointer<UInt8>) {
    write(String._fromASCII(buffer))
  }
}

@available(_embedded, unavailable)
public protocol TextOutputStreamable {
  func write<Target: TextOutputStream>(to target: inout Target)
}

@available(_embedded, unavailable)
public protocol Encodable {
  func encode(to encoder: any Encoder) throws
}

@available(_embedded, unavailable)
public protocol Decodable {
  init(from decoder: any Decoder) throws
}

@available(_embedded, unavailable)
public typealias Codable = Encodable & Decodable

@available(_embedded, unavailable)
public protocol Encoder { }

@available(_embedded, unavailable)
public protocol Decoder { }

@available(_embedded, unavailable)
public protocol Identifiable<ID> {
  associatedtype ID: Hashable
  var id: ID { get }
}

@available(_embedded, unavailable)
public protocol RandomNumberGenerator { 
    mutating func next() -> UInt64
}

@available(_embedded, unavailable)
extension RandomNumberGenerator {
  @inlinable
  public mutating func next<T: FixedWidthInteger & UnsignedInteger>(
    upperBound: T
  ) -> T { fatalError() }
}

@available(_embedded, unavailable)
public struct SystemRandomNumberGenerator: RandomNumberGenerator, Sendable {
    @inlinable
    public init() { }

    public mutating func next() -> UInt64 { fatalError() }
}

@available(_embedded, unavailable)
public class AnyKeyPath {
  @usableFromInline
  internal var _storedInlineOffset: Int? { fatalError() }
}

@available(_embedded, unavailable)
public class PartialKeyPath<Root>: AnyKeyPath { }

@available(_embedded, unavailable)
public class KeyPath<Root, Value>: PartialKeyPath<Root> { }

@available(_embedded, unavailable)
public class WritableKeyPath<Root, Value>: KeyPath<Root, Value> { }
