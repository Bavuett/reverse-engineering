/*
 * Individua l'origine del log "SCRTYMANAGER: RunningOnRootedDeviceException"
 * agganciando android.util.Log a runtime. Le stringhe sono cifrate nello
 * smali quindi non si trovano via grep statico, ma qui intercettiamo il
 * messaggio gia' decifrato, nel momento stesso in cui viene loggato, e
 * stampiamo lo stack trace Java di chi ha chiamato Log.*, rivelando la
 * classe/metodo responsabile del controllo di root.
 *
 * Uso:
 *   frida -U -f <package> -l find_root_check.js --no-pause
 */

Java.perform(function () {
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

    ['d', 'i', 'w', 'v'].forEach(function (level) {
        try {
            Log[level].overload('java.lang.String', 'java.lang.String').implementation = function (tag, msg) {
                if (msg && (msg.indexOf('Rooted') !== -1 || msg.indexOf('SCRTY') !== -1 || tag.indexOf('SCRTY') !== -1)) {
                    dumpStack('Log.' + level, tag, msg);
                }
                return this[level](tag, msg);
            };
        } catch (e) {
            console.log('overload Log.' + level + '(String,String) non trovato: ' + e);
        }
    });

    // e() ha anche l'overload con Throwable: Log.e(tag, msg, tr)
    Log.e.overload('java.lang.String', 'java.lang.String').implementation = function (tag, msg) {
        if (msg && (msg.indexOf('Rooted') !== -1 || msg.indexOf('SCRTY') !== -1 || tag.indexOf('SCRTY') !== -1)) {
            dumpStack('Log.e', tag, msg);
        }
        return this.e(tag, msg);
    };

    Log.e.overload('java.lang.String', 'java.lang.String', 'java.lang.Throwable').implementation = function (tag, msg, tr) {
        if (msg && (msg.indexOf('Rooted') !== -1 || msg.indexOf('SCRTY') !== -1 || tag.indexOf('SCRTY') !== -1)) {
            dumpStack('Log.e(+Throwable)', tag, msg);
            console.log('    Throwable: ' + tr);
        }
        return this.e(tag, msg, tr);
    };

    // Fallback: se il messaggio non passa mai per android.util.Log (es. e' un
    // System.out.println o un logger custom), agganciamo anche il costruttore
    // di RuntimeException/Exception per vedere se il messaggio compare li'.
    const RuntimeException = Java.use('java.lang.RuntimeException');
    RuntimeException.$init.overload('java.lang.String').implementation = function (msg) {
        if (msg && (msg.indexOf('Rooted') !== -1 || msg.indexOf('SCRTY') !== -1)) {
            console.log('\n=== [RuntimeException.<init>] msg="' + msg + '" ===');
            console.log(Log.getStackTraceString(this));
        }
        return this.$init(msg);
    };

    console.log('[*] Hook su Log.*/RuntimeException installati, in attesa del messaggio...');
});
