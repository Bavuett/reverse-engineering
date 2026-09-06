Java.perform(function () {
  console.log(`[*] Starting Dynamic Inspection on FirebasePerfOkHttpClient`);

  var TargetClass = Java.use("com.google.firebase.perf.network.FirebasePerfOkHttpClient");

  TargetClass.a.overloads.forEarch(function (overload) {
    overload.implementation = function () {
      console.log(`\n===================================================`);
      console.log(`[!] Call to FirebasePerfOkHttpClient.a()`);
      console.log("=====================================================\n");
      return overload.apply(this, arguments);
    }
  })
})
