---
tags: [snippet]
level: 3
project: "ClasseViva (eu.spaggiari.classevivastudente)"
source: "eu.spaggiari.classevivastudente — Flutter (Dart AOT) Android app, libapp.so disassembled with Blutter"
version: "unknown (not recorded alongside the imported files)"
source_path: "libapp.so: _AuthenticationService.login (0x7249bc) and _$LoginRequestJTOToJson (0x725870), Blutter output core/auth/authentication_service.dart and login_request_jto.dart"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Small fragment kept to illustrate one tracing pattern. Check the app's ToS before any redistribution."
---

# Stalking-A-Dart-AOT-Login-Path-In-ClasseViva

> [!info] Level 3 — real code
> Stalker applied to Dart AOT code reached only by offset: the Blutter listing of ClasseViva's `login()` names every callee, so a scoped call trace can be labeled with Dart method names and compared with the static call order.

> [!warning] Static expectation, not a captured run
> The callee order below is read from the Blutter disassembly; it is the reference a real trace is compared against, not recorded output.

## Context

ClasseViva's `_AuthenticationService.login` (at `libapp.so + 0x7249bc`) has no export; its entry was hooked by offset in [[Attaching-At-A-Dart-AOT-Entry-Offset]]. Blutter annotates every `bl` in its body with the callee's Dart name, so the static call order is unusually readable — and so is the matching dynamic trace, once offsets are mapped back to those names. Part of [[ClasseViva-Case-Study]].

## Original path

`authentication_service.dart` (Blutter output for `_AuthenticationService.login`), the section that builds and sends the request:

```text
0x724a34: bl #0x7e86ec   ; InitAsyncStub
0x724a44: bl #0x6e0e60   ; Map::Map._fromLiteral          (headers map)
0x724ad4: bl #0x6e0e60   ; Map::Map._fromLiteral          (body map)
0x724ae0: bl #0x725870   ; _$LoginRequestJTOToJson
0x724aec: bl #0x1098f0c  ; _Map::addAll
0x724af0: bl #0x75b7fc   ; AllocateOptionsStub -> Options
0x724b4c: bl #0x752c40   ; Options::compose                ("rest/v1/auth/login", "POST")
0x724b9c: bl #0x725730   ; _AuthenticationService::_setStreamType
0x724bb4: bl #0x71a7a4   ; DioMixin::fetch
0x724bc0: bl #0x7e84ac   ; AwaitStub
```

and `login_request_jto.dart`, the serializer called at `0x724ae0` (`0x725870`, size `0xb0`), which loads the four fields `+0x7`, `+0xb`, `+0xf`, `+0x13` (tagged offsets of `uid`, `pass`, `ident`, `otp`) and ends in one call, `bl #0x6e0e60 Map._fromLiteral`.

## Snippet

```javascript
const lib = Process.getModuleByName("libapp.so");
const LOGIN = 0x7249bc;

const names = new Map([                          // offsets taken from the Blutter listing above
    [0x6e0e60, "Map._fromLiteral"], [0x725870, "_$LoginRequestJTOToJson"],
    [0x1098f0c, "_Map.addAll"], [0x75b7fc, "AllocateOptionsStub"], [0x752c40, "Options.compose"],
    [0x725730, "_setStreamType"], [0x71a7a4, "Dio.fetch"], [0x7e86ec, "InitAsyncStub"], [0x7e84ac, "AwaitStub"],
]);

Interceptor.attach(lib.base.add(LOGIN), {
    onEnter() {
        this.tid = Process.getCurrentThreadId();
        const seq = this.seq = [];
        Stalker.follow(this.tid, {
            events: { call: true },
            onReceive(ev) {
                for (const [, , to, depth] of Stalker.parse(ev)) {
                    const off = ptr(to).sub(lib.base).toUInt32();
                    if (depth === 1 && names.has(off)) seq.push(names.get(off));
                }
            }
        });
    },
    onLeave() {
        Stalker.unfollow(this.tid);
        Stalker.flush();
        setTimeout(() => console.log(`[login] ${this.seq.join(" -> ")}`), 100);
    }
});
```

## Reconstructed source

What the Blutter call order corresponds to in Dart (a Retrofit/Dio-generated service method):

```dart
Future<LoginJTO> login(LoginRequestJTO request) async {
  final headers = <String, dynamic>{};
  final data = <String, dynamic>{};
  data.addAll(_$LoginRequestJTOToJson(request));     // {uid, pass, ident, otp}
  final result = await _dio.fetch(_setStreamType<LoginJTO>(
      Options(method: 'POST', headers: headers)
          .compose(_dio.options, 'rest/v1/auth/login', data: data)));
  return LoginJTO.fromJson(result.data!);
}
```

## Notes

- **`async` splits the trace.** `InitAsyncStub` and `AwaitStub` mean `login` is a Dart `async` function: the call at `0x7249bc` runs up to the first `await` and returns a `Future`; the code after `AwaitStub` resumes later, possibly in a different invocation of the same compiled body. Expect the first trace to end at `Dio.fetch`/`AwaitStub`, and the response-handling half (from `0x724bc4` on) to show up in a *later* call.
- **Names make Dart traces readable.** Raw Dart AOT call targets are meaningless offsets in one huge `libapp.so`; the `names` map built from Blutter's comments is what turns the trace into the Dart call order. Without it, filter to `libapp.so`'s range and label offsets afterwards.
- **Not AAPCS64.** Dart passes arguments in its own registers (here `x1`/`x2` at entry), so the trace is the useful view of *what* is called; reading *arguments* requires the register/decompression handling in [[Attaching-At-A-Dart-AOT-Entry-Offset]] and [[Compressed-Pointer-Decompression-Step-By-Step]].
- **Tagged field offsets.** `_$LoginRequestJTOToJson` loads `[x1, #7]`, `[x1, #0xb]`, … — Dart heap pointers are tagged (+1), so these are fields at `+0x8`, `+0xc`, `+0x10`, `+0x14` of the object, matching the 0x18-byte `_LoginRequestJTO` ([[Dart-Object-Header-And-Field-Offsets]]).
- **The coverage alternative.** Diffing block coverage of a login attempt against an idle run would surface the same functions without knowing any offsets in advance ([[Coverage-Diff-To-Locate-A-Feature]]); with Blutter output available, the targeted trace is quicker.

## See also

- [[Stalker-And-Code-Tracing]]
- [[Hooking-Dart-AOT-Login-With-Frida]]
- [[Flutter-Dart-AOT]] in [[ARM64-Android]]
- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
