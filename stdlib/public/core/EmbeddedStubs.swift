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

/// SwiftStdlibVersion

public typealias _SwiftStdlibVersion = SwiftShims._SwiftStdlibVersion

@available(_embedded, unavailable)
internal func _isExecutableLinkedOnOrAfter(_ stdlibVersion: _SwiftStdlibVersion) -> Bool { fatalError() }

/// String

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
  public static func + (lhs: String, rhs: String) -> String { fatalError() }
  public static func += (lhs: inout String, rhs: String) { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  public var isContiguousUTF8: Bool { fatalError() }
  public mutating func makeContiguousUTF8() { fatalError() }
  public mutating func withUTF8<R>(_ body: (UnsafeBufferPointer<UInt8>) throws -> R) rethrows -> R { fatalError() }
  public var utf8: ContiguousArray<UInt8> { fatalError() }
  public var utf16: ContiguousArray<UInt16> { fatalError() }
  public var debugDescription: String { fatalError() }
}

@available(_embedded, unavailable)
public func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") { fatalError() }

@available(_embedded, unavailable)
public func debugPrint<Target: TextOutputStream>(_ items: Any..., separator: String = " ", terminator: String = "\n", to output: inout Target) { fatalError() }

@available(_embedded, unavailable)
extension String: TextOutputStream {
  public mutating func write(_ other: String) { fatalError() }
  public mutating func _writeASCII(_ buffer: UnsafeBufferPointer<UInt8>) { fatalError() }
}

@available(_embedded, unavailable)
extension String: _ExpressibleByBuiltinUnicodeScalarLiteral {
  public init(_builtinUnicodeScalarLiteral value: Builtin.Int32) { fatalError() }
  public init(_ scalar: UInt32) { fatalError() }
}

@available(_embedded, unavailable)
extension String: _ExpressibleByBuiltinExtendedGraphemeClusterLiteral {
  public init(_builtinExtendedGraphemeClusterLiteral start: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) { fatalError() }
}

@available(_embedded, unavailable)
extension String: _ExpressibleByBuiltinStringLiteral {
  public init(_builtinStringLiteral start: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) { fatalError() }
}

@available(_embedded, unavailable)
extension String: ExpressibleByStringLiteral {
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
  public mutating func appendInterpolation<T>(_: T) { fatalError() }

  internal __consuming func make() -> String { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  @inlinable
  @_effects(readonly)
  public init(stringInterpolation: DefaultStringInterpolation) { fatalError() }
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
  public mutating func _writeASCII(_ buffer: UnsafeBufferPointer<UInt8>) {}
}

@available(_embedded, unavailable)
public protocol TextOutputStreamable {
  func write<Target: TextOutputStream>(to target: inout Target)
}

@available(_embedded, unavailable)
extension String {
  internal static func _fromUTF8Repairing(_ input: UnsafeBufferPointer<UInt8>) -> (result: String, repairsMade: Bool) { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  internal static func _fromASCII(_ input: UnsafeBufferPointer<UInt8>) -> String { fatalError() }
  internal static func _uncheckedFromUTF8( _ input: UnsafeBufferPointer<UInt8>) -> String { fatalError() }
  internal static func _uncheckedFromUTF8(_ input: UnsafeBufferPointer<UInt8>, isASCII: Bool) -> String { fatalError() }
  internal static func _uncheckedFromUTF8(_ input: UnsafeBufferPointer<UInt8>, asciiPreScanResult: Bool) -> String { fatalError() }
}

@available(_embedded, unavailable)
extension String {
  public init<T: BinaryInteger>(_ value: T, radix: Int = 10, uppercase: Bool = false) { fatalError() }
}

/// Unicode.Scalar

public enum Unicode {}

extension Unicode {
  public struct Scalar: Sendable {
    internal var _value: UInt32
    internal init(_value: UInt32) {
      self._value = _value
    }
  }
}

extension Unicode.Scalar : _ExpressibleByBuiltinUnicodeScalarLiteral, ExpressibleByUnicodeScalarLiteral {
  public var value: UInt32 { return _value }
  public init(_builtinUnicodeScalarLiteral value: Builtin.Int32) {
    self._value = UInt32(value)
  }
  public init(unicodeScalarLiteral value: Unicode.Scalar) {
    self = value
  }
  public init?(_ v: UInt32) {
    if (v < 0xD800 || v > 0xDFFF) && v <= 0x10FFFF {
      self._value = v
      return
    }
    return nil
  }
  public init?(_ v: UInt16) {
    self.init(UInt32(v))
  }
  public init(_ v: UInt8) {
    self._value = UInt32(v)
  }
  public init(_ v: Unicode.Scalar) {
    self = v
  }
  @available(_embedded, unavailable)
  public func escaped(asASCII forceASCII: Bool) -> String { fatalError() }
  @available(_embedded, unavailable)
  internal func _escaped(asASCII forceASCII: Bool) -> String? { fatalError() }
  public var isASCII: Bool {
    return value <= 127
  }
  internal var _isPrintableASCII: Bool {
    return (self >= Unicode.Scalar(0o040) && self <= Unicode.Scalar(0o176))
  }
}

extension Unicode.Scalar: Equatable {
  public static func == (lhs: Unicode.Scalar, rhs: Unicode.Scalar) -> Bool {
    return lhs.value == rhs.value
  }
}

extension Unicode.Scalar: Comparable {
  public static func < (lhs: Unicode.Scalar, rhs: Unicode.Scalar) -> Bool {
    return lhs.value < rhs.value
  }
}

public typealias UTF8 = Unicode.UTF8

extension Unicode {
  public enum UTF8 {
  }
}

extension Unicode.UTF8 {
  public typealias CodeUnit = UInt8
}

/// Codable

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
  public struct Context: Sendable {
    public let codingPath: [any CodingKey]

    public let debugDescription: String

    public let underlyingError: Error?

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
  case typeMismatch(Any.Type, Context)
  case valueNotFound(Any.Type, Context)
  case keyNotFound(any CodingKey, Context)
  case dataCorrupted(Context)
}

/// Identifiable

@available(_embedded, unavailable)
public protocol Identifiable<ID> {
  associatedtype ID: Hashable
  var id: ID { get }
}

/// RandomNumberGenerator

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

/// KeyPath

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
