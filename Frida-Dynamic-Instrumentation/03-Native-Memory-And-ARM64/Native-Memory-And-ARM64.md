---
tags: [fundamentals]
aliases: ["Interceptor.attach", "Reading Strings At Runtime"]
created: 2026-07-28
---

# Native-Memory-And-ARM64

## In short

`Interceptor.attach(address, { onEnter, onLeave })` hooks a native function at a fixed address; inside `onEnter`, `args[0]`, `args[1]`, ... are the raw AAPCS64 argument registers (`x0`-`x7`) as `NativePointer` objects, and `Memory.readUtf8String`/`Memory.readCString`/`Memory.readByteArray` turn a pointer into actual bytes. None of this is meaningful without ARM64: knowing the calling convention tells you what each `args[i]` *is*, and knowing how to read disassembly tells you *where* to attach and *what a decrypted/decoded value is a pointer to* in the first place.

## Explanation

### Why static ARM64/smali reading and dynamic hooking are two halves of one job

- [[Dalvik-Bytecode|Smali]] gives you the **surface**: which classes exist, which methods are `native` (and their exact JNI signature), and any string constants sitting in the dex's string pool in cleartext. This is where you find the *name* of a JNI entry point to hook, or confirm a string literal isn't obfuscated at all (so you don't need runtime memory reading for it).
- [[ARM64-Android|ARM64 disassembly]] gives you the **logic**: what a native function actually does once smali runs out (a `native` method has no bytecode body — only the `.so` has the real implementation), including any string-building, XOR/decrypt, or Dart-AOT ([[Flutter-Dart-AOT]]) routines that produce a value which doesn't exist anywhere in the binary as a static constant.
- Frida gives you **ground truth at a specific moment**: instead of hand-simulating a decrypt routine you found in Ghidra, you let the real code run it once and just read the result out of memory. This is almost always faster and less error-prone than re-implementing an obfuscation algorithm by hand from disassembly alone.

### Finding an address to hook

Two starting points, matching two different situations:

| Situation | How to get the address |
| --- | --- |
| Exported/visible symbol (a JNI function registered via `RegisterNatives`, or any exported C function) | `Module.findExportByName("libtarget.so", "Java_com_example_app_Native_decrypt")` |
| Internal, non-exported function found via static analysis (Ghidra/objdump — see [[Objdump-And-Readelf]], [[Reading-Raw-Disassembly]]) at a known **file offset** | `Module.findBaseAddress("libtarget.so").add(0x1a2b3c)` — the module's runtime base plus the static offset from the disassembler |

`Process.enumerateModules()` and `Module.enumerateExports("libtarget.so")` are the exploratory equivalents when you don't already know the exact name — useful for confirming a library is even loaded yet (native libraries used behind a feature-module or lazy `System.loadLibrary` may not exist as a module until later).

### Reading arguments: registers are just `args[i]`

For a native function following standard AAPCS64 (see [[Functions-And-Calling-Convention]]), the first eight integer/pointer arguments arrive in `x0`-`x7`; Frida's `args[0]` through `args[7]` map directly onto those, already as `NativePointer`. A JNI-exported function's *real* first two arguments are always `JNIEnv*` (`args[0]`) and `jobject`/`jclass` (`args[1]`) — every declared Java parameter after that shifts by two:

```javascript
const targetAddr = Module.findExportByName("libnative-lib.so", "Java_com_example_app_Crypto_decrypt");

Interceptor.attach(targetAddr, {
    onEnter(args) {
        // args[0] = JNIEnv*, args[1] = jobject/jclass — skip those
        const inputPtr = args[2]; // first real Java parameter, e.g. a jstring
        console.log("[*] decrypt() called, arg2 = " + inputPtr);
    },
    onLeave(retval) {
        console.log("[*] decrypt() returned pointer: " + retval);
    }
});
```

### Reading memory once you have a pointer

| API | Reads |
| --- | --- |
| `Memory.readUtf8String(ptr, [length])` | A UTF-8 string (Java `jstring`s and most native C strings) |
| `Memory.readCString(ptr, [length])` | A null-terminated ASCII/Latin-1 C string |
| `Memory.readByteArray(ptr, length)` | Raw bytes as an `ArrayBuffer` — for binary blobs, or to `hexdump()` them |
| `Memory.readPointer(ptr)` | Follows one level of pointer indirection (a `char**`, a struct field holding another pointer) |
| `hexdump(ptr, { length, header: true })` | A formatted hex+ASCII dump — the fastest way to eyeball a struct or buffer you haven't fully reverse-engineered yet |

### The case that actually needs this: strings that don't exist statically

A string visible in `strings libtarget.so` output or as a smali `const-string` needs none of this — read it once, statically, and move on. This chapter's technique earns its keep specifically when a string is **built or decrypted at runtime**: an API key assembled byte-by-byte, a URL XORed against a key, a Dart AOT string object materialized from a `libapp.so` object pool entry at a stub address (see [[Flutter-Dart-AOT]]). In every one of those cases, static analysis can tell you *where the decrypt routine is* and *roughly what it does* — but hand-simulating it is wasted effort when you can hook the point right after it runs and just read the plaintext out of the register/memory it left it in.

`Memory.scan(address, size, pattern, { onMatch, onComplete })` extends this to "I don't know the exact address, but I know a byte pattern" — useful for finding a struct or a known-prefix string (e.g. `"https://"`) inside a module's memory range without a precise offset.

## Worked example

Hook a native decrypt function found via static analysis (address recovered from Ghidra, base module resolved at runtime), dump its raw input bytes, and read the decrypted C-string it returns:

```javascript
const moduleName = "libnative-lib.so";
const staticOffset = 0x4a1c; // from Ghidra/objdump, relative to the module's load base

const base = Module.findBaseAddress(moduleName);
if (base === null) {
    console.log(`[!] ${moduleName} not loaded yet — spawn instead of attach, or wait for it`);
} else {
    const target = base.add(staticOffset);

    Interceptor.attach(target, {
        onEnter(args) {
            this.inputLen = args[1].toInt32();
            console.log("[*] decrypt() input:");
            console.log(hexdump(args[0], { length: this.inputLen, ansi: false }));
        },
        onLeave(retval) {
            if (!retval.isNull()) {
                console.log("[*] decrypt() plaintext: " + Memory.readCString(retval));
            }
        }
    });
}
```

## More examples

- [[Frida-JS-API-Cheatsheet]] in [[Frida-Dynamic-Instrumentation-Cheatsheets|Cheatsheets]] lists the full `Memory.*`/`Module.*`/`Interceptor.*` surface.

## See also

- [[Java-Layer-Hooking]]
- [[Network-Interception]]
- [[Functions-And-Calling-Convention]] and [[Reading-Raw-Disassembly]] in [[ARM64-Android]] — without these, `args[i]` are just numbers with no meaning.
- [[Android-Native-Internals]] in [[ARM64-Android]] — the JNI calling convention (`JNIEnv*`, `jobject`/`jclass` as the first two real arguments) referenced above.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

For a JNI-exported native function, what are `args[0]` and `args[1]` always, regardless of the Java method's declared parameters?::`JNIEnv*` and the `jobject`/`jclass` receiver — every declared Java parameter shifts two slots to the right in the native argument list.

When is runtime memory reading actually necessary for extracting a string, versus just reading the binary statically?::When the string is built or decrypted at runtime and never exists as a plaintext constant in the binary — a static `strings`/smali read would miss it entirely, while hooking the point right after the decrypt/build routine runs lets you read the real value directly out of memory.

How do you get the runtime address for a static offset found in a disassembler?::`Module.findBaseAddress(moduleName).add(staticOffset)` — the module's runtime load base plus the file offset the disassembler reported.
