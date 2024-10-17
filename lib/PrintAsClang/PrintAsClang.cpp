//===--- PrintAsClang.cpp - Emit a header file for a Swift AST ------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#include "swift/PrintAsClang/PrintAsClang.h"

#include "ClangSyntaxPrinter.h"
#include "ModuleContentsWriter.h"
#include "SwiftToClangInteropContext.h"

#include "swift/AST/ASTContext.h"
#include "swift/AST/Module.h"
#include "swift/AST/PrettyStackTrace.h"
#include "swift/Basic/Assertions.h"
#include "swift/Basic/Version.h"
#include "swift/ClangImporter/ClangImporter.h"
#include "swift/Frontend/FrontendOptions.h"

#include "clang/Basic/FileManager.h"
#include "clang/Basic/Module.h"
#include "clang/Lex/HeaderSearch.h"

#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/raw_ostream.h"

using namespace swift;

static void emitCxxConditional(raw_ostream &out,
                               llvm::function_ref<void()> cxxCase,
                               llvm::function_ref<void()> cCase = {}) {
  out << "#if defined(__cplusplus)\n";
  cxxCase();
  if (cCase) {
    out << "#else\n";
    cCase();
  }
  out << "#endif\n";
}

static void emitObjCConditional(raw_ostream &out,
                                llvm::function_ref<void()> objcCase,
                                llvm::function_ref<void()> nonObjCCase = {}) {
  out << "#if defined(__OBJC__)\n";
  objcCase();
  if (nonObjCCase) {
    out << "#else\n";
    nonObjCCase();
  }
  out << "#endif\n";
}

static void writePtrauthPrologue(raw_ostream &os, ASTContext &ctx) {
  emitCxxConditional(os, [&]() {
    ClangSyntaxPrinter(ctx, os).printIgnoredDiagnosticBlock(
        "non-modular-include-in-framework-module", [&] {
          os << "#if defined(__arm64e__) && __has_include(<ptrauth.h>)\n";
          os << "# include <ptrauth.h>\n";
          os << "#else\n";
          ClangSyntaxPrinter(ctx, os).printIgnoredDiagnosticBlock(
              "reserved-macro-identifier", [&]() {
                os << "# ifndef "
                      "__ptrauth_swift_value_witness_function_pointer\n";
                os << "#  define "
                      "__ptrauth_swift_value_witness_function_pointer(x)\n";
                os << "# endif\n";
                os << "# ifndef __ptrauth_swift_class_method_pointer\n";
                os << "#  define __ptrauth_swift_class_method_pointer(x)\n";
                os << "# endif\n";
              });
          os << "#endif\n";
        });
  });
}

