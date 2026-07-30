/*
 * Script combinato:
 *  1) neutralizza il root-check nascosto in UPCEANExtension2Support.onMessageChannelReady
 *  2) aggancia Log (tutti i livelli) e RuntimeException per stampare lo stack trace di QUALSIASI
 *     messaggio "SCRTYMANAGER" residuo (es. AppDebuggableException), cosi'
 *     vediamo subito da dove parte anche quello, nello stesso avvio.
 *
 * Uso (spawn, non attach):
 *   frida -U -f net.pluservice.tua -l combined.js --no-pause
 */

Java.perform(function () {
    // --- -1) Bypass del certificate pinning applicativo di OkHttp3, per
    //     poter intercettare il traffico con mitmproxy. L'app pinna via
    //     okhttp3.CertificatePinner (visto in PlusNetworking.smali). Il
    //     metodo check() lancia SSLPeerUnverifiedException se il pin non
    //     combacia: qui lo neutralizziamo (no-op = pin sempre accettato).
    //     NB: la CA di mitmproxy va comunque installata sul device (fatto,
    //     come CA utente in /data/misc/user/0/cacerts-added/), perche' il
    //     traffico WebView (non-OkHttp) si affida al trust-store di sistema,
    //     non a questo bypass. ---
    try {
        const CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function (hostname, peerCertificates) {
            console.log('[*] CertificatePinner.check bypassato per host: ' + hostname);
        };
        // Alcune versioni di OkHttp hanno anche l'overload con Certificate...
        try {
            CertificatePinner.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;').implementation = function (hostname, peerCertificates) {
                console.log('[*] CertificatePinner.check (varargs) bypassato per host: ' + hostname);
            };
        } catch (e) { /* overload non presente in questa versione, ignorabile */ }

        console.log('[*] Hook -1/3 installato: okhttp3.CertificatePinner.check bypassato (mitmproxy-ready)');
    } catch (e) {
        console.log('[!] impossibile bypassare CertificatePinner: ' + e);
    }

    // --- 0) Blocca il meccanismo di terminazione stesso: qualunque check
    //     nascosto (root, debuggable, e chissa' quanti altri) alla fine
    //     chiama System.exit(status). Se lo neutralizziamo qui, il check
    //     logga pure il suo messaggio ma il processo resta vivo, senza
    //     dover inseguire ogni singola chiamata reflection una per una. ---
    const Runtime = Java.use('java.lang.Runtime');
    Runtime.exit.implementation = function (status) {
        console.log('[*] Runtime.exit(' + status + ') soppresso');
    };
    Runtime.halt.implementation = function (status) {
        console.log('[*] Runtime.halt(' + status + ') soppresso');
    };

    const Process = Java.use('android.os.Process');
    Process.killProcess.implementation = function (pid) {
        console.log('[*] Process.killProcess(' + pid + ') soppresso');
    };

    console.log('[*] Hook 0/3 installato: Runtime.exit/halt, Process.killProcess neutralizzati');

    // --- 1) Neutralizza TUTTI i nascondigli con firma (JJ)V trovati nell'intero
    //     albero smali (stesso pattern usato ovunque da FirebaseInitProvider
    //     per invocare via reflection i controlli nascosti: root, debuggable,
    //     e chissa' quali altri, dentro classi totalmente estranee) ---
    const HIDDEN_CHECKS = [
        ['android.support.v4.media.MediaBrowserCompatApi26', 'extraCallbackWithResult'],
        ['net.pluservice.plusnetworking.R$anim', 'onNavigationEvent'],
        ['com.google.zxing.RGBLuminanceSource', 'extraCallbackWithResult'],
        ['com.google.zxing.pdf417.decoder.ec.ModulusPoly', 'ICustomTabsCallback'],
        ['com.google.zxing.oned.UPCEANExtension2Support', 'onMessageChannelReady'],
        ['com.google.firebase.R$drawable', 'extraCallbackWithResult'],
        ['com.google.gson.internal.UnsafeAllocator$2', 'extraCallbackWithResult'],
        ['com.google.zxing.client.android.encode.VCardContactEncoder', 'ICustomTabsCallback'],
        ['com.google.android.gms.measurement.internal.zzep', 'extraCallback'],
        ['com.google.android.gms.dynamite.DynamiteModule$LoadingException', 'extraCallbackWithResult'],
        ['com.google.android.gms.common.api.internal.ApiKey', 'onNavigationEvent'],
        ['com.google.android.gms.common.api.internal.zaf', 'ICustomTabsCallback'],
        ['o.setButtonDrawable', 'ICustomTabsCallback'],
        ['o.setImeOptions', 'onNavigationEvent'],
        ['o.setOnSearchClickListener', 'onMessageChannelReady'],
    ];

    let installed = 0;
    HIDDEN_CHECKS.forEach(function (entry) {
        const className = entry[0];
        const methodName = entry[1];
        try {
            const klass = Java.use(className);
            klass[methodName].overload('long', 'long').implementation = function (a, b) {
                console.log('[*] ' + className + '.' + methodName + ' neutralizzato (args=' + a + ', ' + b + ')');
            };
            installed++;
        } catch (e) {
            console.log('[!] impossibile agganciare ' + className + '.' + methodName + ': ' + e);
        }
    });
    console.log('[*] Hook 1/3 installati: ' + installed + '/' + HIDDEN_CHECKS.length + ' metodi-nascondiglio (JJ)V neutralizzati');

    // --- 2) Cattura stack trace di qualunque messaggio SCRTYMANAGER residuo ---
    const Log = Java.use('android.util.Log');
    const Throwable = Java.use('java.lang.Throwable');

    function dumpStack(where, tag, msg) {
        console.log('\n=== [' + where + '] tag="' + tag + '" msg="' + msg + '" ===');
        const stack = Throwable.$new().getStackTrace();
        for (let i = 0; i < stack.length; i++) {
            console.log('    at ' + stack[i].toString());
        }
        console.log('=== fine stack ===\n');
    }

    function matches(tag, msg) {
        return (msg && (msg.indexOf('SCRTY') !== -1 || msg.indexOf('Debuggable') !== -1 || msg.indexOf('Rooted') !== -1))
            || (tag && tag.indexOf('SCRTY') !== -1);
    }

    ['d', 'i', 'w', 'v'].forEach(function (level) {
        try {
            Log[level].overload('java.lang.String', 'java.lang.String').implementation = function (tag, msg) {
                if (matches(tag, msg)) dumpStack('Log.' + level, tag, msg);
                return this[level](tag, msg);
            };
        } catch (e) {
            console.log('overload Log.' + level + '(String,String) non trovato: ' + e);
        }
    });

    Log.e.overload('java.lang.String', 'java.lang.String').implementation = function (tag, msg) {
        if (matches(tag, msg)) dumpStack('Log.e', tag, msg);
        return this.e(tag, msg);
    };

    Log.e.overload('java.lang.String', 'java.lang.String', 'java.lang.Throwable').implementation = function (tag, msg, tr) {
        if (matches(tag, msg)) {
            dumpStack('Log.e(+Throwable)', tag, msg);
            console.log('    Throwable: ' + tr);
        }
        return this.e(tag, msg, tr);
    };

    const RuntimeException = Java.use('java.lang.RuntimeException');
    RuntimeException.$init.overload('java.lang.String').implementation = function (msg) {
        if (matches(null, msg)) {
            console.log('\n=== [RuntimeException.<init>] msg="' + msg + '" ===');
            console.log(Log.getStackTraceString(this));
        }
        return this.$init(msg);
    };

    console.log('[*] Hook 3/3 installato: Log (tutti i livelli) e RuntimeException (filtro SCRTY/Debuggable/Rooted)');

    // --- 4) Logging di tutte le richieste/risposte HTTP (OkHttp3) ---
    // Iniettiamo un Interceptor applicativo in ogni OkHttpClient costruito
    // dall'app (es. net.pluservice.plusnetworking.PlusNetworking). Essendo
    // un interceptor "application", vede la richiesta/risposta finale gia'
    // dentro il processo: il certificate pinning configurato non c'entra,
    // non stiamo facendo MITM di rete.
    try {
        const OkHttpInterceptor = Java.use('okhttp3.Interceptor');
        const OkHttpClientBuilder = Java.use('okhttp3.OkHttpClient$Builder');
        const Buffer = Java.use('okio.Buffer');

        const LoggingInterceptor = Java.registerClass({
            name: 'net.pluservice.tua.FridaLoggingInterceptor',
            implements: [OkHttpInterceptor],
            methods: {
                intercept: function (chain) {
                    const request = chain.request();
                    const url = request.url().toString();
                    const method = request.method();

                    console.log('\n>>> [HTTP REQUEST] ' + method + ' ' + url);
                    const reqHeaders = request.headers();
                    for (let i = 0; i < reqHeaders.size(); i++) {
                        console.log('    ' + reqHeaders.name(i) + ': ' + reqHeaders.value(i));
                    }

                    try {
                        const body = request.body();
                        if (body !== null) {
                            const buffer = Buffer.$new();
                            body.writeTo(buffer);
                            console.log('    body: ' + buffer.readUtf8());
                        }
                    } catch (e) {
                        console.log('    [body richiesta non leggibile: ' + e + ']');
                    }

                    const response = chain.proceed(request);

                    console.log('<<< [HTTP RESPONSE] ' + response.code() + ' ' + url);
                    const respHeaders = response.headers();
                    for (let i = 0; i < respHeaders.size(); i++) {
                        console.log('    ' + respHeaders.name(i) + ': ' + respHeaders.value(i));
                    }

                    try {
                        // peekBody legge una copia senza consumare il body reale,
                        // che l'app deve ancora poter leggere normalmente dopo di noi.
                        const peeked = response.peekBody(1024 * 1024);
                        console.log('    body: ' + peeked.string());
                    } catch (e) {
                        console.log('    [body risposta non leggibile: ' + e + ']');
                    }
                    console.log('');

                    return response;
                }
            }
        });

        const Proxy = Java.use('java.net.Proxy');
        const ProxyType = Java.use('java.net.Proxy$Type');
        const InetSocketAddress = Java.use('java.net.InetSocketAddress');

        OkHttpClientBuilder.build.implementation = function () {
            this.addInterceptor(LoggingInterceptor.$new());
            // Forziamo il proxy esplicitamente sul client: l'impostazione di
            // sistema (settings put global http_proxy) non e' affidabile per
            // tutti gli stack di rete dell'app, quindi non ci affidiamo al
            // ProxySelector di default.
            const proxyAddr = InetSocketAddress.$new('10.0.2.2', 8080);
            const proxy = Proxy.$new(ProxyType.HTTP.value, proxyAddr);
            this.proxy(proxy);
            return this.build(); // chiama l'implementazione originale, non ricorsione
        };

        console.log('[*] Hook 4/4 installato: logging richieste/risposte OkHttp3 (via interceptor iniettato)');
    } catch (e) {
        console.log('[!] impossibile installare il logging OkHttp: ' + e);
    }

    // --- 5) Logging di TUTTE le richieste della WebView (Cordova) ---
    // Cordova e' basata su WebView: le vere chiamate REST fatte da JS
    // (fetch/XHR) passano per lo stack di rete nativo di Chromium, non per
    // l'OkHttp custom sopra. Android richiama shouldInterceptRequest() per
    // OGNI risorsa caricata (pagina, script, XHR, fetch), quindi e' il punto
    // giusto per vedere URL/metodo/header di tutto il traffico WebView.
    //
    // LIMITE NOTO: WebResourceRequest non espone MAI il body delle richieste
    // POST/PUT (limitazione dell'API Android, non aggirabile qui). Per la
    // risposta, se Cordova lascia gestire la richiesta alla WebView (ritorna
    // null), rifacciamo noi la stessa GET in modo sincrono ("shadow fetch")
    // solo per loggare status/header/body, senza intaccare il caricamento
    // reale (la WebView fara' comunque la sua richiesta normalmente).
    try {
        const SystemWebViewClient = Java.use('org.apache.cordova.engine.SystemWebViewClient');
        const URL = Java.use('java.net.URL');
        const MapEntry = Java.use('java.util.Map$Entry');

        function logHeaders(prefix, map) {
            const iterator = map.entrySet().iterator();
            while (iterator.hasNext()) {
                const entry = Java.cast(iterator.next(), MapEntry);
                console.log(prefix + entry.getKey() + ': ' + entry.getValue());
            }
        }

        function shadowFetch(urlStr, method, headersMap) {
            // Solo per GET: per POST/PUT non abbiamo il body originale da
            // rispedire, quindi non avrebbe senso rifare la richiesta.
            if (method !== 'GET') return;
            try {
                const HttpURLConnection = Java.use('java.net.HttpURLConnection');
                const conn = Java.cast(URL.$new(urlStr).openConnection(), HttpURLConnection);
                conn.setRequestMethod('GET');
                const iterator = headersMap.entrySet().iterator();
                while (iterator.hasNext()) {
                    const entry = Java.cast(iterator.next(), MapEntry);
                    try { conn.setRequestProperty(entry.getKey(), entry.getValue()); } catch (e) {}
                }
                conn.setConnectTimeout(5000);
                conn.setReadTimeout(5000);

                const code = conn.getResponseCode();
                console.log('<<< [WEBVIEW RESPONSE] ' + code + ' ' + urlStr);

                const respHeaders = conn.getHeaderFields();
                const hIterator = respHeaders.entrySet().iterator();
                while (hIterator.hasNext()) {
                    const entry = Java.cast(hIterator.next(), MapEntry);
                    if (entry.getKey() !== null) {
                        console.log('    ' + entry.getKey() + ': ' + entry.getValue());
                    }
                }

                const InputStreamReader = Java.use('java.io.InputStreamReader');
                const BufferedReader = Java.use('java.io.BufferedReader');
                const stream = code >= 400 ? conn.getErrorStream() : conn.getInputStream();
                if (stream !== null) {
                    const reader = BufferedReader.$new(InputStreamReader.$new(stream, 'UTF-8'));
                    let line, body = '';
                    let n = 0;
                    while ((line = reader.readLine()) !== null && n < 500) {
                        body += line + '\n';
                        n++;
                    }
                    reader.close();
                    console.log('    body: ' + body);
                }
                console.log('');
            } catch (e) {
                console.log('    [shadow fetch fallita: ' + e + ']');
            }
        }

        SystemWebViewClient.shouldInterceptRequest.overload('android.webkit.WebView', 'android.webkit.WebResourceRequest').implementation = function (webview, request) {
            const url = request.getUrl().toString();
            const method = request.getMethod();

            console.log('\n>>> [WEBVIEW REQUEST] ' + method + ' ' + url);
            logHeaders('    ', request.getRequestHeaders());

            const result = this.shouldInterceptRequest(webview, request);

            if (result === null) {
                // Cordova non ha intercettato: la WebView fara' la richiesta
                // reale da sola. Proviamo a vedere anche noi la risposta
                // (solo GET, vedi limite sopra), senza toccare il flusso vero.
                shadowFetch(url, method, request.getRequestHeaders());
            } else {
                console.log('    [gestita localmente da Cordova, non e\' una richiesta di rete reale]\n');
            }

            return result;
        };

        console.log('[*] Hook 5/5 installato: logging richieste WebView (Cordova shouldInterceptRequest)');
    } catch (e) {
        console.log('[!] impossibile installare il logging WebView: ' + e);
    }

    // --- 6) Forza il proxy anche dentro la WebView (Chromium) ---
    // Il system-wide "settings put global http_proxy" NON e' affidabile per
    // il motore Chromium della WebView (a differenza di Chrome vero, che lo
    // rispetta - infatti nelle connessioni di sistema si vede
    // com.android.chrome andare su 10.0.2.2:8080 mentre l'app va dritta
    // sull'host reale). La classe org.chromium.base.CommandLine vive
    // nell'APK del provider WebView, non nell'app: diventa caricabile solo
    // quando WebViewFactory.getProvider() viene chiamato per la prima volta,
    // quindi e' li' che agganciamo, il piu' presto possibile prima che il
    // motore di rete di Chromium si inizializzi davvero.
    try {
        const WebViewFactory = Java.use('android.webkit.WebViewFactory');
        let injected = false;

        WebViewFactory.getProvider.implementation = function () {
            const result = this.getProvider();
            if (!injected) {
                injected = true;
                try {
                    const CommandLine = Java.use('org.chromium.base.CommandLine');
                    if (!CommandLine.isInitialized()) {
                        const emptyArgs = Java.array('java.lang.String', []);
                        CommandLine.init(emptyArgs);
                    }
                    CommandLine.getInstance().appendSwitchWithValue('proxy-server', '10.0.2.2:8080');
                    console.log('[*] CommandLine proxy-server=10.0.2.2:8080 iniettato nel motore WebView');
                } catch (e) {
                    console.log('[!] impossibile iniettare il proxy in CommandLine: ' + e);
                }
            }
            return result;
        };

        console.log('[*] Hook 6/6 installato: WebViewFactory.getProvider (proxy Chromium)');
    } catch (e) {
        console.log('[!] impossibile agganciare WebViewFactory.getProvider: ' + e);
    }
});
