---
tags: [fundamentals]
aliases: ["ABI", "Android ABIs", "armeabi-v7a", "APK Native Libraries", "Emulator Architecture", "INSTALL_FAILED_NO_MATCHING_ABIS", "extractNativeLibs"]
created: 2026-07-29
---

# Android-ABIs-And-Emulation

## In short

Before a single Frida script can attach to anything, the target APK has to actually be installed and running on the device you're pointing at — and for an emulator, that's where most of the real friction lives, not in Frida itself. This chapter is about the layer underneath [[Frida-Fundamentals]]: what an ABI is and why an APK's native libraries are tied to one, why an Android Virtual Device is a full CPU emulator with its own architecture separate from the app's, why that sometimes forces you onto an "old" API level instead of the newest AVD image, and why an APK that fails to install with a cryptic native-library error is almost always an ABI or packaging mismatch rather than a corrupt file.

## Explanation

### What an ABI actually is, and why it's per-`.so`, not per-APK

An **ABI** (Application Binary Interface) is the contract compiled native code depends on: instruction set, register/calling convention, struct layout and alignment, syscall numbering. It's a strictly lower-level concept than the CPU architecture family alone — `armeabi-v7a` and `arm64-v8a` are both "ARM", but they are different, mutually incompatible ABIs (32-bit vs. 64-bit ARM, different calling conventions — see [[Functions-And-Calling-Convention]] and its 64-bit-specific [[Aapcs64-Specification|AAPCS64]] reading notes for the 64-bit side of that). Java/Kotlin bytecode is architecture-neutral and runs unmodified on any device via ART; only the `.so` files under an APK's `lib/` directory are ABI-specific:

```
lib/
├── armeabi-v7a/libfoo.so   <- 32-bit ARM
├── arm64-v8a/libfoo.so     <- 64-bit ARM
├── x86/libfoo.so           <- 32-bit Intel
└── x86_64/libfoo.so        <- 64-bit Intel
```

A production APK built for the Play Store typically ships several of these side by side (or Play delivers only the one matching the install target, via split APKs); a lot of reverse-engineering targets — anything obfuscated with a native protection layer, anything using a native crypto/anti-tamper library — ship **only one**, usually `armeabi-v7a` or `arm64-v8a`, because the vendor never bothered building an x86 variant nobody's physical phone needs. That single-ABI case is exactly what turns "just install the APK" into an architecture problem.

### Two independent architecture questions, easy to conflate

Running an app on the Android Emulator involves two separate architecture matches, and a mismatch in either one fails differently:

| Question | What it determines | Where it's decided |
|---|---|---|
| What architecture is the **emulated device's OS itself**? | Whether the AVD boots at all, and how fast | The system image you picked (`x86_64`, `arm64-v8a`, ...) vs. the **host** CPU |
| What ABI(s) can that running OS **execute app native code** in? | Whether a specific APK's `lib/<abi>/*.so` can load | `ro.product.cpu.abilist` on the running device, which can be wider than the image's own "native" architecture if a translation layer is bundled |

The first is a hard requirement: the emulator's QEMU2 backend runs the guest OS's architecture more or less natively when it matches the host (hardware-accelerated via WHPX/HAXM/KVM) and falls back to slow, more limited software emulation otherwise — on a desktop x86_64 host, that's why `x86_64` (or 32-bit `x86`) AVD images are the practical default, not `arm64-v8a` ones, even though real Android phones are ARM.