static void writePrologue(raw_ostream &out, ASTContext &ctx,
                          StringRef macroGuard) {

  out << "// Generated by "
      << version::getSwiftFullVersion(ctx.LangOpts.EffectiveLanguageVersion)
      << "\n"
      // Guard against recursive definition.
      << "#ifndef " << macroGuard << "\n"
      << "#define " << macroGuard
      << "\n"
         "#pragma clang diagnostic push\n"
         "#pragma clang diagnostic ignored \"-Wgcc-compat\"\n"
         "\n"
         "#if !defined(__has_include)\n"
         "# define __has_include(x) 0\n"
         "#endif\n"
         "#if !defined(__has_attribute)\n"
         "# define __has_attribute(x) 0\n"
         "#endif\n"
         "#if !defined(__has_feature)\n"
         "# define __has_feature(x) 0\n"
         "#endif\n"
         "#if !defined(__has_warning)\n"
         "# define __has_warning(x) 0\n"
         "#endif\n"
         "\n"
         "#if __has_include(<swift/objc-prologue.h>)\n"
         "# include <swift/objc-prologue.h>\n"
         "#endif\n"
         "\n"
         "#pragma clang diagnostic ignored \"-Wauto-import\"\n";
  emitObjCConditional(out,
                      [&] { out << "#include <Foundation/Foundation.h>\n"; });
  emitCxxConditional(
      out,
      [&] {
        out << "#include <cstdint>\n"
               "#include <cstddef>\n"
               "#include <cstdbool>\n"
               "#include <cstring>\n";
        out << "#include <stdlib.h>\n";
        out << "#include <new>\n";
        out << "#include <type_traits>\n";
      },
      [&] {
        out << "#include <stdint.h>\n"
               "#include <stddef.h>\n"
               "#include <stdbool.h>\n"
               "#include <string.h>\n";
      });
  writePtrauthPrologue(out, ctx);
  out << "\n"
         "#if !defined(SWIFT_TYPEDEFS)\n"
         "# define SWIFT_TYPEDEFS 1\n"
         "# if __has_include(<uchar.h>)\n"
         "#  include <uchar.h>\n"
         "# elif !defined(__cplusplus)\n"
         "typedef unsigned char char8_t;\n"
         "typedef uint_least16_t char16_t;\n"
         "typedef uint_least32_t char32_t;\n"
         "# endif\n"
#define MAP_SIMD_TYPE(C_TYPE, SCALAR_TYPE, _) \
         "typedef " #SCALAR_TYPE " swift_" #C_TYPE "2"       \
         "  __attribute__((__ext_vector_type__(2)));\n" \
         "typedef " #SCALAR_TYPE " swift_" #C_TYPE "3"       \
         "  __attribute__((__ext_vector_type__(3)));\n" \
         "typedef " #SCALAR_TYPE " swift_" #C_TYPE "4"       \
         "  __attribute__((__ext_vector_type__(4)));\n"
#include "swift/ClangImporter/SIMDMappedTypes.def"
         "#endif\n"
         "\n";

#define CLANG_MACRO_BODY(NAME, BODY) \
  out << "#if !defined(" NAME ")\n" \
         BODY "\n" \
         "#endif\n";

#define CLANG_MACRO(NAME, ARGS, VALUE) CLANG_MACRO_BODY(NAME, "# define " NAME ARGS " " VALUE)

#define CLANG_MACRO_ALTERNATIVE(NAME, ARGS, CONDITION, VALUE, ALTERNATIVE) CLANG_MACRO_BODY(NAME, \
  "# if " CONDITION "\n" \
  "#  define " NAME ARGS " " VALUE "\n" \
  "# else\n" \
  "#  define " NAME ARGS " " ALTERNATIVE "\n" \
  "# endif")

#define CLANG_MACRO_OBJC(NAME, ARGS, VALUE) \
  out << "#if defined(__OBJC__)\n" \
         "#if !defined(" NAME ")\n" \
         "# define " NAME ARGS " " VALUE "\n" \
         "#endif\n" \
         "#endif\n";

#define CLANG_MACRO_CXX(NAME, ARGS, VALUE, ALTERNATIVE) \
  out << "#if defined(__cplusplus)\n" \
         "# define " NAME ARGS " " VALUE "\n" \
         "#else\n" \
         "# define " NAME ARGS " " ALTERNATIVE "\n" \
         "#endif\n";

#define CLANG_MACRO_CXX_BODY(NAME, BODY) \
  out << "#if defined(__cplusplus)\n" \
         BODY "\n" \
         "#endif\n";

#include "swift/PrintAsClang/ClangMacros.def"

  // SWIFT_IMPORT_STDLIB_SYMBOL's expansion can't be calculated in the
  // preprocessor, so write its definition here
  auto emitMacro = [&](StringRef name, StringRef value = "") {
    out << "#if !defined(" << name << ")\n";
    out << "# define " << name << " " << value << "\n";
    out << "#endif\n";
  };
  if (ctx.getStdlibModule()->isStaticLibrary()) {
    emitMacro("SWIFT_IMPORT_STDLIB_SYMBOL");
  } else {
    out << "#if defined(_WIN32)\n";
    emitMacro("SWIFT_IMPORT_STDLIB_SYMBOL", "__declspec(dllimport)");
    out << "#else\n";
    emitMacro("SWIFT_IMPORT_STDLIB_SYMBOL");
    out << "#endif\n";
  }

  static_assert(SWIFT_MAX_IMPORTED_SIMD_ELEMENTS == 4,
              "need to add SIMD typedefs here if max elements is increased");
}

