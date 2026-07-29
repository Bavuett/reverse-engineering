Java.perform(() => {
  const keywords = ["genuin", "responsab", "compromes", "manomess", "root", "integrit", "sicur"];

  function matches(text) {
    if (!text) return false;
    const lower = text.toString().toLowerCase();
    return keywords.some((k) => lower.includes(k));
  }

  function printStack(tag) {
    const Exception = Java.use("java.lang.Exception");
    const stack = Exception.$new().getStackTrace();
    console.log(`[${tag}] stack:`);
    for (let i = 0; i < Math.min(stack.length, 15); i++) {
      console.log("    " + stack[i].toString());
    }
  }

  try {
    const TextView = Java.use("android.widget.TextView");
    TextView.setText.overload("java.lang.CharSequence").implementation = function (text) {
      if (matches(text)) {
        console.log(`\n[TEXTVIEW] "${text}"`);
        printStack("TEXTVIEW");
      }
      return this.setText(text);
    };
  } catch (e) {
    console.log(`[!] TextView hook failed: ${e}`);
  }

  try {
    const AlertBuilder = Java.use("androidx.appcompat.app.AlertDialog$Builder");
    AlertBuilder.setMessage.overload("java.lang.CharSequence").implementation = function (text) {
      console.log(`\n[ALERT-MSG] "${text}"`);
      printStack("ALERT-MSG");
      return this.setMessage(text);
    };
  } catch (e) {
    console.log(`[!] androidx AlertDialog.Builder hook failed: ${e}`);
  }

  try {
    const AlertBuilder2 = Java.use("android.app.AlertDialog$Builder");
    AlertBuilder2.setMessage.overload("java.lang.CharSequence").implementation = function (text) {
      console.log(`\n[ALERT-MSG] "${text}"`);
      printStack("ALERT-MSG");
      return this.setMessage(text);
    };
  } catch (e) {
    console.log(`[!] android AlertDialog.Builder hook failed: ${e}`);
  }
});