The second is what actually matters for a specific target APK, and it's solved by **binary translation baked into the system image**, not by the emulator's core CPU emulation: an x86/x86_64 Google image can ship a translation layer (`libhoudini` on older 32-bit `x86` images, Google's own `libndk_translation` on newer 64-bit-only images) that translates ARM native code on the fly, so an ARM-only APK still runs even though the host and guest OS are both x86. Check what a running AVD actually offers before installing anything:

```
adb shell getprop ro.product.cpu.abilist
adb shell getprop ro.product.cpu.abilist32
adb shell getprop ro.product.cpu.abilist64
```

An empty or missing `armeabi-v7a` entry in that list means this particular image cannot run a 32-bit-ARM-only APK, full stop — no amount of retrying the install fixes it, because the OS underneath genuinely doesn't have the translation binary for that ABI.

### `INSTALL_FAILED_NO_MATCHING_ABIS`

`PackageManager` checks an APK's `lib/` entries against the device's `abilist` at install time, before it even tries to extract anything, and refuses outright if there's no overlap at all:

```
adb install -r target.apk
# Failure [INSTALL_FAILED_NO_MATCHING_ABIS: ... Failed to extract native libraries, res=-113]
```

This is a hard incompatibility, not a corrupt-APK symptom — the fix is always to switch to a system image whose `abilist` actually includes the APK's ABI (see "Building a 32-bit, Google-Play-certified AVD" below), never to re-sign, re-zipalign, or otherwise fiddle with the APK itself.

### Why "relatively old" API levels: 32-bit `x86` Google Play images stopped at API 30

Google has been steadily dropping 32-bit support from newer system images. The practical consequence for anyone reverse-engineering an `armeabi-v7a`-only app on a desktop emulator: genuinely 32-bit **and** Play-Store-certified (`google_apis_playstore`) images only exist up through **API 30** — list what's actually published with:

```
sdkmanager --list | grep "google_apis_playstore;x86"
```

which, as of this vault's SDK snapshot, tops out at `system-images;android-30;google_apis_playstore;x86`. Nothing newer in that exact combination exists to install — API 31+ Play images are `x86_64`/`arm64-v8a` only, and while some of those still bundle `libndk_translation` for `arm64-v8a` guest code, translation support for 32-bit `armeabi-v7a` specifically has been getting dropped image by image as Google narrows what the translator covers. So "pick an old API level" isn't a workaround or a compatibility shim you'd reach for out of laziness — for a genuinely 32-bit-ARM-only target that also needs the real Play Store present, it's the newest image that still has both properties at once.

This is a distinct axis from the `google_apis` vs. `google_apis_playstore` rootability tradeoff covered in [[Frida-Server-Setup]] — that note's table is about whether `adb root` works (`userdebug` vs. `user` builds); this section is about whether the CPU architecture even loads the app's native code at all. A single AVD choice has to satisfy both independently: Play Store present *and* the right ABI available *and*, separately again, rootable enough for whatever instrumentation approach you're using ([[Anti-Detection-And-Gadget-Mode]] covers the Frida Gadget route for when it isn't).

### Building a 32-bit, Google-Play-certified AVD

```
sdkmanager "system-images;android-30;google_apis_playstore;x86"
avdmanager create avd -n MyAVD30-PlayStore-x86 -k "system-images;android-30;google_apis_playstore;x86" -d "pixel_6"
emulator -avd MyAVD30-PlayStore-x86
```

`-d "pixel_6"` picks a device profile (screen size/density) — it has no bearing on the ABI question, only on skin/resolution. Once it's booted, confirm the ABI before trusting it:

```
adb wait-for-device
adb shell getprop ro.product.cpu.abilist   # expect: x86,armeabi-v7a
```

### `extractNativeLibs` and why *adding* a native library can break installation

Modern APKs commonly set `android:extractNativeLibs="false"` in the manifest (check with `aapt2 dump xmltree target.apk --file AndroidManifest.xml | grep extractNativeLibs`) as an install-size/-speed optimization: instead of copying every `.so` out to disk at install time, the OS `mmap`s them directly out of the APK zip at load time. That only works if every entry under `lib/` in the zip is **stored uncompressed** (`ZIP_STORED`, not `DEFLATE`) and page-aligned — `mmap` needs a contiguous, uncompressed byte range to map, and can't map through a decompression step.