static int compareImportModulesByName(const ImportModuleTy *left,
                                      const ImportModuleTy *right, bool isCxx) {
  auto *leftSwiftModule = left->dyn_cast<ModuleDecl *>();
  auto *rightSwiftModule = right->dyn_cast<ModuleDecl *>();

  if (leftSwiftModule && !rightSwiftModule)
    return -compareImportModulesByName(right, left, isCxx);

  if (leftSwiftModule && rightSwiftModule)
    return leftSwiftModule->getName().compare(rightSwiftModule->getName());

  auto *leftClangModule = left->get<const clang::Module *>();
  assert((isCxx || leftClangModule->isSubModule()) &&
         "top-level modules should use a normal swift::ModuleDecl");
  if (rightSwiftModule) {
    // Because the Clang module is a submodule, its full name will never be
    // equal to a Swift module's name, even if the top-level name is the same;
    // it will always come before or after.
    if (leftClangModule->getTopLevelModuleName() <
        rightSwiftModule->getName().str()) {
      return -1;
    }
    return 1;
  }

  auto *rightClangModule = right->get<const clang::Module *>();
  assert((isCxx || rightClangModule->isSubModule()) &&
         "top-level modules should use a normal swift::ModuleDecl");

  SmallVector<StringRef, 8> leftReversePath(
      ModuleDecl::ReverseFullNameIterator(leftClangModule), {});
  SmallVector<StringRef, 8> rightReversePath(
      ModuleDecl::ReverseFullNameIterator(rightClangModule), {});

  assert(leftReversePath != rightReversePath &&
         "distinct Clang modules should not have the same full name");
  if (std::lexicographical_compare(leftReversePath.rbegin(),
                                   leftReversePath.rend(),
                                   rightReversePath.rbegin(),
                                   rightReversePath.rend())) {
    return -1;
  }
  return 1;
}

// Makes the provided path absolute and removes any "." or ".." segments from
// the path
static llvm::SmallString<128> normalizePath(const llvm::StringRef path) {
  llvm::SmallString<128> result = path;
  llvm::sys::path::remove_dots(result, /* remove_dot_dot */ true);
  llvm::sys::fs::make_absolute(result);
  return result;
}

