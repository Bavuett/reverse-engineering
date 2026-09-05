Java.perform(function () {
  console.log(`[*] Waiting for FirebasePerfOkHttpClient...`);

  try {
    // 1. Let's point to the FirebasePerfOkHttpClient class, which is not obfuscated.
    var FirebaseClient = Java.use(`com.google.firebase.perf.network.FireBasePerfOkHttpClient`);
    
  }
})
