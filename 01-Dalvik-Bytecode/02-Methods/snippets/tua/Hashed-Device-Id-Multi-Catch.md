---
tags: [snippet]
project: "TUA (net.pluservice.tua)"
source: net.pluservice.tua
version: "unknown"
source_path: "smali/net/pluservice/plugins/DeviceInformation/DeviceIdProvider.smali"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Hashed-Device-Id-Multi-Catch

## Context

`getHashedDeviceID` wraps a device-ID lookup and a SHA-1 hash in a single `try` block guarded by **two** `.catch` directives for two unrelated exception types — a real-world instance of Java's multi-catch compiling down to nothing more than two separate `.catch` entries pointing at two separate handler labels, both covering the exact same protected region. It's plain, unobfuscated smali (unlike most of the rest of this app — see [[Reading-Raw-Dalvik]]), which is exactly what makes it a clean example of the `.catch` mechanics [[Methods]] describes in the abstract.

## Original path

`smali/net/pluservice/plugins/DeviceInformation/DeviceIdProvider.smali` (see [[Tua-Case-Study]]; full file under `Case-Studies/tua/source/smali/`)

## Snippet

```smali
.method public static getHashedDeviceID(Landroid/content/Context;)Ljava/lang/String;
    .locals 3

    const-string v0, "Cannot create SHA1 hash of UUID: "
    const-string v1, "DeviceIdProvider"

    :try_start_0
    invoke-static {p0}, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->getDeviceID(Landroid/content/Context;)Ljava/lang/String;
    move-result-object p0

    invoke-static {p0}, Lnet/pluservice/plugins/DeviceInformation/AeSimpleSHA1;->SHA1(Ljava/lang/String;)Ljava/lang/String;
    move-result-object p0
    :try_end_0
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    return-object p0

    :catch_0
    move-exception p0
    # ... build a log message from v0/v1 and p0's own getMessage(), then Log.e(...) ...
    throw p0

    :catch_1
    move-exception p0
    # ... same shape, second exception type, second handler label ...
    throw p0
.end method
```

## Notes

Both `.catch` directives share the identical `{:try_start_0 .. :try_end_0}` range — a single protected region can have as many `.catch` entries as there are exception types worth handling differently, each with its own handler label, exactly mirroring a Java `catch (A e) {...} catch (B e) {...}` on one `try`. Each handler here re-throws after logging (`throw p0`), rather than swallowing the exception, so the method's only two ways out are a successful `return-object` or a re-thrown exception — no silent failure path. See [[Methods]]'s own `.catch` section for the single-exception case this generalizes.

## See also

- [[Methods]]
- [[Dalvik-Bytecode-Reference|Reference]]