// Collect the set of header includes needed to import the given Clang module
// into an ObjectiveC program. Modeled after collectModuleHeaderIncludes in the
// Clang frontend (FrontendAction.cpp)
// Augment requiredTextualIncludes with the set of headers required.
static void collectClangModuleHeaderIncludes(
    const clang::Module *clangModule, clang::FileManager &fileManager,
    llvm::SmallSet<llvm::SmallString<128>, 10> &requiredTextualIncludes,
    llvm::SmallSet<const clang::Module *, 10> &visitedModules,
    const llvm::SmallSet<llvm::SmallString<128>, 10> &includeDirs,
    const llvm::StringRef cwd) {

  if (!visitedModules.insert(clangModule).second)
    return;

  auto addHeader = [&](llvm::StringRef headerPath,
                       llvm::StringRef pathRelativeToRootModuleDir) {
    if (!clangModule->Directory)
      return;

    llvm::SmallString<128> textualInclude = normalizePath(headerPath);
    llvm::SmallString<128> containingSearchDirPath;

    for (auto &includeDir : includeDirs) {
      if (textualInclude.str().starts_with(includeDir)) {
        if (includeDir.size() > containingSearchDirPath.size()) {
          containingSearchDirPath = includeDir;
        }
      }
    }

    if (!containingSearchDirPath.empty()) {
      llvm::SmallString<128> prefixToRemove =
          llvm::formatv("{0}/", containingSearchDirPath);
      llvm::sys::path::replace_path_prefix(textualInclude, prefixToRemove, "");
    } else {
      // If we cannot find find the module map on the search path,
      // fallback to including the header using the provided path relative
      // to the module map
      textualInclude = pathRelativeToRootModuleDir;
    }

    if (clangModule->getTopLevelModule()->IsFramework) {
      llvm::SmallString<32> frameworkName =
          clangModule->getTopLevelModuleName();
      llvm::SmallString<64> oldFrameworkPrefix =
          llvm::formatv("{0}.framework/Headers", frameworkName);
      llvm::sys::path::replace_path_prefix(textualInclude, oldFrameworkPrefix,
                                           frameworkName);
    }

    requiredTextualIncludes.insert(textualInclude);
  };

  if (std::optional<clang::Module::Header> umbrellaHeader =
          clangModule->getUmbrellaHeaderAsWritten()) {
    addHeader(umbrellaHeader->Entry.getFileEntry().tryGetRealPathName(),
        umbrellaHeader->PathRelativeToRootModuleDirectory);
  } else if (std::optional<clang::Module::DirectoryName> umbrellaDir =
                 clangModule->getUmbrellaDirAsWritten()) {
    SmallString<128> nativeUmbrellaDirPath;
    std::error_code errorCode;
    llvm::sys::path::native(umbrellaDir->Entry.getName(),
                            nativeUmbrellaDirPath);
    llvm::vfs::FileSystem &fileSystem = fileManager.getVirtualFileSystem();
    for (llvm::vfs::recursive_directory_iterator
             dir(fileSystem, nativeUmbrellaDirPath, errorCode),
         end;
         dir != end && !errorCode; dir.increment(errorCode)) {

      if (llvm::StringSwitch<bool>(llvm::sys::path::extension(dir->path()))
              .Cases(".h", ".H", ".hh", ".hpp", true)
              .Default(false)) {

        // Compute path to the header relative to the root of the module
        // (location of the module map) First compute the relative path from
        // umbrella directory to header file
        SmallVector<StringRef> pathComponents;
        auto pathIt = llvm::sys::path::rbegin(dir->path());

        for (int i = 0; i != dir.level() + 1; ++i, ++pathIt)
          pathComponents.push_back(*pathIt);
        // Then append this to the path from module root to umbrella dir
        SmallString<128> relativeHeaderPath;
        if (umbrellaDir->PathRelativeToRootModuleDirectory != ".")
          relativeHeaderPath += umbrellaDir->PathRelativeToRootModuleDirectory;

        for (auto it = pathComponents.rbegin(), end = pathComponents.rend();
             it != end; ++it) {
          llvm::sys::path::append(relativeHeaderPath, *it);
        }

        addHeader(dir->path(), relativeHeaderPath);
      }
    }
  } else {
    for (clang::Module::HeaderKind headerKind :
         {clang::Module::HK_Normal, clang::Module::HK_Textual}) {
      for (const clang::Module::Header &header :
           clangModule->Headers[headerKind]) {
        addHeader(header.Entry.getFileEntry().tryGetRealPathName(),
                  header.PathRelativeToRootModuleDirectory);
      }
    }
    for (auto submodule : clangModule->submodules()) {
      if (submodule->IsExplicit)
        continue;

      collectClangModuleHeaderIncludes(submodule, fileManager,
                                       requiredTextualIncludes, visitedModules,
                                       includeDirs, cwd);
    }
  }
}

