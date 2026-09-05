/*
 * Poste Italiane (com.posteitaliane.spim) — SSL pinning bypass + HTTP request/response dump.
 *
 * Usage:
 *   frida -U -f com.posteitaliane.spim -l http-pinning-bypass-and-dump.js --no-pause
 *   (or attach to an already-running process with -p/-n instead of -f/--no-pause)
 *
 * What it does, in order of how traffic actually flows through the app:
 *   1. Neutralizes certificate/pin validation at four independent layers, so whichever
 *      networking stack the app actually uses (OkHttp, plain HttpsURLConnection, an in-app
 *      WebView, or this app's own custom SSLInterceptor) still completes its TLS handshake
 *      against a MITM proxy's certificate.
 *   2. Logs every OkHttp request/response pair (method, URL, headers, body) at the point
 *      where the app's own interceptor chain sees them — i.e. already decoded, regardless of
 *      whether the wire protocol was HTTP/1.1 or HTTP/2.
 *   3. Hooks this app's bundled Nimbus JOSE+JWT library (com.nimbusds.jose.JWEObject) to
 *      recover the plaintext behind any JWE-encrypted body logged in step 2 — see
 *      [[Decrypting-JWE-Request-Response-Bodies]] for why offline decryption of the
 *      RSA-OAEP-256-wrapped ciphertext isn't feasible and this hook-the-library approach is
 *      used instead. Decrypted plaintext is printed directly under the request/response body
 *      it belongs to wherever the timing allows (always true for request bodies, since
 *      encryption happens before the request is sent; response bodies are decrypted by the
 *      app's own business logic *after* this script's response hook already logged the
 *      ciphertext, so that plaintext is instead printed, tagged with its URL, as soon as
 *      decryption actually happens — see the queueing comment above requestJwe/responseJwe).
 *   4. Falls back to a native SSL_write/SSL_read hexdump (see [[Network-Interception]]) for
 *      any traffic that never goes through OkHttp's Java-visible chain at all.
 */

// Set to false to install only the pinning bypasses (section 1) and skip the
// request/response logger (section 2) entirely — no RealInterceptorChain hook
// at all, not just silenced logging. Added after a splash-screen ANR traced to
// a Google Datatransport background job timing out (see
// Splash-Screen-ANR-Under-Heavy-Instrumentation.md); this logger reads full
// headers and bodies (including response peekBody()) on every single OkHttp
// call in the process, which is the most expensive hook here — toggle this
// off first when isolating whether logging overhead is what's causing a stall
// elsewhere in the app, independent of whether pinning itself needs bypassing.
const ENABLE_HTTP_LOGGING = true;

// Set to false to suppress file output even when using run.py as the launcher.
// Has no effect when running with plain `frida -l` (console only in that case).
const LOG_TO_FILE = true;

// Mirrors every log line both to the Frida console and, when LOG_TO_FILE is
// true, to the Python run.py launcher via send() so it can persist the line to
// a local timestamped file. Falls back gracefully to console-only when this
// script is loaded directly with `frida -l` (unhandled send() messages are
// silently dropped by the Frida runtime in that mode).
function flog(msg) {
    console.log(msg);
    if (LOG_TO_FILE) {
        send({ type: 'log', line: String(msg) });
    }
}

