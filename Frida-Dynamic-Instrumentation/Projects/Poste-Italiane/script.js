Java.perform(() => {
  // Package/file needles below mirror RootBeer's (com.scottyab.rootbeer) known
  // root/dangerous/cloaking-app constants — this app's checks match that
  // library's lists almost exactly, so it's filled in rather than guessed at.
  const ROOT_PACKAGE_NEEDLES = [
    "magisk",
    "supersu",
    "kingroot",
    "kingo",
    "superuser",
    "su",
    "framaroot",
    "rommanager",
    "oneclickroot",
    "root.global",
    "luckypatcher",
    "lackypatch",
    "appquarantine",
    "InAppBillingService.COIN",
    "InAppBillingService.LUCK",
    "InAppBillingService.LOCK",
    "blackmart",
    "allinone.free",
    "repodroid",
    "creeplays.hack",
    "baseappfull.fwd",
    "zmapp",
    "marketmod",
    "mobilism",
    "wp.net.log",
    "camera.update",
    "madkite",
    "edxposed",
    "xmodgame",
    "game_cih",
    "lpoqasert",
    "catch_.me_.if_.you_.can_",
    "xposed.installer",
    "saurik.substrate",
    "rootcloak",
    "temprootremovejb",
    "hidemyroot",
    "hideroot",
  ];
  const ROOT_FILE_NAMES = ["Superuser.apk", "SuperSU.apk", "busybox", "daemonsu"];

  // 1. Fake "file doesn't exist" for common su paths and known root-app files
  const File = Java.use("java.io.File");
  File.exists.implementation = function () {
    const path = this.getAbsolutePath();

    console.log(`[*] File.exists() called for ${path}`);

    if (
      path.includes("/su") ||
      path.includes("magisk") ||
      ROOT_FILE_NAMES.some((name) => path.endsWith(name))
    ) {
      console.log(`[*] Faking File.exists() = false for ${path}`);
      return false;
    }
    return this.exists();
  };

  // 2. Fake "package not found" for root-manager / cracking / xposed apps
  const PackageManager = Java.use("android.app.ApplicationPackageManager");
  PackageManager.getPackageInfo.overload(
    "java.lang.String",
    "int",
  ).implementation = function (pkg, flags) {
    console.log(`[*] PackageManager: ${pkg} has been checked`);

    if (ROOT_PACKAGE_NEEDLES.some((needle) => pkg.includes(needle))) {
      console.log(`[*] Faking PackageManager: ${pkg} not found`);
      const NameNotFoundException = Java.use(
        "android.content.pm.PackageManager$NameNotFoundException",
      );
      throw NameNotFoundException.$new("not found");
    }
    return this.getPackageInfo(pkg, flags);
  };

  // 3. Fake release build tags
  const Build = Java.use("android.os.Build");
  Build.TAGS.value = "release-keys";

  // 4. Log every OkHttp request (method, url, headers, body)
  const RequestBuilder = Java.use("okhttp3.Request$Builder");
  RequestBuilder.build.implementation = function () {
    const request = this.build();
    console.log(`\n[>>] ${request.method()} ${request.url()}`);
    console.log(`[>>] Headers:\n${request.headers()}`);

    const body = request.body();
    if (body !== null) {
      const Buffer = Java.use("okio.Buffer");
      const buffer = Buffer.$new();
      body.writeTo(buffer);
      console.log(`[>>] Body:\n${buffer.readUtf8()}`);
    }
    return request;
  };

  // 5. Log every OkHttp response (status, headers, body) — peekBody() reads
  //    a copy of the stream so the app can still consume the real one
  const ResponseBuilder = Java.use("okhttp3.Response$Builder");
  ResponseBuilder.build.implementation = function () {
    const response = this.build();
    console.log(
      `\n[<<] ${response.code()} ${response.message()} ${response.request().url()}`,
    );
    console.log(`[<<] Headers:\n${response.headers()}`);
    if (response.body() !== null) {
      console.log(`[<<] Body:\n${response.peekBody(1024 * 1024).string()}`);
    }
    return response;
  };
});