static void
writeImports(raw_ostream &out, llvm::SmallPtrSetImpl<ImportModuleTy> &imports,
             ModuleDecl &M, StringRef bridgingHeader,
             const FrontendOptions &frontendOpts,
             clang::HeaderSearch &clangHeaderSearchInfo,
             const llvm::StringMap<StringRef> &exposedModuleHeaderNames,
             bool useCxxImport = false) {
  // Note: we can't use has_feature(modules) as it's always enabled in C++20
  // mode.
  out << "#if __has_feature(objc_modules)\n";

  out << "#if __has_warning(\"-Watimport-in-framework-header\")\n"
      << "#pragma clang diagnostic ignored \"-Watimport-in-framework-header\"\n"
      << "#endif\n";

  // Sort alphabetically for determinism and consistency.
  SmallVector<ImportModuleTy, 8> sortedImports{imports.begin(),
                                               imports.end()};
  std::stable_sort(
      sortedImports.begin(), sortedImports.end(),
      [&](const ImportModuleTy &left, const ImportModuleTy &right) -> bool {
        return compareImportModulesByName(&left, &right, useCxxImport) < 0;
      });

  auto isUnderlyingModule = [&M, bridgingHeader](ModuleDecl *import) -> bool {
    if (bridgingHeader.empty())
      return import != &M && import->getName() == M.getName();

    return import->isClangHeaderImportModule();
  };

  clang::FileSystemOptions fileSystemOptions;
  clang::FileManager fileManager{fileSystemOptions};

  llvm::SmallSet<llvm::SmallString<128>, 10>
      requiredTextualIncludes; // Only included without modules.
  llvm::SmallVector<StringRef, 1> textualIncludes; // always included.
  llvm::SmallSet<const clang::Module *, 10> visitedModules;
  llvm::SmallSet<llvm::SmallString<128>, 10> includeDirs;

  llvm::vfs::FileSystem &fileSystem = fileManager.getVirtualFileSystem();
  llvm::ErrorOr<std::string> cwd = fileSystem.getCurrentWorkingDirectory();

  if (frontendOpts.EmitClangHeaderWithNonModularIncludes) {
    assert(cwd && "Access to current working directory required");

    for (auto searchDir = clangHeaderSearchInfo.search_dir_begin();
         searchDir != clangHeaderSearchInfo.search_dir_end(); ++searchDir) {
      includeDirs.insert(normalizePath(searchDir->getName()));
    }

    const clang::Module *foundationModule = clangHeaderSearchInfo.lookupModule(
        "Foundation", clang::SourceLocation(), false, false);
    const clang::Module *darwinModule = clangHeaderSearchInfo.lookupModule(
        "Darwin", clang::SourceLocation(), false, false);

    std::function<void(const clang::Module *)>
        collectTransitiveSubmoduleClosure;
    collectTransitiveSubmoduleClosure = [&](const clang::Module *module) {
      if (!module)
        return;

      visitedModules.insert(module);
      for (auto submodule : module->submodules()) {
        collectTransitiveSubmoduleClosure(submodule);
      }
    };

    collectTransitiveSubmoduleClosure(foundationModule);
    collectTransitiveSubmoduleClosure(darwinModule);
  }

  // Track printed names to handle overlay modules.
  llvm::SmallPtrSet<Identifier, 8> seenImports;
  bool includeUnderlying = false;
  StringRef importDirective =
      useCxxImport ? "#pragma clang module import" : "@import";
  StringRef importDirectiveLineEnd = useCxxImport ? "\n" : ";\n";
  for (auto import : sortedImports) {
    if (auto *swiftModule = import.dyn_cast<ModuleDecl *>()) {
      if (useCxxImport) {
        // Do not import Swift modules into the C++ section of the generated
        // header unless explicitly exposed.
        auto it = exposedModuleHeaderNames.find(swiftModule->getName().str());
        if (it != exposedModuleHeaderNames.end())
          textualIncludes.push_back(it->getValue());
        continue;
      }
      auto Name = swiftModule->getName();
      if (isUnderlyingModule(swiftModule)) {
        includeUnderlying = true;
        continue;
      }
      if (seenImports.insert(Name).second) {
        out << importDirective << ' ' << Name.str() << importDirectiveLineEnd;
        if (frontendOpts.EmitClangHeaderWithNonModularIncludes) {
          if (const clang::Module *underlyingClangModule =
                  swiftModule->findUnderlyingClangModule()) {
            collectClangModuleHeaderIncludes(
                underlyingClangModule, fileManager, requiredTextualIncludes,
                visitedModules, includeDirs, cwd.get());
          } else if ((underlyingClangModule =
                          clangHeaderSearchInfo.lookupModule(
                              Name.str(), clang::SourceLocation(), true,
                              true))) {
            collectClangModuleHeaderIncludes(
                underlyingClangModule, fileManager, requiredTextualIncludes,
                visitedModules, includeDirs, cwd.get());
          }
        }
      }
    } else {
      const auto *clangModule = import.get<const clang::Module *>();
      assert((useCxxImport || clangModule->isSubModule()) &&
             "top-level modules should use a normal swift::ModuleDecl");
      out << importDirective << ' ';
      ModuleDecl::ReverseFullNameIterator(clangModule).printForward(out);
      out << importDirectiveLineEnd;
      if (frontendOpts.EmitClangHeaderWithNonModularIncludes) {
        collectClangModuleHeaderIncludes(
            clangModule, fileManager, requiredTextualIncludes, visitedModules,
            includeDirs, cwd.get());
      }
    }
  }

  if (frontendOpts.EmitClangHeaderWithNonModularIncludes) {
    out << "#else\n";
    for (auto header : requiredTextualIncludes) {
      out << "#import <" << header << ">\n";
    }
  }
  out << "#endif\n\n";
  for (const auto header : textualIncludes) {
    out << "#include <" << header << ">\n";
  }

  if (includeUnderlying) {
    if (bridgingHeader.empty())
      out << "#import <" << M.getName().str() << '/' << M.getName().str()
          << ".h>\n\n";
    else
      out << "#import \"" << bridgingHeader << "\"\n\n";
  }
}

