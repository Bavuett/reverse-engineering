---
tags: [example]
level: 1
aliases: ["frida -f vs -n", "spawn vs attach"]
created: 2026-11-12
---

# Example: Spawn-Vs-Attach-Timing

> [!info] Level 1 — basics
> One idea: attaching hooks a process that has already run its startup code; spawning starts the process suspended so hooks are in place before the first line of app code.

## Goal

Show, with one script run both ways, why some hooks "never fire" when attached and how spawn mode fixes it. Belongs to [[Frida-Fundamentals]].

## Script (`startup.js`)

```javascript
Java.perform(() => {
    const App = Java.use("android.app.Application");
    App.onCreate.implementation = function () {
        console.log(`[*] Application.onCreate for ${this.getPackageName()}`);
        return this.onCreate();
    };

    const Activity = Java.use("android.app.Activity");
    Activity.onResume.implementation = function () {
        console.log(`[*] onResume: ${this.getClass().getName()}`);
        return this.onResume();
    };
});
```

## Running it both ways

```text
# Attach to an app that's already open
$ frida -U -n "MyApp" -l startup.js
[*] onResume: com.example.MainActivity          <- only after switching away and back
                                                   (Application.onCreate never prints)

# Spawn: Frida starts the app suspended, loads the script, then resumes it
$ frida -U -f com.example.app -l startup.js
[*] Application.onCreate for com.example.app
[*] onResume: com.example.MainActivity
```

## Step by step

1. **Attach (`-n`/`-p`)**: the process is running; `Application.onCreate`, content-provider initialization, and static initializers have already executed. Hooks only catch *future* calls.
2. **Spawn (`-f <package>`)**: Frida launches the package with its main thread paused, injects the agent, runs the script, and resumes (Frida 16+ resumes automatically; older versions needed `--no-pause`). Every startup path runs under your hooks.
3. **What runs before `Application.onCreate`**: `ContentProvider.onCreate` for every declared provider (many SDKs initialize there), `Application.attachBaseContext`, and `<clinit>` of whatever those touch. Security checks hidden in any of these are invisible to an attached script.
4. **Rule of thumb**: spawn for anything touching startup, anti-tamper, root detection, or pinning setup; attach for exploring a screen that's already open, or when restarting would lose state ([[Reattaching-Without-Losing-Session-State]]).
5. **Lazily-loaded classes** are a third timing problem that spawn doesn't fix: a class not yet loaded can't be `Java.use`d even in spawn mode — see [[Hooking-A-Lazily-Loaded-Class-With-A-Retry-Loop]].

## Compared with real code

The TUA case study's root-check bypass only works spawned. Its script header (translated from Italian) explains why:

```javascript
/*
 * IMPORTANT: run in SPAWN mode (-f), not attach, because
 * FirebaseInitProvider.onCreate() runs in handleBindApplication(), BEFORE
 * any Application.onCreate()/Activity: if the process has already started
 * when we attach, the check has already fired.
 *
 * Usage:
 *   frida -U -f <package> -l neutralize_root_check.js --no-pause
 */
```

The full script is dissected in [[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]].

## See also

- [[Frida-Fundamentals]]
- [[First-Script-Attach-And-Enumerate]]
- [[Java-Layer-Hooking]]
- [[Anti-Detection-And-Gadget-Mode]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
