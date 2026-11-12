---
tags: [snippet]
level: 3
project: "PressReader"
source: "com.newspaperdirect.pressreader.android — bundled AndroidX DataStore native library"
version: "unknown"
source_path: "lib/arm64-v8a/libdatastore_shared_counter.so (whole library, 7 KB)"
date_added: 2026-11-12
license_note: "Disassembly of an AndroidX (Apache-2.0) component shipped inside the app; personal study/research purposes only."
---

# Reading-Datastore-Shared-Counter-Cold

> [!info] Level 3 — real code
> A complete real shared library, read cold from the file up: sections, exports, imports, strings, constructors, then every function — ending in a full C++ reconstruction of a 7 KB `.so`.

## Context

`libdatastore_shared_counter.so` ships in PressReader's `lib/arm64-v8a/`. It's small enough to read *entirely*, which makes it the ideal capstone for this chapter: every technique from the basic examples, applied in order on one real binary, with nothing skipped. The individual functions are analysed in depth in the chapter-specific snippets linked below; this note is about the *workflow*.

## Original path

`lib/arm64-v8a/libdatastore_shared_counter.so` (from the decoded PressReader APK).

## Pass 1 — the file

```text
$ objdump -h libdatastore_shared_counter.so      # sections
  .dynsym .dynstr .rela.dyn .rela.plt .rodata(0x27 bytes) .text(0x38c bytes) .plt .init_array ...
$ objdump -s -j .rodata libdatastore_shared_counter.so
  0a80  exynos9810.java/io/IOException.ro.arch.
$ objdump -R libdatastore_shared_counter.so      # imports, via relocations
  __cxa_finalize __cxa_atexit strerror __stack_chk_fail ftruncate __errno
  mmap getauxval __system_property_get strncmp
  + four of the library's own datastore:: functions (called through the PLT)
```

- **Size**: 908 bytes of code. Every function can be read.
- **Strings** (three!): `java/io/IOException` → throws Java exceptions (JNI); `ro.arch` + `exynos9810` → a system-property check on a Samsung SoC name.
- **Imports**: `ftruncate`, `mmap` → file-backed shared memory; `getauxval` → CPU feature detection; `__stack_chk_fail` → stack protector enabled.
- **`.init_array`** has an entry → code runs at load time.

## Pass 2 — exported functions

```text
0xd80   92  ThrowIoException(JNIEnv*, const char*)
0xddc  120  Java_androidx_datastore_core_NativeSharedCounter_nativeTruncateFile
0xe54  192  Java_androidx_datastore_core_NativeSharedCounter_nativeCreateSharedCounter
0xf14   24  Java_androidx_datastore_core_NativeSharedCounter_nativeGetCounterValue
0xf2c   24  Java_androidx_datastore_core_NativeSharedCounter_nativeIncrementAndGetCounterValue
0xf44   36  datastore::TruncateFile(int)
0xf68   88  datastore::CreateSharedCounter(int, void**)
0xfc0    8  datastore::GetCounterValue(std::atomic<unsigned>*)
0xfc8   32  datastore::IncrementAndGetCounterValue(std::atomic<unsigned>*)
```

The demangled C++ names already give the parameter *types*. The `Java_…` names give the Java class (`androidx.datastore.core.NativeSharedCounter`) and its four `native` methods. What's left unnamed: the stretch `0xff0`–`0x10bc`, which [[Finding-Function-Boundaries-And-Calls]]'s method splits into a helper at `0xff0` (target of `bl` from `0xfd8`) and the `.init_array` constructor at `0x1020`.

## Pass 3 — every function, bottom-up

Read leaves first, then their callers:

| function | key instructions | meaning | deep dive |
| --- | --- | --- | --- |
| `GetCounterValue` | `ldar w0, [x0]` | atomic load of a `uint32_t` | [[Outline-Atomics-LSE-Vs-LLSC-In-Datastore]] |
| helper `0xff0` | `ldaddal` or `ldaxr`/`stlxr` loop, chosen by a flag | `__aarch64_ldadd4_acq_rel` | same |
| ctor `0x1020` | `getauxval(16)`, bit 8, `ro.arch` ≠ `exynos9810` | sets the "has LSE" flag | same |
| `IncrementAndGetCounterValue` | `bl helper(1, p)`; `add w0, w0, #1` | `fetch_add(1) + 1` | same |
| `TruncateFile` | `ftruncate(fd, 4)`; `errno` on failure | resize file to 4 bytes | below |
| `CreateSharedCounter` | `mmap(NULL, 4, 3, 0x8001, fd, 0)` | map the counter | [[Mmap-Call-Arguments-In-Datastore]] |
| `ThrowIoException` | `FindClass` + tail-call `ThrowNew` | throw `IOException` | [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]] |
| `nativeTruncateFile` | inlined throw, `sxtw` return | JNI wrapper, returns 64-bit | [[Return-Value-Widening-In-Datastore-JNI]] |
| `nativeCreateSharedCounter` | canary, `&address` out-param, `csel` | JNI wrapper, returns the pointer | [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]] |
| `nativeGet…`/`nativeIncrement…` | `mov x0, x2`; `bl`; `ret` | JNI wrappers: drop `env`/`this`, forward the `long` address | below |