// ---------------------------------------------------------------------
// JWE plaintext <-> ciphertext correlation.
// A JWE compact token is 5 base64url segments (4 dots) — distinguishes it from a
// plain (unencrypted) signed JWT/JWS, which has 3 segments (2 dots), like the
// Authorization: Bearer access tokens and JWS-signed getPassKeyChallenge responses
// also seen in this app's traffic.
// ---------------------------------------------------------------------
const JWE_TOKEN_RE = /[A-Za-z0-9_-]{16,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*/g;

// Builds a matcher that pairs logged ciphertext (from logRequest/logResponse, which
// only knows a URL and how many JWE-shaped tokens were in the body) with plaintext
// (from the JWEObject encrypt/decrypt hooks below, which only know the plaintext
// itself, not which HTTP call it belongs to). Whichever side arrives second
// immediately triggers a match and a console.log — this makes request-body plaintext
// print synchronously (encryption always precedes the send) while response-body
// plaintext prints as soon as the app's own code actually decrypts it, which is
// necessarily *after* this script already logged that response's ciphertext.
// Ordering is matched FIFO per matcher, which holds for the common sequential case
// but can mismatch under enough concurrent in-flight requests of the same kind —
// each printed line is still tagged with its URL so a mismatch is easy to spot.
function makeJweMatcher(label) {
    const pendingCiphertext = []; // { url } entries, one per JWE-shaped token seen
    const pendingPlaintext = [];  // plaintext strings, one per encrypt()/decrypt() call

    function tryFlush() {
        while (pendingCiphertext.length > 0 && pendingPlaintext.length > 0) {
            const { url } = pendingCiphertext.shift();
            const plaintext = pendingPlaintext.shift();
            // Same single-call pattern as logRequest/logResponse: build the entire
            // block as one string so it can never be split by a concurrent thread.
            const out = `[jwe-decrypted ${label} — ${url}]\n      ${plaintext.replace(/\n/g, '\n      ')}`;
            console.log(out);
        }
    }

    return {
        noteCiphertext(url, bodyText) {
            const matches = bodyText ? bodyText.match(JWE_TOKEN_RE) : null;
            if (!matches) return;
            for (const _ of matches) pendingCiphertext.push({ url });
            tryFlush();
        },
        notePlaintext(plaintext) {
            pendingPlaintext.push(plaintext);
            tryFlush();
        },
    };
}

const requestJwe = makeJweMatcher("request body");
const responseJwe = makeJweMatcher("response body");

Java.perform(() => {
    // ---------------------------------------------------------------------
    // 0. Nimbus JOSE+JWT hook: recovers JWE plaintext at the point this app's own
    // bundled library encrypts/decrypts it. Confirmed live (2026-09-04) via
    // Java.enumerateLoadedClasses for "jose"/"jwe"/"nimbus" — see
    // [[Decrypting-JWE-Request-Response-Bodies]]. encrypt()/decrypt() are both void
    // methods that mutate JWEObject's internal state; the plaintext Payload is
    // readable via getPayload() BEFORE encrypt() runs (it's the input) and only
    // AFTER decrypt() runs (decryption is what populates it).
    // ---------------------------------------------------------------------
    try {
        const JWEObject = Java.use("com.nimbusds.jose.JWEObject");

        JWEObject.encrypt.overload("com.nimbusds.jose.JWEEncrypter").implementation = function (encrypter) {
            let plaintext = null;
          try { plaintext = this.getPayload().toString(); } catch (e) { /* leave null */ }

          // Log the encrypt call details, including the stack trace for debugging purposes.
          let header = null;
          try { header = this.getHeader().toString(); } catch (e) { }

          // Log the encrypt call details, including the stack trace for debugging purposes.
          const encrypterClass = encrypter.$className;

          // Get the stack trace to identify the caller context (useful for debugging).
          // Note: the stack trace is obtained before the encrypt call to avoid interference from concurrent threads.
          const stack = Java.use("android.util.Log")
            .getStackTraceString(Java.use("java.lang.Exception").$new());

          // Log the encrypt call details, including the stack trace for debugging purposes.
          console.log(`[jwe-encrypt]\n  header:   ${header}\n   encrypter: ${encrypterClass}\n  payload:  ${plaintext}\n${stack}`);
          this.encrypt(encrypter);
            if (plaintext !== null) requestJwe.notePlaintext(plaintext);
        };

        JWEObject.decrypt.overload("com.nimbusds.jose.JWEDecrypter").implementation = function (decrypter) {
            this.decrypt(decrypter);
            try { responseJwe.notePlaintext(this.getPayload().toString()); } catch (e) { /* nothing readable */ }
        };

        console.log("[+] Hooked com.nimbusds.jose.JWEObject.encrypt/decrypt");
    } catch (e) {
        console.log(`[!] JWEObject hook not applied (app may not use Nimbus JOSE): ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // 1a. Platform-level bypass: com.android.org.conscrypt.TrustManagerImpl.
    // Covers HttpsURLConnection and anything else built on the platform SSLContext,
    // including OkHttp when it delegates to the platform trust manager instead of
    // (or in addition to) its own CertificatePinner.
    // ---------------------------------------------------------------------
    try {
        const TrustManagerImpl = Java.use("com.android.org.conscrypt.TrustManagerImpl");
        TrustManagerImpl.verifyChain.implementation = function (untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
            console.log(`[pin-bypass] TrustManagerImpl.verifyChain() — accepting chain for host: ${host}`);
            return untrustedChain;
        };
        console.log("[+] Hooked com.android.org.conscrypt.TrustManagerImpl.verifyChain");
    } catch (e) {
        console.log(`[!] TrustManagerImpl hook not applied: ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // 1b. OkHttp-level bypass: CertificatePinner.check(), in case the app pins
    // independently of (or on top of) the platform trust manager above.
    // ---------------------------------------------------------------------
    try {
        const CertificatePinner = Java.use("okhttp3.CertificatePinner");
        // OkHttp 3.x/4.x: check(String, List<Certificate>). OkHttp 5.x renamed the
        // Kotlin-compiled method to check$okhttp — try both signatures.
        ["check", "check$okhttp"].forEach((name) => {
            if (CertificatePinner[name] === undefined) return;
            CertificatePinner[name].overloads.forEach((ov) => {
                ov.implementation = function (...args) {
                    const host = args[0];
                    console.log(`[pin-bypass] CertificatePinner.${name}() — skipping pin check for host: ${host}`);
                    // Do not call the original implementation: a no-op return means "pinned, and it matched".
                };
            });
        });
        console.log("[+] Hooked okhttp3.CertificatePinner.check/check$okhttp");
    } catch (e) {
        console.log(`[!] CertificatePinner hook not applied: ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // 1c. App-specific bypass: it.posteitaliane.df_utils.network.SSLInterceptor.
    // A custom OkHttp Interceptor this app registers on top of (and independently
    // of) CertificatePinner — found by enumerating loaded classes for
    // "SSLInterceptor" after noticing the app's own telemetry logging a
    // "Trusted chain does not end in a TrustAnchor" / SSL1 error from a class by
    // that name, tied to the splash screen's checkConfiguration step. Without
    // this hook the app never gets past its splash screen while Frida's other
    // TLS hooks are active — see [[Embedded-OAuth2-Client-Credentials]] for how
    // this was found. Replacing intercept() with a plain pass-through to
    // chain.proceed() skips whatever manual validation it does internally.
    // ---------------------------------------------------------------------
    try {
        const SSLInterceptor = Java.use("it.posteitaliane.df_utils.network.SSLInterceptor");
        SSLInterceptor.intercept.implementation = function (chain) {
            console.log("[pin-bypass] SSLInterceptor.intercept() — passthrough to chain.proceed()");
            return chain.proceed(chain.request());
        };
        console.log("[+] Hooked it.posteitaliane.df_utils.network.SSLInterceptor.intercept");
    } catch (e) {
        console.log(`[!] SSLInterceptor hook not applied: ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // 1d. WebView bypass: auto-accept TLS errors surfaced to WebViewClient,
    // for any in-app screens rendered through a WebView instead of native UI.
    // ---------------------------------------------------------------------
    try {
        const WebViewClient = Java.use("android.webkit.WebViewClient");
        WebViewClient.onReceivedSslError.implementation = function (view, handler, error) {
            console.log("[pin-bypass] WebViewClient.onReceivedSslError() — proceeding anyway");
            handler.proceed();
        };
        console.log("[+] Hooked android.webkit.WebViewClient.onReceivedSslError");
    } catch (e) {
        console.log(`[!] WebViewClient hook not applied: ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // 1e. Android declarative pinning: android.security.net.config.NetworkSecurityTrustManager.
    // A separate trust manager the platform installs for hosts covered by an app's
    // network_security_config.xml <pin-set> — independent of, and in this app's
    // case apparently NOT routed through, com.android.org.conscrypt.TrustManagerImpl
    // above. Found live (2026-09-04) after two specific hosts — oneapp.poste.it's
    // customer/home and appup.mobile.poste.it's verifyUserStatus — kept failing
    // with "SSLHandshakeException: Trusted chain does not end in a TrustAnchor"
    // even with 1a-1d all active; every OTHER host worked fine with 1a alone. This
    // was the classic missing layer, not a real server-side/network fault: dumping
    // TrustManagerImpl's own declared methods showed only the one verifyChain
    // overload already hooked, ruling out a missed overload there, while
    // NetworkSecurityTrustManager turned out to exist and expose its own parallel
    // checkServerTrusted(...). Hooking every overload here (rather than just
    // checkPins()) covers both the void- and List-returning signatures Android has
    // shipped across versions.
    // ---------------------------------------------------------------------
    try {
        const NetworkSecurityTrustManager = Java.use("android.security.net.config.NetworkSecurityTrustManager");
        const Arrays = Java.use("java.util.Arrays");
        NetworkSecurityTrustManager.checkServerTrusted.overloads.forEach((ov) => {
            ov.implementation = function (...args) {
                console.log("[pin-bypass] NetworkSecurityTrustManager.checkServerTrusted() — bypassing Network Security Config pinning");
                if (ov.returnType.className === "java.util.List") {
                    return Arrays.asList(args[0]); // the input X509Certificate[], "trusted" as-is
                }
                // void overloads: not calling the original is the pass.
            };
        });
        console.log("[+] Hooked android.security.net.config.NetworkSecurityTrustManager.checkServerTrusted");
    } catch (e) {
        console.log(`[!] NetworkSecurityTrustManager hook not applied: ${e.message}`);
    }

    // ---------------------------------------------------------------------
    // 2. OkHttp request/response logger.
    // Hooked on RealInterceptorChain.proceed(Request) rather than on RealCall's
    // execute()/enqueue(), because the exact call class has moved package
    // (okhttp3.RealCall -> okhttp3.internal.connection.RealCall) across OkHttp
    // versions, while RealInterceptorChain has stayed put since 3.x. Every
    // interceptor in the chain re-invokes proceed(), so this hook fires multiple
    // times per logical request/response pair — filtered down to `index === 0`
    // (the outermost invocation, before the app's own interceptors run) to log
    // each pair exactly once.
    // ---------------------------------------------------------------------
    if (ENABLE_HTTP_LOGGING) {
        try {
            const RealInterceptorChain = Java.use("okhttp3.internal.http.RealInterceptorChain");
            const Buffer = Java.use("okio.Buffer");

            RealInterceptorChain.proceed.overload("okhttp3.Request").implementation = function (request) {
                const isOutermost = this.index.value === 0;

                if (isOutermost) {
                    logRequest(request, Buffer);
                }

                // proceed() throwing (timeout, connection reset/refused, host
                // resolution failure, ...) previously vanished silently here — the
                // request got logged, then nothing, no matter which of those it
                // actually was. Logging the exception's own class/message surfaces
                // exactly which one it is instead of leaving a request that just
                // never got an [<<<] response line.
                let response;
                try {
                    response = this.proceed(request);
                } catch (e) {
                    if (isOutermost) {
                        console.log(`[xxx] ${request.method()} ${request.url().toString()} — proceed() threw: ${e.$className || e.name || "?"}: ${e.message}`);
                    }
                    throw e; // still propagate — the app must see its own real failure
                }

                if (isOutermost) {
                    logResponse(response);
                }

                return response;
            };
            console.log("[+] Hooked okhttp3.internal.http.RealInterceptorChain.proceed — dumping HTTP traffic");
        } catch (e) {
            console.log(`[!] OkHttp interceptor hook not applied (app may not use OkHttp): ${e.message}`);
        }
    } else {
        console.log("[+] HTTP logging disabled (ENABLE_HTTP_LOGGING = false) — pinning bypasses only");
    }
});

// Single-quote-escapes a value for safe use inside a '...'-quoted shell argument:
// close the quote, emit an escaped single quote, reopen the quote.
function shQuote(value) {
    return `'${String(value).replace(/'/g, `'\\''`)}'`;
}

function logRequest(request, Buffer) {
    const method = request.method();
    const url = request.url().toString();

    // Accumulate the entire block — headers, body, and curl — into one string
    // before emitting it. logRequest runs on an OkHttp dispatcher thread; if two
    // requests overlap, separate console.log calls would interleave their lines.
    // A single console.log is one atomic Frida message over the control channel,
    // so the full block (including the curl) always arrives intact and together.
    let out = `\n[>>>] ${method} ${url}\n`;

    const headers = request.headers();
    const headerPairs = [];
    for (let i = 0; i < headers.size(); i++) {
        const name = headers.name(i);
        const value = headers.value(i);
        out += `      ${name}: ${value}\n`;
        headerPairs.push([name, value]);
    }

    let bodyText = null;
    const body = request.body();
    if (body !== null) {
        try {
            const buffer = Buffer.$new();
            body.writeTo(buffer);
            bodyText = buffer.readUtf8();
            out += `      [body]\n${bodyText}\n`;
            requestJwe.noteCiphertext(url, bodyText);
        } catch (e) {
            out += `      [body] <unreadable: ${e.message}>\n`;
        }
    }

    // curl — part of the same atomic block so it always accompanies its request
    // and is never displaced by a concurrent request on another dispatcher thread.
    // Skip Content-Length and Host: OkHttp manages these itself and re-sending a
    // stale Content-Length when replaying by hand would just be wrong.
    let curl = `[curl] curl -X ${method} ${shQuote(url)}`;
    for (const [name, value] of headerPairs) {
        if (/^(content-length|host)$/i.test(name)) continue;
        curl += ` \\\n  -H ${shQuote(`${name}: ${value}`)}`;
    }
    if (bodyText !== null) {
        curl += ` \\\n  --data-raw ${shQuote(bodyText)}`;
    }
    out += curl;

    console.log(out.trimEnd());
}

function logResponse(response) {
    const url = response.request().url().toString();

    // Same atomicity fix as logRequest: accumulate the full [<<<] block into one
    // string so concurrent responses never interleave their header/body lines.
    let out = `[<<<] ${response.code()} ${response.message()} — ${url}\n`;

    const headers = response.headers();
    for (let i = 0; i < headers.size(); i++) {
        out += `      ${headers.name(i)}: ${headers.value(i)}\n`;
    }

    const body = response.body();
    if (body !== null) {
        try {
            // peekBody() reads a copy without consuming the original source, so the
            // app still gets its response body afterwards.
            const peeked = response.peekBody(1024 * 1024);
            const bodyText = peeked.string();
            out += `      [body]\n${bodyText}`;
            // Any matching plaintext prints here immediately only if this app's own
            // code already decrypted this exact body before we got around to peeking
            // it (rare); otherwise it appears later, tagged with this URL, from
            // responseJwe's queue once JWEObject.decrypt() actually fires — see the
            // header comment and the makeJweMatcher definition above.
            responseJwe.noteCiphertext(url, bodyText);
        } catch (e) {
            out += `      [body] <unreadable: ${e.message}>`;
        }
    }

    console.log(out.trimEnd());
}

// ---------------------------------------------------------------------
// 3. Native fallback: raw SSL_write/SSL_read hexdump, for traffic that never
// reaches OkHttp's Java-visible interceptor chain (e.g. a native networking
// component, or HTTP/2 push frames outside the request/response model above).
// Commented out by default since the OkHttp logger above is already
// structured and readable when it applies — see [[Network-Interception]] for
// the full explanation of when this layer is actually needed.
// ---------------------------------------------------------------------
/*
const libssl = Process.findModuleByName("libssl.so");
if (libssl !== null) {
    const sslWrite = Module.findExportByName(libssl.name, "SSL_write");
    const sslRead = Module.findExportByName(libssl.name, "SSL_read");

    Interceptor.attach(sslWrite, {
        onEnter(args) {
            const len = args[2].toInt32();
            console.log(`[*] SSL_write (${len} bytes):`);
            console.log(hexdump(args[1], { length: len, ansi: false }));
        }
    });

    Interceptor.attach(sslRead, {
        onEnter(args) { this.buf = args[1]; },
        onLeave(retval) {
            const len = retval.toInt32();
            if (len > 0) {
                console.log(`[*] SSL_read (${len} bytes):`);
                console.log(hexdump(this.buf, { length: len, ansi: false }));
            }
        }
    });
}
*/
