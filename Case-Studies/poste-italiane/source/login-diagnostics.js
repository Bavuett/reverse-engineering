/*
 * Poste Italiane (com.posteitaliane.spim) — login failure diagnostics.
 *
 * Load alongside the other two scripts once the app is past splash:
 *   frida -U -f com.posteitaliane.spim \
 *         -l root-and-frida-hiding.js -l http-pinning-bypass-and-dump.js -l login-diagnostics.js \
 *         -q -t inf
 *
 * Purpose: the login flow (it.posteitaliane.df_sessionmanager.LoginViewModel /
 * SessionManagerRepository / PassKeyRepository) is FIDO2/WebAuthn-based
 * (com.google.android.gms.fido.fido2), and its request/response bodies are
 * JWE-encrypted at the application layer — so TLS interception alone
 * (http-pinning-bypass-and-dump.js) shows encrypted blobs, not the actual
 * error. This script hooks the specific Java methods that decide *why* login
 * failed and prints their arguments plus a full stack trace, found by
 * enumerating LoginViewModel's declared methods for the two most likely
 * error-surfacing ones: showLoginFailedError(String, String) and
 * checkErrorCode(String, String, Context, String, OpenIdSubjectEnum).
 */

Java.perform(() => {
    const getStackTrace = () => {
        const Log = Java.use("android.util.Log");
        const Exception = Java.use("java.lang.Exception");
        return Log.getStackTraceString(Exception.$new());
    };

    // ---------------------------------------------------------------------
    // The methods most likely to be the direct source of a visible login
    // error message, found via LoginViewModel.class.getDeclaredMethods().
    // ---------------------------------------------------------------------
    try {
        const LoginViewModel = Java.use("it.posteitaliane.df_sessionmanager.LoginViewModel");

        LoginViewModel.showLoginFailedError.implementation = function (a, b) {
            console.log(`\n[login-diag] LoginViewModel.showLoginFailedError("${a}", "${b}")`);
            console.log(getStackTrace());
            return this.showLoginFailedError(a, b);
        };

        LoginViewModel.checkErrorCode.implementation = function (code, msg, ctx, tag, subject) {
            console.log(`\n[login-diag] LoginViewModel.checkErrorCode(code="${code}", msg="${msg}", tag="${tag}", subject=${subject})`);
            console.log(getStackTrace());
            return this.checkErrorCode(code, msg, ctx, tag, subject);
        };

        LoginViewModel.handlePosteIdErrorCode.implementation = function (code) {
            console.log(`\n[login-diag] LoginViewModel.handlePosteIdErrorCode("${code}")`);
            console.log(getStackTrace());
            return this.handlePosteIdErrorCode(code);
        };

        LoginViewModel.showBlockedAccessPopup.overload("android.content.Context", "boolean").implementation = function (ctx, b) {
            console.log(`\n[login-diag] LoginViewModel.showBlockedAccessPopup(isTemporary=${b}) — device/account was BLOCKED, not just a wrong password`);
            console.log(getStackTrace());
            return this.showBlockedAccessPopup(ctx, b);
        };

        LoginViewModel.postAntiFraudLockedEvent.implementation = function (s) {
            console.log(`\n[login-diag] LoginViewModel.postAntiFraudLockedEvent("${s}") — ANTI-FRAUD LOCK triggered`);
            console.log(getStackTrace());
            return this.postAntiFraudLockedEvent(s);
        };

        LoginViewModel.postPosteIdLockedEvent.implementation = function () {
            console.log("\n[login-diag] LoginViewModel.postPosteIdLockedEvent() — PosteID locked");
            console.log(getStackTrace());
            return this.postPosteIdLockedEvent();
        };

        LoginViewModel.postUserTemporaryLockedEvent.implementation = function () {
            console.log("\n[login-diag] LoginViewModel.postUserTemporaryLockedEvent() — user temporarily locked");
            console.log(getStackTrace());
            return this.postUserTemporaryLockedEvent();
        };

        LoginViewModel.showGenericError.implementation = function () {
            console.log("\n[login-diag] LoginViewModel.showGenericError()");
            console.log(getStackTrace());
            return this.showGenericError();
        };

        LoginViewModel.showNetworkError.implementation = function (ctx, a, b) {
            console.log(`\n[login-diag] LoginViewModel.showNetworkError("${a}", "${b}")`);
            console.log(getStackTrace());
            return this.showNetworkError(ctx, a, b);
        };

        LoginViewModel.getBundleDeviceError.implementation = function () {
            const result = this.getBundleDeviceError();
            console.log(`\n[login-diag] LoginViewModel.getBundleDeviceError() -> ${result}`);
            console.log(getStackTrace());
            return result;
        };

        console.log("[+] Hooked LoginViewModel error-path methods (showLoginFailedError, checkErrorCode, handlePosteIdErrorCode, showBlockedAccessPopup, postAntiFraudLockedEvent, postPosteIdLockedEvent, postUserTemporaryLockedEvent, showGenericError, showNetworkError, getBundleDeviceError)");
    } catch (e) {
        console.log(`[!] LoginViewModel hooks not applied: ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // PostePasskeyThrowable and every nested subclass — the concrete
    // passkey/FIDO2 error hierarchy. Each subclass constructor takes
    // (errorCode: String, errorMessage: String); hooking all of them found by
    // enumerating loaded classes avoids missing one that isn't hardcoded here.
    //
    // These classes are loaded lazily by the app's own classloader, only once
    // the passkey flow actually starts — enumerating once right after
    // Java.perform() (at spawn time, before the user has navigated anywhere)
    // reliably misses all of them. Retrying the same scan a few times over the
    // following ~30s catches the classes once they load, without needing to
    // hook the classloader itself.
    // ---------------------------------------------------------------------
    const hookedPasskeyThrowables = new Set();
    const hookPasskeyThrowables = () => {
        Java.enumerateLoadedClasses({
            onMatch(name) {
                if (name.indexOf("PostePasskeyThrowable$") === -1) return;
                if (hookedPasskeyThrowables.has(name)) return;
                try {
                    const Cls = Java.use(name);
                    if (Cls.$init.overloads.some((ov) => ov.argumentTypes.length === 2)) {
                        Cls.$init.overload("java.lang.String", "java.lang.String").implementation = function (code, msg) {
                            console.log(`\n[login-diag] ${name}(errorCode="${code}", errorMessage="${msg}")`);
                            console.log(getStackTrace());
                            return this.$init(code, msg);
                        };
                        hookedPasskeyThrowables.add(name);
                        console.log(`[+] Hooked ${name} constructor`);
                    }
                } catch (e) {
                    // Not every matched class is directly hookable (e.g. abstract base) — skip silently.
                }
            },
            onComplete() {},
        });
    };

    hookPasskeyThrowables();
    for (let i = 1; i <= 10; i++) {
        setTimeout(hookPasskeyThrowables, i * 3000);
    }
});
