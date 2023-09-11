# Embedded runtime
set(EMBEDDED_ARCHS armv7 arm64)
foreach(arch ${EMBEDDED_ARCHS})
  message(${arch})
  set(SWIFT_ENABLE_REFLECTION OFF)
  set(SWIFT_STDLIB_SUPPORT_BACK_DEPLOYMENT OFF)
  set(SWIFT_STDLIB_STABLE_ABI OFF)
  set(SWIFT_STDLIB_ENABLE_OBJC_INTEROP OFF)
  set(SWIFT_SDK_embedded_ARCH_${arch}_MODULE "${arch}-apple-none-macho")

  add_swift_target_library_single(
    embedded-runtime-${arch}
    swiftRuntimeEmbedded
    STATIC
    IS_STDLIB

    Heap.swift
    RefCounting.swift

    SWIFT_COMPILE_FLAGS
                -target "${arch}-apple-none-macho" -Xcc -D__MACH__
                -enable-experimental-feature Embedded
                -enable-experimental-feature SymbolLinkageMarkers

    MODULE_DIR "${CMAKE_BINARY_DIR}/lib/swift/embedded"
    SDK "embedded"
    ARCHITECTURE "${arch}"
    INSTALL_IN_COMPONENT "never_install"
    )
endforeach()

add_custom_target(embedded-runtime)
foreach(arch ${EMBEDDED_ARCHS})
  add_dependencies(embedded-runtime embedded-runtime-${arch})
endforeach()
