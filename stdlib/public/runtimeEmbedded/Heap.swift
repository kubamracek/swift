let _swift_MinAllocationAlignment: UInt = 16

@_silgen_name("posix_memalign")
func posix_memalign(_: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _: UInt, _: UInt) -> CInt

@_silgen_name("free")
func free(_: UnsafeMutableRawPointer?)

func alignedAlloc(size: UInt, alignment: UInt) -> UnsafeMutableRawPointer? {
  let alignment = max(alignment, UInt(MemoryLayout<UnsafeRawPointer>.size))
  var r: UnsafeMutableRawPointer? = nil
  _ = posix_memalign(&r, alignment, size)
  return r
}

/// Public APIs

// void *swift_slowAlloc(size_t size, size_t alignMask);
@_cdecl("swift_slowAlloc")
public func swift_slowAlloc(_ size: UInt, _ alignMask: UInt) -> UnsafeMutableRawPointer? {
  let alignment: UInt
  if alignMask == UInt.max {
    alignment = _swift_MinAllocationAlignment
  } else {
    alignment = alignMask + 1
  }
  return alignedAlloc(size: size, alignment: alignment)
}

// void swift_slowDealloc(void *ptr, size_t bytes, size_t alignMask);
@_cdecl("swift_slowDealloc")
public func swift_slowDealloc(_ ptr: UnsafeMutableRawPointer?, _ size: UInt, _ alignMask: UInt) {
  free(ptr)
}