This becomes a trap the moment you repackage an APK to add a native library — most commonly, injecting `libfrida-gadget.so` for [[Anti-Detection-And-Gadget-Mode|Gadget mode]] into an app that already has `extractNativeLibs=false`. If the repackaging tool adds the new `.so` compressed (the default behavior of most naive "just re-zip it" scripts, and of Python's `zipfile` unless told otherwise), the result is an APK where some `lib/*.so` entries are uncompressed and one is compressed — internally inconsistent with its own manifest flag — and installation fails:

```
adb install -r repackaged.apk
# Failure [INSTALL_FAILED_INVALID_APK: Failed to extract native libraries, res=-2]
```

Critically, `zipalign -c -v 4` on that same file can report every entry as correctly aligned and still not catch this — alignment and compression method are independent properties of a zip entry, and the installer's native-library extractor cares about both.

## Worked example

Diagnosing and fixing exactly that failure, starting from an APK that has just been repackaged with an injected native library and refuses to install.

```
# 1. Confirm what ABI the APK actually ships, and read the manifest flag
aapt dump badging target.apk | grep native-code
aapt2 dump xmltree target.apk --file AndroidManifest.xml | grep -A1 extractNativeLibs

# 2. Rule out plain misalignment first (fast, doesn't explain a compression mismatch on its own)
zipalign -c -v 4 target.apk

# 3. List every lib/*.so entry's compressed vs. uncompressed size — a mismatch (compressed
#    size < uncompressed size) on an image that expects extractNativeLibs=false is the smoking gun
python3 - <<'EOF'
import zipfile
z = zipfile.ZipFile("target.apk")
for i in z.infolist():
    if i.filename.startswith("lib/") and i.filename.endswith(".so"):
        print(i.filename, i.file_size, i.compress_size,
              "COMPRESSED" if i.compress_size < i.file_size else "stored")
EOF
```

```python
# 4. fix_apk.py — rewrite the zip forcing every lib/*.so entry to STORED (uncompressed),
#    dropping the old signature files so the APK can be re-signed cleanly afterward
import zipfile, sys
src, dst = sys.argv[1], sys.argv[2]
zin = zipfile.ZipFile(src, "r")
zout = zipfile.ZipFile(dst, "w", allowZip64=True)
for item in zin.infolist():
    if item.filename.startswith("META-INF/") and (
        item.filename.endswith((".RSA", ".SF", ".DSA", ".EC")) or item.filename == "META-INF/MANIFEST.MF"
    ):
        continue
    data = zin.read(item.filename)
    compress_type = zipfile.ZIP_STORED if item.filename.startswith("lib/") and item.filename.endswith(".so") else item.compress_type
    zi = zipfile.ZipInfo(item.filename, date_time=item.date_time)
    zi.compress_type = compress_type
    zi.external_attr = item.external_attr
    zout.writestr(zi, data)
zin.close(); zout.close()
```

```
# 5. Re-align (now meaningful, since the lib/*.so entries are actually uncompressed) and re-sign.
#    A fresh debug key is fine here — this isn't being installed as an update over an
#    existing signed copy, so it doesn't need to match the original developer's signature.
python3 fix_apk.py target.apk fixed_unaligned.apk
zipalign -f -p 4 fixed_unaligned.apk fixed_aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android \
  --key-pass pass:android --ks-key-alias androiddebugkey \
  --out final_signed.apk fixed_aligned.apk

adb install -r final_signed.apk
```

`-p 4` on `zipalign` aligns uncompressed entries to 4 bytes generally, and specifically page-aligns uncompressed shared libraries — the flag that matters once `extractNativeLibs=false` is in play; plain `zipalign -f 4` without `-p` only guarantees the weaker general alignment.

## More examples

-

## See also

- [[Frida-Fundamentals]] — what all of this is in service of: getting a script attached at all.
- [[Frida-Server-Setup]] — the companion AVD-setup note, focused on the `google_apis`-vs-`google_apis_playstore` rootability tradeoff rather than the ABI-translation question this chapter covers.
- [[Anti-Detection-And-Gadget-Mode]] — the most common reason to be repackaging an APK's native libraries in the first place.
- [[Native-Memory-And-ARM64]] — why ABI/architecture matters again once you're actually hooking, not just installing.
- [[ARM64-Android]] — the static-analysis side of the 32-bit/64-bit ARM distinction (registers, calling convention, disassembly).

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why are `armeabi-v7a` and `arm64-v8a` incompatible ABIs even though both are "ARM"?::They differ in instruction set width, calling convention, and struct layout/alignment — an ABI is a strict binary contract, and 32-bit vs. 64-bit ARM are different contracts entirely, even though they're the same CPU vendor family.

What are the two separate architecture questions an Android Emulator setup has to answer, and how does each fail differently?::(1) Does the AVD's own OS architecture match the host CPU well enough to boot/run at reasonable speed — mismatches here make the emulator slow or refuse to start; (2) does the running system image's `abilist` include the target APK's native-library ABI, via a bundled translation layer — a mismatch here installs the OS fine but rejects that specific APK with `INSTALL_FAILED_NO_MATCHING_ABIS`.

Why does a genuinely 32-bit-ARM target sometimes force you onto an old API level like 30 instead of the newest AVD image?::Google-Play-certified, 32-bit `x86` system images (the combination that has both real Play Store *and* `libhoudini`-based `armeabi-v7a` translation) stop being published after API 30; newer Play images are 64-bit-only and progressively drop 32-bit ARM translation support, so an old image is the newest one that still satisfies both requirements.

Why can injecting a native library like Frida Gadget into an APK that has `extractNativeLibs=false` break installation even when `zipalign -c` reports no problems?::`extractNativeLibs=false` requires every `lib/*.so` entry to be stored uncompressed (not just aligned) so the OS can `mmap` it straight out of the APK; a repackaging tool that adds the new library compressed produces an internally inconsistent APK that fails with `INSTALL_FAILED_INVALID_APK: Failed to extract native libraries` — a problem `zipalign`'s alignment check doesn't catch, since compression method and alignment are checked independently.
