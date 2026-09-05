Java.perform(function () {
  // Intercept calls to Log.d() to inspect the stack trace.
  var Log = Java.use("android.util.Log");
  // Intercept calls to Exception.printStackTrace() to inspect the stack trace.
  var Exception = Java.use("java.lang.Exception");

  // Helper function to print the stack trace of an exception.
  function printStackTrace(message) {
    console.log(`\n=====================================================`);
    console.log(`[?] ${message}`);
    // Generate a false exception only to read its trace.
    var trace = Log.getStackTraceString(Exception.$new());
    console.log(trace);
    console.log(`=====================================================\n`);
  }

  // 1. Capture every single URL created.
  var URL = Java.use(`java.net.URL`);
  // Intercept URL constructor to log every URL created.
  URL.$init.overload(`java.lang.String`).implementation = function (url) {
    // Ignore system URLs calls (xml, android, etc) to avoid spam.
    if (!url.startsWith("jar:") && !url.startsWith("file:")) {
      printStackTrace(`Someone prepared this URL: ${url}`);
    }

    return this.$init(url);
  }
})