static void writePostImportPrologue(raw_ostream &os, ModuleDecl &M) {
  os << "#pragma clang diagnostic ignored \"-Wproperty-attribute-mismatch\"\n"
        "#pragma clang diagnostic ignored \"-Wduplicate-method-arg\"\n"
        "#if __has_warning(\"-Wpragma-clang-attribute\")\n"
        "# pragma clang diagnostic ignored \"-Wpragma-clang-attribute\"\n"
        "#endif\n"
        "#pragma clang diagnostic ignored \"-Wunknown-pragmas\"\n"
        "#pragma clang diagnostic ignored \"-Wnullability\"\n"
        "#pragma clang diagnostic ignored "
        "\"-Wdollar-in-identifier-extension\"\n"
        "#pragma clang diagnostic ignored "
        "\"-Wunsafe-buffer-usage\"\n"
        "\n"
        "#if __has_attribute(external_source_symbol)\n"
        "# pragma push_macro(\"any\")\n"
        "# undef any\n"
        "# pragma clang attribute push("
        "__attribute__((external_source_symbol(language=\"Swift\", "
        "defined_in=\""
     << M.getNameStr()
     << "\",generated_declaration))), "
        "apply_to=any(function,enum,objc_interface,objc_category,"
        "objc_protocol))\n"
        "# pragma pop_macro(\"any\")\n"
        "#endif\n\n";
}

static void writeObjCEpilogue(raw_ostream &os) {
  // Pop out of `external_source_symbol` attribute
  // before emitting the C++ section as the C++ section
  // might include other files in it.
  os << "#if __has_attribute(external_source_symbol)\n"
        "# pragma clang attribute pop\n"
        "#endif\n";
}

static void writeEpilogue(raw_ostream &os) {
  os << "#pragma clang diagnostic pop\n"
        // For the macro guard against recursive definition
        "#endif\n";
}

static std::string computeMacroGuard(const ModuleDecl *M) {
  return (llvm::Twine(M->getNameStr().upper()) + "_SWIFT_H").str();
}

