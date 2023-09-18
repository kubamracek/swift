// Building with regular Swift should succeed
// RUN: %target-swift-emit-ir %s -parse-stdlib

// Building with embedded Swift should produce unavailability errors
// RUN: %target-typecheck-verify-swift -parse-stdlib -enable-experimental-feature Embedded

@available(_embedded, unavailable)
public func embedded() { }
public func regular() {
	embedded() // expected-error {{'embedded()' is unavailable in embedded Swift}}
	// expected-note@-3 {{'embedded()' has been explicitly marked unavailable here}}
}

@available(_embedded, unavailable)
public func unused() { } // no error

@available(_embedded, unavailable)
public func called_from_unavailable() { }
@available(_embedded, unavailable)
public func also_embedded() { 
	called_from_unavailable() // no error
}
