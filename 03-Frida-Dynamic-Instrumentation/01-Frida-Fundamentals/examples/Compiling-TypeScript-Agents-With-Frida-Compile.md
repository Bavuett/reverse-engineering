---
tags: [example]
level: 2
aliases: ["frida-compile TypeScript", "Frida agent project setup"]
created: 2026-11-12
---

# Example: Compiling-TypeScript-Agents-With-Frida-Compile

> [!info] Level 2 — intermediate
> Moving from a single `.js` file to a typed agent project: `frida-compile` bundles TypeScript and npm packages (including the Java bridge) into one script, and the type definitions catch API mistakes before they crash inside the target.

## Goal

Set up a minimal TypeScript agent project, understand why `frida-java-bridge` is imported explicitly in modern Frida, and know what the compiled output contains. Belongs to [[Frida-Fundamentals]].

## Project layout

```text
agent/
├── package.json
├── tsconfig.json
└── agent.ts          -> compiled to agent.js, which is what `frida -l` loads
```

```json
// package.json
{
  "scripts": {
    "build": "frida-compile agent.ts -o agent.js",
    "watch": "frida-compile agent.ts -o agent.js -w"
  },
  "devDependencies": {
    "@types/frida-gum": "*",
    "frida-compile": "*",
    "frida-java-bridge": "*",
    "typescript": "*"
  }
}
```

```typescript
// agent.ts
import Java from "frida-java-bridge";

function hookUrl(): void {
    const URL = Java.use("java.net.URL");
    URL.$init.overload("java.lang.String").implementation = function (this: Java.Wrapper, spec: string) {
        console.log(`[URL] ${spec}`);
        return this.$init(spec);
    };
}

Java.perform(hookUrl);
```

```text
$ npm install
$ npm run watch                                  # rebuilds agent.js on every save
$ frida -U -f com.example.app -l agent.js        # frida reloads agent.js when it changes
```

## Step by step

1. **Why compile at all.** Frida's runtime executes one JavaScript file. `frida-compile` resolves `import`s, transpiles TypeScript, and bundles everything — your modules and npm packages — into that single file.
2. **Why import the Java bridge.** Since Frida 17, the `Java` (and `ObjC`/`Swift`) bridges are no longer baked into every script runtime; they're npm packages. The `frida` CLI REPL still preloads them for quick experiments, but a compiled agent must `import Java from "frida-java-bridge"`. A script that works in the REPL but fails with `Java is not defined` when loaded from code is usually missing this import.
3. **Types catch mistakes early.** `@types/frida-gum` types `Interceptor`, `Memory`, `NativePointer`, … A typo like `Interceptor.atach` or passing a string where a `NativePointer` is required fails at build time instead of inside the target, where the only symptom might be a silent non-hook.
4. **`function`, not arrow, for implementations.** Frida binds `this` to the Java object for the replacement function; an arrow function would capture the outer `this` instead. In TypeScript, declare it: `function (this: Java.Wrapper, …)`.
5. **The output is large.** The compiled file contains the whole Java bridge — hundreds of kilobytes for a ten-line agent. That's expected; don't hand-edit it, and when grepping a case-study folder for API usage, skip the bundle and read the `.ts` sources.
6. **Watch mode + Frida's auto-reload** make the edit-run loop a couple of seconds: save `agent.ts`, the bundle rebuilds, Frida reloads it into the live process.

## Compared with real code

The PressReader investigation used exactly this setup. Its real `package.json` scripts are `"build": "frida-compile inspector.ts -o inspector.js"` and `"watch": "frida-compile inspector.ts -o inspector.js -w"`, its agents start with `import Java from "frida-java-bridge";`, and the compiled `inspector.js` is about 440 KB for a ~100-line TypeScript source — almost all of it the bundled bridge. A focused agent from that project:

```typescript
import Java from "frida-java-bridge";

Java.perform(() => {
  const m1 = Java.use(`bp.m1`);
  m1.m.implementation = function (service: Java.Wrapper | null, str: string | null, t1: number, t2: number) {
    console.log(`Calling m on bp.m1 with service=${service}, str=${str}, t1=${t1}, t2=${t2}`);
    if (service !== null) {
      console.log(`   f() (service name):   ${service.f()}`);
      console.log(`   j   (user name):      ${service._j.value}`);   // field `j` shadowed by method `j()`
    }
  }
});
```

The `_j.value` syntax — reaching a field whose name collides with a method — is covered in [[Finding-Live-Instances-With-Java-Choose]]. Project context: [[PressReader]], [[Modularizing-Hook-Targets-With-An-Array-Structure]].

## See also

- [[Frida-Fundamentals]]
- [[RPC-Exports-And-Host-Messaging]] — the other half of a larger tooling setup: a host script talking to the agent
- [[Java-Perform-And-Java-Use]]
- [[Frida]] in [[Tools]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
