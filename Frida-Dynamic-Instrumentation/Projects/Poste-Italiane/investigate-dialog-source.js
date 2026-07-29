Java.perform(() => {
  // android.app.Dialog.show() is the common ancestor for AlertDialog (both
  // android.app.* and androidx.appcompat.*) AND for Jetpack Compose dialogs
  // (Compose's AlertDialog/Dialog wraps androidx.compose.ui.window.DialogWrapper,
  // which itself extends android.app.Dialog) -- so hooking this one method
  // catches every dialog implementation regardless of UI toolkit used.
  function printStack(tag) {
    const Exception = Java.use("java.lang.Exception");
    const stack = Exception.$new().getStackTrace();
    for (let i = 0; i < Math.min(stack.length, 25); i++) {
      console.log(`    [${tag}] ` + stack[i].toString());
    }
  }

  const Dialog = Java.use("android.app.Dialog");
  Dialog.show.implementation = function () {
    console.log(`\n[DIALOG.show] class = ${this.getClass().getName()}`);
    try {
      const context = this.getContext();
      console.log(`[DIALOG.show] context = ${context}`);
    } catch (e) {}
    printStack("DIALOG.show");
    return this.show();
  };

  try {
    const DialogFragment = Java.use("androidx.fragment.app.DialogFragment");
    DialogFragment.show.overload(
      "androidx.fragment.app.FragmentManager",
      "java.lang.String",
    ).implementation = function (fm, tag) {
      console.log(`\n[DIALOGFRAGMENT.show] class = ${this.getClass().getName()}, tag = ${tag}`);
      printStack("DIALOGFRAGMENT.show");
      return this.show(fm, tag);
    };
  } catch (e) {
    console.log(`[!] DialogFragment hook failed: ${e}`);
  }

  // In case the warning is rendered inside a WebView instead of native
  // Views/Compose (this app leans heavily on WebView for some flows)
  try {
    const WebView = Java.use("android.webkit.WebView");
    WebView.loadUrl.overload("java.lang.String").implementation = function (url) {
      console.log(`[WEBVIEW.loadUrl] ${url}`);
      return this.loadUrl(url);
    };
    WebView.loadDataWithBaseURL.implementation = function (
      baseUrl,
      data,
      mimeType,
      encoding,
      historyUrl,
    ) {
      console.log(`[WEBVIEW.loadDataWithBaseURL] baseUrl=${baseUrl}`);
      if (data && data.length < 4000) {
        console.log(`[WEBVIEW.loadDataWithBaseURL] data:\n${data}`);
      }
      return this.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
    };
  } catch (e) {
    console.log(`[!] WebView hook failed: ${e}`);
  }
});
