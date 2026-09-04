---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "root-and-frida-hiding.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Blocking-The-Frida-Control-Port-Scan

## Context

[[Anti-Detection-And-Gadget-Mode]] lists port-scanning `frida-server`'s default control port (27042)
as one of the standard Frida-detection checks, distinct from root detection. This is the concrete
Java-layer implementation used against this app: a self-connect attempt to that port from inside the
app's own process fails loudly (`ConnectException`) instead of succeeding, which is what a detection
check is actually looking for.

## Original path

`` Case-Studies/poste-italiane/source/root-and-frida-hiding.js ``

## Snippet

```javascript
const Socket = Java.use("java.net.Socket");
Socket.connect.overload("java.net.SocketAddress", "int").implementation = function (addr, timeout) {
    const addrStr = addr.toString();
    if (addrStr.includes("27042") || addrStr.includes("27043")) {
        console.log(`[frida-hide] Socket.connect(${addrStr}) -> ConnectException`);
        const ConnectException = Java.use("java.net.ConnectException");
        throw ConnectException.$new("Connection refused");
    }
    return this.connect(addr, timeout);
};
```

### Example — installed alongside the root-hiding hooks, in the same `Java.perform` pass

The full script installs this in a **separate** `Java.perform(() => { ... })` block from the
root-artifact hooks, even though nothing stops them from sharing one:

```javascript
Java.perform(() => {
    const Socket = Java.use("java.net.Socket");
    Socket.connect.overload("java.net.SocketAddress", "int").implementation = function (addr, timeout) {
        const addrStr = addr.toString();
        if (addrStr.includes("27042") || addrStr.includes("27043")) {
            throw Java.use("java.net.ConnectException").$new("Connection refused");
        }
        return this.connect(addr, timeout);
    };
});
```

Splitting Frida-detection hooks from root-detection hooks into their own `Java.perform` call is purely
organizational here (both run at the same point, immediately on script load) — but it keeps the two
*conceptually* separate categories [[Anti-Detection-And-Gadget-Mode]] itself insists on distinguishing
(device state vs. instrumentation-tool presence) visible at a glance in the source file, rather than
interleaved with the root-hiding hooks above it.

## Notes

- Throwing `ConnectException` (rather than, say, silently returning) matters: a detection routine
  checking "is 27042 open" typically does so by attempting a real connect and catching the exception
  that means "closed" — returning cleanly from a hooked `connect()` without throwing would instead read
  as "the port IS open and the connection succeeded," the opposite of the intended lie.
- 27043 is included alongside 27042 since Frida can use an adjacent port for its own auxiliary
  protocol depending on configuration — blocking only the primary port leaves a narrower, still-real
  detection surface open.
- This hook only covers a Java-layer `Socket.connect` self-scan. A native-level scan (a raw `connect()`
  syscall from C code, bypassing `java.net.Socket` entirely) would need a native hook instead — not
  observed as a check this specific app performs, but worth remembering as a gap the same way
  [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]] exists precisely because *that* particular
  check turned out to be native-only.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Java-Layer-Hooking]]
- [[Poste-Italiane]] in [[Case-Studies]]