bool swift::printAsClangHeader(raw_ostream &os, ModuleDecl *M,
                               StringRef bridgingHeader,
                               const FrontendOptions &frontendOpts,
                               const IRGenOptions &irGenOpts,
                               clang::HeaderSearch &clangHeaderSearchInfo) {
  llvm::PrettyStackTraceString trace("While generating Clang header");

  SwiftToClangInteropContext interopContext(*M, irGenOpts);

  SmallPtrSet<ImportModuleTy, 8> imports;
  std::string objcModuleContentsBuf;
  llvm::raw_string_ostream objcModuleContents{objcModuleContentsBuf};
  printModuleContentsAsObjC(objcModuleContents, imports, *M, interopContext);
  writePrologue(os, M->getASTContext(), computeMacroGuard(M));
  emitObjCConditional(os, [&] {
    llvm::StringMap<StringRef> exposedModuleHeaderNames;
    writeImports(os, imports, *M, bridgingHeader, frontendOpts,
                 clangHeaderSearchInfo, exposedModuleHeaderNames);
  });
  writePostImportPrologue(os, *M);
  emitObjCConditional(os, [&] { os << objcModuleContents.str(); });
  writeObjCEpilogue(os);
  emitCxxConditional(os, [&] {
    // FIXME: Expose Swift with @expose by default.
    bool enableCxx = frontendOpts.ClangHeaderExposedDecls.has_value() ||
                     M->DeclContext::getASTContext().LangOpts.EnableCXXInterop;
    if (!enableCxx)
      return;

    llvm::StringSet<> exposedModules;
    for (const auto &mod : frontendOpts.clangHeaderExposedImports)
      exposedModules.insert(mod.moduleName);

    // Include the shim header only in the C++ mode.
    ClangSyntaxPrinter(M->getASTContext(), os).printIncludeForShimHeader(
        "_SwiftCxxInteroperability.h");

    // Explicit @expose attribute is required only when the user specifies
    // -clang-header-expose-decls flag.
    // FIXME: should we detect any presence of @expose and require it then?
    bool requiresExplicitExpose =
        frontendOpts.ClangHeaderExposedDecls.has_value() &&
        (*frontendOpts.ClangHeaderExposedDecls ==
             FrontendOptions::ClangHeaderExposeBehavior::HasExposeAttr ||
         *frontendOpts.ClangHeaderExposedDecls ==
             FrontendOptions::ClangHeaderExposeBehavior::
                 HasExposeAttrOrImplicitDeps);
    // Swift stdlib dependencies are emitted into the same header when
    // -clang-header-expose-decls flag is not specified, or when it allows
    // implicit dependency emission.
    bool addStdlibDepsInline =
        !frontendOpts.ClangHeaderExposedDecls.has_value() ||
        *frontendOpts.ClangHeaderExposedDecls ==
            FrontendOptions::ClangHeaderExposeBehavior::
                HasExposeAttrOrImplicitDeps ||
        *frontendOpts.ClangHeaderExposedDecls ==
            FrontendOptions::ClangHeaderExposeBehavior::AllPublic;

    std::string moduleContentsBuf;
    llvm::raw_string_ostream moduleContents{moduleContentsBuf};
    auto deps = printModuleContentsAsCxx(
        moduleContents, *M, interopContext,
        /*requiresExposedAttribute=*/requiresExplicitExpose, exposedModules);
    // FIXME: In ObjC++ mode, we do not need to reimport duplicate modules.
    llvm::StringMap<StringRef> exposedModuleHeaderNames;
    for (const auto &mod : frontendOpts.clangHeaderExposedImports)
      exposedModuleHeaderNames.insert({mod.moduleName, mod.headerName});
    writeImports(os, deps.imports, *M, bridgingHeader, frontendOpts,
                 clangHeaderSearchInfo, exposedModuleHeaderNames,
                 /*useCxxImport=*/true);
    // Embed the standard library directly.
    if (addStdlibDepsInline && deps.dependsOnStandardLibrary) {
      assert(!M->isStdlibModule());
      SwiftToClangInteropContext interopContext(
          *M->getASTContext().getStdlibModule(), irGenOpts);
      auto macroGuard = computeMacroGuard(M->getASTContext().getStdlibModule());
      os << "#ifndef " << macroGuard << "\n";
      os << "#define " << macroGuard << "\n";
      printModuleContentsAsCxx(
          os, *M->getASTContext().getStdlibModule(), interopContext,
          /*requiresExposedAttribute=*/true, exposedModules);
      os << "#endif // " << macroGuard << "\n";
    }

      os << moduleContents.str();
  });
  writeEpilogue(os);

  return false;
}
