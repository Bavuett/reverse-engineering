---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "lib/arm64-v8a/libencrypt.so, function Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt (0x589d0)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Conditional-Cleanup-Chain-In-Libencrypt

> [!info] Level 3 — real code
> The control-flow skeleton of a real 676-byte native function: a try-then-retry call, three error paths that log and jump into the middle of the cleanup, and a cleanup chain of independent `if (p) release(p)` blocks.

## Context

`Encryption.decrypt` is PressReader's native routine for unpacking a licence blob (Java side: [[Reading-A-Native-Facade-Class-Cold]]; JNI-level reading: [[Encryption-Decrypt-JNI-Entry-In-Libencrypt]]). This note ignores *what* is computed and looks only at the *shape* of the control flow, which is typical of hand-written C/C++ resource handling and shows up in nearly every JNI function that takes strings.

## Original path

`lib/arm64-v8a/libencrypt.so` → `Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt`, address `0x589d0`, 676 bytes. Callee names resolved through `.rela.plt`; string addresses resolved in `.rodata`.

## Snippet (condensed)

```asm
; --- try, then retry with an extra argument -------------------------------
58ab4:  mov     x4, x24               ; s2 (may be NULL)
58ab8:  bl      DecryptData           ; attempt 1: key argument = NULL
58abc:  tbnz    w0, #0, 0x58adc       ; bool true -> success, skip retry
58ac4:  ldr     x3, [sp, #8]          ; s1
58ad4:  bl      DecryptData           ; attempt 2: key argument = s1
58ad8:  tbz     w0, #0, 0x58c50       ; still false -> error path C

; --- happy path ---------------------------------------------------------------
58adc:  ...                           ; zero a 64-byte buffer
58b00:  bl      GetXmlAtribute        ; (buf, "encryptionKey", out)
58b04:  cbz     w0, 0x58c24           ; attribute missing -> error path B
58b10:  bl      __strlen_chk
58b28:  bl      base64_decode         ; -> result, result_len
58b2c:  b       0x58c3c               ; join cleanup

; --- error path A: base64 of the input failed ------------------------------
58b30:  adr     x1, "Panda"           ; log tag
58b38:  adrp/add x2, "Can not encode the base64 certificate "
58b40:  mov     w0, #6                ; ANDROID_LOG_ERROR
58b44:  bl      __android_log_print
58b48:  mov     x0, x27
58b4c:  bl      free                  ; <- error path C rejoins here
58b50:  mov     w26, wzr              ; result_len = 0

; --- cleanup chain: three independent "if (p) release(p)" ------------------
58b54:  cbz     x22, 0x58b70          ; jstring arg 1 was null?
58b68:  ldr     x8, [x8, #0x550]      ;   env->ReleaseStringUTFChars
58b6c:  blr     x8
58b70:  cbz     x21, 0x58b8c
58b84:  ldr     x8, [x8, #0x550]
58b88:  blr     x8
58b8c:  cbz     x20, 0x58ba8
58ba0:  ldr     x8, [x8, #0x550]
58ba4:  blr     x8

; --- build the return value only if there's something to return ----------
58ba8:  cmp     w26, #1
58bac:  b.lt    0x58bec               ; len < 1 -> return NULL
58bbc:  ldr     x8, [x8, #0x580]      ; env->NewByteArray(len)
58bdc:  ldr     x8, [x8, #0x680]      ; env->SetByteArrayRegion(arr, 0, len, result)
58be8:  b       0x58bf0
58bec:  mov     x20, xzr              ; NULL
58bf0:  ...                           ; canary check, epilogue, ret

; --- error path B / join of the happy path --------------------------------
58c24:  ... __android_log_print("Panda", "Licence file has wrong format")
58c3c:  ldr     x0, [sp, #0x18]
58c40:  bl      free                  ; free the decrypted buffer
58c44:  ldr     w26, [sp, #0x10]      ; result_len (0 on error)
58c48:  cbnz    x22, 0x58b58          ; jump INTO the cleanup chain
58c4c:  b       0x58b70               ; ...skipping its first test

; --- error path C ----------------------------------------------------------
58c50:  ... __android_log_print("Panda", "Unable decrypt the certificate")
58c68:  ldr     x0, [sp, #0x18]
58c6c:  b       0x58b4c               ; rejoin error path A at free()
```

## Reconstructed control flow

```c
if (!base64_decode(in, in + n, buf, &buf_len)) {
    LOGE("Can not encode the base64 certificate ");
    goto fail_free;                                   // path A
}
if (!DecryptData(&buf, buf_len, mode, NULL, s2) &&
    !DecryptData(&buf, buf_len, mode, s1,   s2)) {   // try, then retry
    LOGE("Unable decrypt the certificate");
    goto fail_free;                                   // path C
}
if (GetXmlAtribute(buf, "encryptionKey", attr)) {
    base64_decode(attr, attr + strlen(attr), result, &result_len);
} else {
    LOGE("Licence file has wrong format");             // path B
}
free(buf);
goto release;
fail_free:
    free(buf);
    result_len = 0;
release:
    if (j1) env->ReleaseStringUTFChars(j1, s0);
    if (j2) env->ReleaseStringUTFChars(j2, s1);
    if (j3) env->ReleaseStringUTFChars(j3, s2);
    return result_len >= 1 ? to_byte_array(env, result, result_len) : NULL;
```

## Notes

- **Compared with the textbook shapes.** [[If-Else-As-Branches]] and [[Short-Circuit-Conditions-And-CCMP]] show one condition at a time. Real resource-handling code is dominated by a different pattern: *many exits converging on shared cleanup*, the compiled form of `goto cleanup;` (or of C++ destructors). Find the cleanup chain first — it's the block that releases everything acquired at the top — and every error path becomes "log, then jump into the chain".
- **`bool` results tested with `tbz`/`tbnz #0`.** `DecryptData` returns a C++ `bool`; only bit 0 is meaningful, so the compiler tests that bit instead of comparing the whole register ([[CBZ-CBNZ-And-TBZ-TBNZ]]).
- **Try-then-retry is `a || b`.** Attempt 1's success branch skips attempt 2; attempt 2's failure branch goes to the error. That's the `||` shape from the basic example, with calls instead of comparisons.
- **Jumping into the middle of the chain.** At `0x58c48` the join path re-tests `x22` itself and then enters the chain *after* its first test (`0x58b58` or `0x58b70`). The compiler duplicated one test to save a branch; don't misread it as a second, different cleanup sequence.
- **Independent `if`s are not `else if`s.** Each `cbz xN, next` skips exactly one release and falls into the next test. No path skips more than one block — that's how you tell a sequence of guards from a nested chain.
- **Logging as documentation.** `w0 = 6` is `ANDROID_LOG_ERROR`, `x1` the tag (`"Panda"`), `x2` the message. Error strings label each branch for free; in a stripped binary, `__android_log_print` call sites are often the fastest way to name blocks.

## See also

- [[Control-Flow-Patterns]]
- [[Short-Circuit-Conditions-And-CCMP]]
- [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]] — the canary check in this function's epilogue works the same way
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
