//===--- SwiftStdint.h ------------------------------------------*- C++ -*-===//
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

#ifndef SWIFT_STDLIB_SHIMS_SWIFT_STDINT_H
#define SWIFT_STDLIB_SHIMS_SWIFT_STDINT_H

// stdint.h is provided by Clang, but it dispatches to libc's stdint.h.  As a
// result, using stdint.h here would pull in Darwin module (which includes
// libc). This creates a dependency cycle, so we can't use stdint.h in
// SwiftShims.
// On Linux, the story is different. We get the error message
// "/usr/include/x86_64-linux-gnu/sys/types.h:146:10: error: 'stddef.h' file not
// found"
// This is a known Clang/Ubuntu bug.

// Clang has been defining __INTxx_TYPE__ macros for a long time.
// __UINTxx_TYPE__ are defined only since Clang 3.5.
#if !defined(__APPLE__) && !defined(__linux__) && !defined(__OpenBSD__) && !defined(__wasi__) && __STDC_HOSTED__
#include <stdint.h>
typedef int64_t __swift_int64_t;
typedef uint64_t __swift_uint64_t;
typedef int32_t __swift_int32_t;
typedef uint32_t __swift_uint32_t;
typedef int16_t __swift_int16_t;
typedef uint16_t __swift_uint16_t;
typedef int8_t __swift_int8_t;
typedef uint8_t __swift_uint8_t;
typedef intptr_t __swift_intptr_t;
typedef uintptr_t __swift_uintptr_t;
#define __swift_int64_max INT64_MAX
#define __swift_uint64_max UINT64_MAX
#define __swift_int32_max INT32_MAX
#define __swift_uint32_max UINT32_MAX
#define __swift_int16_max INT16_MAX
#define __swift_uint16_max UINT16_MAX
#define __swift_int8_max INT8_MAX
#define __swift_uint8_max UINT8_MAX
#define __swift_intptr_max INTPTR_MAX
#define __swift_uintptr_max UINTPTR_MAX
#else
typedef __INT64_TYPE__ __swift_int64_t;
#ifdef __UINT64_TYPE__
typedef __UINT64_TYPE__ __swift_uint64_t;
#else
typedef unsigned __INT64_TYPE__ __swift_uint64_t;
#endif
#define __swift_int64_max __INT64_MAX__
#define __swift_uint64_max __UINT64_MAX__

typedef __INT32_TYPE__ __swift_int32_t;
#ifdef __UINT32_TYPE__
typedef __UINT32_TYPE__ __swift_uint32_t;
#else
typedef unsigned __INT32_TYPE__ __swift_uint32_t;
#endif
#define __swift_int32_max __INT32_MAX__
#define __swift_uint32_max __UINT32_MAX__

typedef __INT16_TYPE__ __swift_int16_t;
#ifdef __UINT16_TYPE__
typedef __UINT16_TYPE__ __swift_uint16_t;
#else
typedef unsigned __INT16_TYPE__ __swift_uint16_t;
#endif
#define __swift_int16_max __INT16_MAX__
#define __swift_uint16_max __UINT16_MAX__

typedef __INT8_TYPE__ __swift_int8_t;
#ifdef __UINT8_TYPE__
typedef __UINT8_TYPE__ __swift_uint8_t;
#else
typedef unsigned __INT8_TYPE__ __swift_uint8_t;
#endif
#define __swift_int8_max __INT8_MAX__
#define __swift_uint8_max __UINT8_MAX__

#define __swift_join3(a,b,c) a ## b ## c

#define __swift_intn_t(n) __swift_join3(__swift_int, n, _t)
#define __swift_uintn_t(n) __swift_join3(__swift_uint, n, _t)
#define __swift_intn_max(n) __swift_join3(__swift_int, n, _max)
#define __swift_uintn_max(n) __swift_join3(__swift_uint, n, _max)

#if defined(_MSC_VER) && !defined(__clang__)
#if defined(_WIN64)
typedef __swift_int64_t __swift_intptr_t;
typedef __swift_uint64_t __swift_uintptr_t;
#define __swift_intptr_max __swift_int64_max
#define __swift_uintptr_max __swift_uint64_max
#elif defined(_WIN32)
typedef __swift_int32_t __swift_intptr_t;
typedef __swift_uint32_t __swift_uintptr_t;
#define __swift_intptr_max __swift_int32_max
#define __swift_uintptr_max __swift_uint32_max
#else
#error unknown windows pointer width
#endif
#else
typedef __swift_intn_t(__INTPTR_WIDTH__) __swift_intptr_t;
typedef __swift_uintn_t(__INTPTR_WIDTH__) __swift_uintptr_t;
#define __swift_intptr_max __swift_intn_max(__INTPTR_WIDTH__)
#define __swift_uintptr_max __swift_uintn_max(__INTPTR_WIDTH__)
#endif
#endif

#endif // SWIFT_STDLIB_SHIMS_SWIFT_STDINT_H
