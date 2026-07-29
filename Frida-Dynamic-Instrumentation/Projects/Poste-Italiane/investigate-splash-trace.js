Java.perform(() => {
  // Generic "hook every declared method of one class" tracer -- reimplements
  // what frida-trace does, but scoped to SplashActivity so we can see, in
  // call order, everything it does during onResume() before it decides to
  // build/show the "OS not genuine" dialog (obfuscated as s.c, built via the
  // obfuscated androidx.appcompat.app.c.c helper -- see investigate-dialog-source.js).
  function safeStr(v) {
    try {
      return v === null || v === undefined ? String(v) : v.toString();
    } catch (e) {
      return `<unstringifiable: ${e}>`;
    }
  }

  function traceAllMethods(className, tag) {
    const Cls = Java.use(className);
    const methodNames = new Set();
    Cls.class.getDeclaredMethods().forEach((m) => methodNames.add(m.getName()));

    methodNames.forEach((name) => {
      try {
        Cls[name].overloads.forEach((ov) => {
          ov.implementation = function (...args) {
            const argStr = args.map(safeStr).join(", ");
            console.log(`[${tag}] -> ${name}(${argStr})`);
            const ret = ov.apply(this, args);
            console.log(`[${tag}] <- ${name} = ${safeStr(ret)}`);
            return ret;
          };
        });
      } catch (e) {
        console.log(`[!] ${tag}: could not hook ${name}: ${e}`);
      }
    });
  }

  traceAllMethods("it.posteitaliane.df_home.splash.SplashActivity", "SplashActivity");
  traceAllMethods("it.posteitaliane.df_home.splash.SplashViewModel", "SplashViewModel");
  traceAllMethods("androidx.appcompat.app.c", "androidx.appcompat.app.c");

  // s.c's constructor AND every other method it declares -- not just <init>,
  // in case the actual "should this show real content" check happens inside
  // an onCreate/onStart-style lifecycle callback of the dialog itself rather
  // than in the caller.
  try {
    const DialogClass = Java.use("s.c");
    DialogClass.$init.overloads.forEach((ov) => {
      ov.implementation = function (...args) {
        console.log(`[s.c.<init>] args = ${args.map(safeStr).join(" | ")}`);
        return ov.apply(this, args);
      };
    });
  } catch (e) {
    console.log(`[!] Could not hook s.c constructor: ${e}`);
  }
  traceAllMethods("s.c", "s.c");
});
