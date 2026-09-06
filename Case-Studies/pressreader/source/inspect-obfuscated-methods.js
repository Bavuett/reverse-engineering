Java.perform(function () {
  console.log(`[*] Waiting for FirebasePerfOkHttpClient...`);

  try {
    // 1. Let's point to the FirebasePerfOkHttpClient class, which is not obfuscated.
    var FirebaseClient = Java.use(`com.google.firebase.perf.network.FirebasePerfOkHttpClient`);

    // 2. Since the method `a` could have many variants (overloads), let's find all of them.
    var overloads = FirebaseClient.a.overloads;
    console.log(`[+] Found ${overloads.length} variants of the method 'a'`);

    // 3. Apply the hook on ALL the variants of the 'a' method.
    overloads.forEach(function (overload) {
      overload.implementation = function () {
        console.log(`\n=======================================================`);
        console.log(`[!] Intercepted call to FirebasePerfOkHttpClient.a()`);

        // 4. We analyze all of the arguments passed to the function in real time.
        for (var i = 0; i < arguments.length; i++) {
          var arg = arguments[i];
          if (arg === null) {
            console.log(`   [+] Argument ${i}: [null]`);
          } else if (typeof arg === 'object' && typeof arg.getClass === 'function') {
            // CRUCIAL POINT: we ask the Java VM to tell us the real name of this object's class.
            var className = arg.getClass().getName();
            console.log(`   [+] Argument ${i} is of type ${className}`);
            console.log(`   [+] Value: ${arg.toString()}`);
          } else {
            // Primitives (int/long/boolean/...) come through as plain JS values with no
            // getClass() to call - typeof is the only thing that makes sense here.
            console.log(`   [+] Argument ${i} [primitive, typeof ${typeof arg}]: ${arg}`);
          }
        }

        // 5. Call through to the original implementation so the app keeps working normally.
        // NOTE: calling `overload.apply(...)` here throws "TypeError: not a function" — the
        // element captured from `.overloads` before hooking isn't a valid call-through handle
        // once `.implementation` has been assigned to it. `this.a` is the class-level dispatcher,
        // which Frida resolves back to the original Java implementation when invoked from JS.
        return this.a.apply(this, arguments);
      };
    });
  } catch (e) {
    console.log(`[-] Error: ${e.message}`);
  }
})