The two smallest pieces:

```asm
; datastore::TruncateFile(int fd)
f44:  stp     x29, x30, [sp, #-0x10]!
f48:  mov     x29, sp
f4c:  mov     w1, #4                ; length = 4
f50:  bl      ftruncate
f54:  cbz     w0, 0xf60             ; 0 -> return 0 (w0 already 0)
f58:  bl      __errno
f5c:  ldr     w0, [x0]              ; return errno
f60:  ldp     x29, x30, [sp], #0x10
f64:  ret

; nativeGetCounterValue(JNIEnv*, jobject, jlong address)
f14:  stp     x29, x30, [sp, #-0x10]!
f18:  mov     x29, sp
f1c:  mov     x0, x2                ; third JNI arg -> first C arg
f20:  bl      datastore::GetCounterValue
f24:  ldp     x29, x30, [sp], #0x10
f28:  ret
```

## Reconstructed source

```cpp
// shared_counter.cc (reconstructed)
namespace datastore {
int TruncateFile(int fd) {
    return ftruncate(fd, sizeof(uint32_t)) == 0 ? 0 : errno;
}
int CreateSharedCounter(int fd, void** counter_address) {
    void* p = mmap(nullptr, sizeof(uint32_t), PROT_READ | PROT_WRITE,
                   MAP_SHARED | MAP_POPULATE, fd, 0);
    if (p == MAP_FAILED) return errno;
    *counter_address = p;
    return 0;
}
uint32_t GetCounterValue(std::atomic<uint32_t>* a)             { return a->load(); }
uint32_t IncrementAndGetCounterValue(std::atomic<uint32_t>* a) { return a->fetch_add(1) + 1; }
}

// jni.cc (reconstructed)
static int ThrowIoException(JNIEnv* env, const char* msg) {
    jclass c = env->FindClass("java/io/IOException");
    return c ? env->ThrowNew(c, msg) : -1;
}
extern "C" {
JNIEXPORT jlong JNICALL Java_androidx_datastore_core_NativeSharedCounter_nativeTruncateFile(
        JNIEnv* env, jobject, jint fd) {
    if (int e = datastore::TruncateFile(fd)) return ThrowIoException(env, strerror(e));
    return 0;
}
JNIEXPORT jlong JNICALL Java_androidx_datastore_core_NativeSharedCounter_nativeCreateSharedCounter(
        JNIEnv* env, jobject, jint fd) {
    void* address = nullptr;
    if (int e = datastore::CreateSharedCounter(fd, &address)) return ThrowIoException(env, strerror(e));
    return reinterpret_cast<jlong>(address);
}
JNIEXPORT jint JNICALL Java_androidx_datastore_core_NativeSharedCounter_nativeGetCounterValue(
        JNIEnv*, jobject, jlong address) {
    return datastore::GetCounterValue(reinterpret_cast<std::atomic<uint32_t>*>(address));
}
JNIEXPORT jint JNICALL Java_androidx_datastore_core_NativeSharedCounter_nativeIncrementAndGetCounterValue(
        JNIEnv*, jobject, jlong address) {
    return datastore::IncrementAndGetCounterValue(reinterpret_cast<std::atomic<uint32_t>*>(address));
}
}
```

## Notes

- **Compared with the basic examples.** [[Finding-Function-Boundaries-And-Calls]] and [[Naming-Arguments-From-Their-Uses]] are passes 2 and 3 on toy code; [[Recognizing-A-Hash-Loop-By-Its-Constants]] is the "match a known thing" move used here on the outline-atomics helper. The order — file → exports/imports/strings → leaves → callers → reconstruction — is what makes a whole library tractable.
- **What the binary alone proves.** The Kotlin class that would call these functions is absent from the APK's DEX (R8 removed it — DataStore's multi-process mode is unused by the app), so return types like `jlong` for `nativeTruncateFile` come solely from the machine code (`sxtw x0` / `mov x0`). The library is dead code shipped anyway, a common sight in real APKs: native libraries aren't shrunk with the Java code that uses them.
- **Design recovered.** Two processes open the same file, each calls `nativeTruncateFile` (size 4) and `nativeCreateSharedCounter` (map it `MAP_SHARED`), and then use the atomic increment to signal each other that the data changed — a cross-process version counter. All of that follows from 908 bytes of code and three strings.
- **Upstream source.** DataStore is open source (Apache-2.0), so the reconstruction can be checked against AndroidX's own C++; the point of the exercise is that the binary is enough without it.

## See also

- [[Reading-Raw-Disassembly]]
- [[Reading-A-Dart-AOT-Getter-Cold]] — the other real cold read in this chapter, on Dart AOT code
- [[Objdump-And-Readelf]]
- [[Android-Native-Internals]]
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
