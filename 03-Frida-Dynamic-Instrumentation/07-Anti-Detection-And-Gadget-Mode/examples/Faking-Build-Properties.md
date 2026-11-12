---
tags: [example]
level: 1
aliases: ["spoof android.os.Build", "emulator detection bypass"]
created: 2026-11-12
---

# Example: Faking-Build-Properties

> [!info] Level 1 — basics
> One idea: `android.os.Build` fields are plain static fields, filled once at startup — overwrite them with `.value` and every later emulator or test-build check reads your values.

## Goal

Make an emulator look like a retail phone to a Java-side emulator/root check. Belongs to [[Anti-Detection-And-Gadget-Mode]].

## Target (Java, in the app)

```java
static boolean isEmulator() {
    return Build.FINGERPRINT.startsWith("generic")
        || Build.MODEL.contains("sdk_gphone")
        || Build.HARDWARE.equals("ranchu")
        || Build.TAGS.contains("test-keys");
}
```

## Script

```javascript
Java.perform(() => {
    const Build = Java.use("android.os.Build");
    const fake = {
        FINGERPRINT: "google/oriole/oriole:14/UQ1A.240205.004/11269751:user/release-keys",
        MODEL: "Pixel 6", MANUFACTURER: "Google", BRAND: "google",
        PRODUCT: "oriole", DEVICE: "oriole", HARDWARE: "oriole",
        TAGS: "release-keys", TYPE: "user",
    };
    for (const [name, value] of Object.entries(fake)) {
        console.log(`[*] Build.${name}: ${Build[name].value} -> ${value}`);
        Build[name].value = value;
    }
});
```

## Step by step

1. **Static fields via the class wrapper.** `Java.use("android.os.Build")` gives the class; `Build.MODEL.value` reads the static field and assigning `.value` writes it — same `.value` rule as instance fields ([[Finding-Live-Instances-With-Java-Choose]]).
2. **`final` doesn't stop it.** These fields are `public static final`, but Frida writes them through JNI, which ignores `final`. Since they are initialized at runtime (not compile-time constants), the app's code reads the field and sees the new value.
3. **Consistency matters.** Spoof a coherent set (fingerprint, model, product, device, tags matching one real device). Checks increasingly cross-validate fields against each other.
4. **Timing.** Code that copies a field into its own variable before your script runs keeps the old value — spawn the app for this ([[Spawn-Vs-Attach-Timing]]).
5. **Native reads bypass this.** `Build` is populated from system properties; native code calling `__system_property_get("ro.product.model")` reads the property directly. Covering that needs a hook on `__system_property_get` (or the `SystemProperties.get` Java API for Java code that bypasses `Build`).

## Compared with real code

- [[Login-AT01-And-Device-Trust-Signals]] — the device attributes a real banking app actually sends to its backend, which is what decides which fields are worth spoofing.
- [[Ruling-Out-Play-Integrity-Before-Reaching-For-It]] — why spoofing local properties does nothing against server-verified attestation.

## See also

- [[Anti-Detection-And-Gadget-Mode]]
- [[Bypassing-A-Simple-Java-Root-Check]]
- [[Running-ARM-Apps-On-An-x86-Emulator-With-Translation]] — emulator specifics in [[Android-ABIs-And-Emulation]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
