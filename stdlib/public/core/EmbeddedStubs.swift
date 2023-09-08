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
internal func _isExecutableLinkedOnOrAfter(
  _ stdlibVersion: _SwiftStdlibVersion
) -> Bool {
  fatalError()
}

@available(_embedded, unavailable)
public struct String: Hashable { 
    public var utf8CString: ContiguousArray<CChar> { fatalError() }
    public init() {}
}

@available(_embedded, unavailable)
extension String {
  public init<Subject>(describing instance: Subject) { fatalError() }

  public init<Subject>(reflecting instance: Subject) { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  public static func + (lhs: String, rhs: String) -> String  { fatalError() }

  public static func += (lhs: inout String, rhs: String) { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  public var isContiguousUTF8: Bool { fatalError() }
  public mutating func makeContiguousUTF8() {
    fatalError()
  }
  public mutating func withUTF8<R>(
    _ body: (UnsafeBufferPointer<UInt8>) throws -> R
  ) rethrows -> R {
    fatalError()
  }

  public var utf8: ContiguousArray<UInt8> { fatalError() }

  public var debugDescription: String { fatalError() }
}

@available(_embedded, unavailable)
internal func _rawPointerToString(_ value: Builtin.RawPointer) -> String {
  fatalError()
}

@available(_embedded, unavailable)
public func debugPrint(
  _ items: Any...,
  separator: String = " ",
  terminator: String = "\n"
) {
  fatalError()
}

@available(_embedded, unavailable)
public func debugPrint<Target: TextOutputStream>(
  _ items: Any...,
  separator: String = " ",
  terminator: String = "\n",
  to output: inout Target
) {
  fatalError()
}

@available(_embedded, unavailable)
extension String: TextOutputStream {
  public mutating func write(_ other: String) {
    fatalError()
  }

  public mutating func _writeASCII(_ buffer: UnsafeBufferPointer<UInt8>) {
    fatalError()
  }
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

extension Unicode.Scalar: Equatable {
  @inlinable
  public static func == (lhs: Unicode.Scalar, rhs: Unicode.Scalar) -> Bool {
    return lhs.value == rhs.value
  }
}

extension Unicode.Scalar: Comparable {
  @inlinable
  public static func < (lhs: Unicode.Scalar, rhs: Unicode.Scalar) -> Bool {
    return lhs.value < rhs.value
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
public protocol CodingKey: Sendable,
                           CustomStringConvertible,
                           CustomDebugStringConvertible {
  var stringValue: String { get }
  init?(stringValue: String)
  var intValue: Int? { get }
  init?(intValue: Int)
}

@available(_embedded, unavailable)
public struct KeyedDecodingContainer<K: CodingKey> { }

@available(_embedded, unavailable)
public struct KeyedEncodingContainer<K: CodingKey> { }

@available(_embedded, unavailable)
public protocol UnkeyedDecodingContainer { 
  mutating func decode<T>(_ type: T.Type) throws -> T
}

@available(_embedded, unavailable)
public protocol UnkeyedEncodingContainer { 
  mutating func encode<T>(_ value: T) throws
}

@available(_embedded, unavailable)
public protocol SingleValueDecodingContainer { }

@available(_embedded, unavailable)
public protocol SingleValueEncodingContainer { }

@available(_embedded, unavailable)
public protocol Encoder {
  var codingPath: [any CodingKey] { get }
  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
  func unkeyedContainer() -> any UnkeyedEncodingContainer
  func singleValueContainer() -> any SingleValueEncodingContainer
}

@available(_embedded, unavailable)
public protocol Decoder {
  var codingPath: [any CodingKey] { get }
  func container<Key>(
    keyedBy type: Key.Type
  ) throws -> KeyedDecodingContainer<Key>
  func unkeyedContainer() throws -> any UnkeyedDecodingContainer
  func singleValueContainer() throws -> any SingleValueDecodingContainer
}

@available(_embedded, unavailable)
public enum DecodingError: Error {
  /// The context in which the error occurred.
  public struct Context: Sendable {
    /// The path of coding keys taken to get to the point of the failing decode
    /// call.
    public let codingPath: [any CodingKey]

    /// A description of what went wrong, for debugging purposes.
    public let debugDescription: String

    /// The underlying error which caused this error, if any.
    public let underlyingError: Error?

    /// Creates a new context with the given path of coding keys and a
    /// description of what went wrong.
    ///
    /// - parameter codingPath: The path of coding keys taken to get to the
    ///   point of the failing decode call.
    /// - parameter debugDescription: A description of what went wrong, for
    ///   debugging purposes.
    /// - parameter underlyingError: The underlying error which caused this
    ///   error, if any.
    public init(
      codingPath: [any CodingKey],
      debugDescription: String,
      underlyingError: Error? = nil
    ) {
      self.codingPath = codingPath
      self.debugDescription = debugDescription
      self.underlyingError = underlyingError
    }
  }

  /// An indication that a value of the given type could not be decoded because
  /// it did not match the type of what was found in the encoded payload.
  ///
  /// As associated values, this case contains the attempted type and context
  /// for debugging.
  case typeMismatch(Any.Type, Context)

  /// An indication that a non-optional value of the given type was expected,
  /// but a null value was found.
  ///
  /// As associated values, this case contains the attempted type and context
  /// for debugging.
  case valueNotFound(Any.Type, Context)

  /// An indication that a keyed decoding container was asked for an entry for
  /// the given key, but did not contain one.
  ///
  /// As associated values, this case contains the attempted key and context
  /// for debugging.
  case keyNotFound(any CodingKey, Context)

  /// An indication that the data is corrupted or otherwise invalid.
  ///
  /// As an associated value, this case contains the context for debugging.
  case dataCorrupted(Context)
}

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

@available(_embedded, unavailable)
internal func _int64ToString(
  _ value: Int64,
  radix: Int64 = 10,
  uppercase: Bool = false
) -> String {
  fatalError()
}

@available(_embedded, unavailable)
internal func _float64ToString(
  _ value: Float64,
  debug: Bool
) -> (buffer: _Buffer32, length: Int) {
  fatalError()
}

@available(_embedded, unavailable)
internal func _float16ToString(
  _ value: Float16,
  debug: Bool
) -> (buffer: _Buffer32, length: Int) {
  fatalError()
}

internal func _float32ToString(
  _ value: Float32,
  debug: Bool
) -> (buffer: _Buffer32, length: Int) {
  fatalError()
}

@available(_embedded, unavailable)
public // @testable
func _uint64ToString(
    _ value: UInt64,
    radix: Int64 = 10,
    uppercase: Bool = false
) -> String {
  fatalError()
}

@available(_embedded, unavailable)
extension String {
  @usableFromInline
  internal static func _fromUTF8Repairing(
    _ input: UnsafeBufferPointer<UInt8>
  ) -> (result: String, repairsMade: Bool) { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  internal static func _fromASCII(
    _ input: UnsafeBufferPointer<UInt8>
  ) -> String {
    fatalError()
  }

  @usableFromInline
  internal static func _uncheckedFromUTF8(
    _ input: UnsafeBufferPointer<UInt8>
  ) -> String {
    fatalError()
  }

  @usableFromInline
  internal static func _uncheckedFromUTF8(
    _ input: UnsafeBufferPointer<UInt8>,
    isASCII: Bool
  ) -> String {
    fatalError()
  }

  // If we've already pre-scanned for ASCII, just supply the result
  @usableFromInline
  internal static func _uncheckedFromUTF8(
    _ input: UnsafeBufferPointer<UInt8>, asciiPreScanResult: Bool
  ) -> String {
    fatalError()
  }

}

/// A 32 byte buffer.
internal struct _Buffer32 {
  internal var _x0: UInt8 = 0
  internal var _x1: UInt8 = 0
  internal var _x2: UInt8 = 0
  internal var _x3: UInt8 = 0
  internal var _x4: UInt8 = 0
  internal var _x5: UInt8 = 0
  internal var _x6: UInt8 = 0
  internal var _x7: UInt8 = 0
  internal var _x8: UInt8 = 0
  internal var _x9: UInt8 = 0
  internal var _x10: UInt8 = 0
  internal var _x11: UInt8 = 0
  internal var _x12: UInt8 = 0
  internal var _x13: UInt8 = 0
  internal var _x14: UInt8 = 0
  internal var _x15: UInt8 = 0
  internal var _x16: UInt8 = 0
  internal var _x17: UInt8 = 0
  internal var _x18: UInt8 = 0
  internal var _x19: UInt8 = 0
  internal var _x20: UInt8 = 0
  internal var _x21: UInt8 = 0
  internal var _x22: UInt8 = 0
  internal var _x23: UInt8 = 0
  internal var _x24: UInt8 = 0
  internal var _x25: UInt8 = 0
  internal var _x26: UInt8 = 0
  internal var _x27: UInt8 = 0
  internal var _x28: UInt8 = 0
  internal var _x29: UInt8 = 0
  internal var _x30: UInt8 = 0
  internal var _x31: UInt8 = 0

  internal init() {}

  internal mutating func withBytes<Result>(
    _ body: (UnsafeMutablePointer<UInt8>) throws -> Result
  ) rethrows -> Result {
    return try withUnsafeMutablePointer(to: &self) {
      try body(UnsafeMutableRawPointer($0).assumingMemoryBound(to: UInt8.self))
    }
  }
}

@available(_embedded, unavailable)
extension String {
  public init<T: BinaryInteger>(
    _ value: T, radix: Int = 10, uppercase: Bool = false
  ) {
    fatalError()
  }
}
