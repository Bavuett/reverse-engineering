// hook_encryptionprovider.js
Java.perform(function () {
  const CordovaActivity = Java.use("org.apache.cordova.CordovaActivity");
  const MainActivity = Java.use("net.pluservice.tua.MainActivity");

  MainActivity.onPause.implementation = function () {
    CordovaActivity.onPause.call(this); // salta la trappola, chiama solo la logica reale
  };

  MainActivity.onResume.implementation = function () {
    CordovaActivity.onResume.call(this);
  };

  console.log(
    "[*] MainActivity.onPause/onResume neutralizzati (bypass trappola div/0)",
  );

  const EncryptionProvider = Java.use(
    "net.pluservice.plugins.KeyKeeper.EncryptionProvider",
  );

  // encrypt(String) -> String   (riga 6699)
  EncryptionProvider.encrypt.overload("java.lang.String").implementation =
    function (plaintext) {
      const result = this.encrypt(plaintext);
      console.log("[encrypt] IN : " + plaintext);
      console.log("[encrypt] OUT: " + result);
      return result;
    };

  // decrypt(String) -> String   (riga 6449)
  EncryptionProvider.decrypt.overload("java.lang.String").implementation =
    function (ciphertext) {
      const result = this.decrypt(ciphertext);
      console.log("[decrypt] IN : " + ciphertext);
      console.log("[decrypt] OUT: " + result);
      return result;
    };

  // decryptRecovery(String) -> String   (riga 6533)
  EncryptionProvider.decryptRecovery.overload(
    "java.lang.String",
  ).implementation = function (ciphertext) {
    const result = this.decryptRecovery(ciphertext);
    console.log("[decryptRecovery] IN : " + ciphertext);
    console.log("[decryptRecovery] OUT: " + result);
    return result;
  };

  // decryptDataWithKey(String, String) -> String   (privato, riga 1766)
  EncryptionProvider.decryptDataWithKey.overload(
    "java.lang.String",
    "java.lang.String",
  ).implementation = function (data, key) {
    const result = this.decryptDataWithKey(data, key);
    console.log("[decryptDataWithKey] key : " + key);
    console.log("[decryptDataWithKey] data: " + data);
    console.log("[decryptDataWithKey] OUT : " + result);
    return result;
  };

  console.log("[*] EncryptionProvider hooks installati");
});
