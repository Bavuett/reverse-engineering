---
tags: [snippet]
project: "TUA (net.pluservice.tua)"
source: net.pluservice.tua
version: "unknown"
source_path: "smali/net/pluservice/plugins/DeviceInformation/DeviceIdProvider.smali"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Device-Id-Wide-Register-Uuid

## Context

`getInstanceId` builds a `java.util.UUID` from two `int` hash codes packed into a single 64-bit most-significant-bits argument — a real-world case of the `long` register-pair mechanics from [[Registers]] (`shl-long/2addr`, wide `move`/parameter passing) doing real work, not just an isolated syntax example.

## Original path

`smali/net/pluservice/plugins/DeviceInformation/DeviceIdProvider.smali` (see [[Tua-Case-Study]]; full file under `Case-Studies/tua/source/smali/`)

## Snippet

```smali
.method private static getInstanceId()Ljava/lang/String;
    .locals 6

    invoke-static {}, Lcom/google/firebase/iid/FirebaseInstanceId;->getInstance()Lcom/google/firebase/iid/FirebaseInstanceId;
    move-result-object v0
    invoke-virtual {v0}, Lcom/google/firebase/iid/FirebaseInstanceId;->getId()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/util/UUID;
    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I
    move-result v2                     # v2 = a plain 32-bit int hash code
    int-to-long v2, v2                 # widened into the pair v2-v3 -- v3 is now the sign-extension of v2

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I
    move-result v0                     # a second (identical, in this case) 32-bit hash
    int-to-long v4, v0                 # widened into v4-v5
    const/16 v0, 0x20
    shl-long/2addr v4, v0              # v4-v5 <<= 32: the second hash now occupies the HIGH 32 bits of the pair

    invoke-direct {v1, v2, v3, v4, v5}, Ljava/util/UUID;-><init>(JJ)V   # UUID(long mostSigBits, long leastSigBits)
    invoke-virtual {v1}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method
```

## Notes

`UUID.<init>(JJ)V` takes two `long` parameters, so the call passes **four** consecutive registers (`v2, v3, v4, v5`) even though only two Java-level arguments are involved — exactly the "a `long` occupies two consecutive registers, referred to by its lower one" rule from [[Registers]], made concrete: `v2` is really "the pair `v2`-`v3`" and `v4` is really "the pair `v4`-`v5`". `shl-long/2addr v4, v0` shifting a widened 32-bit hash left by `0x20` (32) is a common idiom for packing two 32-bit values into one 64-bit one — it only works because `int-to-long` sign-extends into the *low* half first, leaving the high half free for the shift to fill. `.locals 6` here isn't a coincidence: two wide pairs (`v2`-`v3`, `v4`-`v5`) plus one object register (`v0`/`v1`, reused) account for exactly the six local slots declared.

## See also

- [[Registers]]
- [[Types]] — `J` descriptor and 64-bit register pairs
- [[Dalvik-Bytecode-Reference|Reference]]
