import Java from "frida-java-bridge";
/// <reference types="frida-java-bridge" />

/**
 * We found that PressReader APIs are mainly called from the method bp.m1.m using java.net.HttpUrlConnection instead of using
 * okHttp3 (used by third party libraries instead). For this reason, we are trying to target this method in order to discover
 * what is being sent over the internet.
 *
 * The bp.m1 class is the "Manager" that handles all of the official communication with PressReader servers.
 * From the `e(Service service) and f()` methods we can tell that the app uses XML in order to send messages over the network.
 * `public static HttpUrlConnection a(String str)` shows us that the app gets an URL in string format, opens the connection and
 * sets the timeouts.
 *
 * The engine of the request is located at method `m(com.newspaperdirect.pressreader.android.core.Service r22,
 * java.lang.String r23, int r24, int r25) throws java.lang.Throwable`. Unfortunately, JADX couldn't decompile the body due
 * to its size. But we know that it receives an object Service, a String (likely the URL or the XML payload) and two integer
 * numbers (likely the timouts). This is where the request gets sent.
 *
 * The parser is located at `m1`: it initializes some SAX listeners (StartElementListener, EndTextElementListener). This means
 * that when the server actually responds, the app reads the XML and looks for tags like <error-code>, <error-message> or
 * <user-activations>.
 */
Java.perform(() => {
  var Log = Java.use(`android.util.Log`);
  var Exception = Java.use(`java.lang.Exception`);

  function printStackTrace(message: any) {
    console.log(`\n==============================================================`);
    var trace = Log.getStackTraceString(Exception.$new());
    console.log(`[?] ${message}`);
    console.log(`     [+] Stack trace:\n${trace}`);
    console.log(`==============================================================\n`);
  }

  console.log(`[*] Waiting to intercept the PressReader XML APIs (bp.m1)...`);

  const Target = {
    className: `bp`,
    methodName: `m1`
  }

  // 1. Intercept the creation of the XML payload (method f).
  var CoreApi = Java.use(`${Target.className}.${Target.methodName}`);

  CoreApi.f.implementation = function () {
    var XmlPayload = this.f();
    printStackTrace(`[+] Payload generated from method f...\n${XmlPayload}`);
    return XmlPayload;
  };

  // 2. Intercept the creation of the XML payload (method e).
  // Since it accepts a paarameter, we specify the function in a classic way.
  CoreApi.e.implementation = function (serviceObj: any) {
    var xmlPayload = this.e(serviceObj);
    printStackTrace(`[+] Payload generated from method e...\n${xmlPayload}`);
    return xmlPayload;
  }

  // 3. Intercept the main function (method m).
  CoreApi.m.implementation = function (serviceObj: any, stringParam: any, int1: any, int2: any) {
    var message = `
      [+] Calling API (Method m).\n
              [*] Parameter (URL or data): ${stringParam}\n
              [*] Parameter (int1): ${int1}\n
              [*] Parameter (int2): ${int2}
      `
    printStackTrace(message);
    return this.m(serviceObj, stringParam, int1, int2);
  }
})
