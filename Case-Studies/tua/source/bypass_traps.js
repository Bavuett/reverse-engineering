/*
 * Neutralizza a runtime le trappole anti-tampering (div/0, NPE deliberati)
 * iniettate in CordovaActivity/MainActivity, sostituendo l'implementazione
 * dei metodi colpiti con una ricostruzione della logica reale (letta dallo
 * smali decompilato), omettendo il codice-trappola legato al contatore di
 * stato condiviso (onNavigationEvent/asInterface/ICustomTabsCallbackStub).
 *
 * Uso:
 *   frida -U -f <package> -l bypass_traps.js --no-pause
 *
 * Se crasha ancora, prendi lo stack trace da `adb logcat | grep -A 30
 * "FATAL EXCEPTION"` e passamelo: aggiungo l'override per il metodo
 * successivo colpito.
 */

Java.perform(function () {
    const CordovaActivity = Java.use('org.apache.cordova.CordovaActivity');
    const MainActivity = Java.use('net.pluservice.tua.MainActivity');
    const FrameLayoutLP = Java.use('android.widget.FrameLayout$LayoutParams');
    const Locale = Java.use('java.util.Locale');

    // --- createViews() -- riga 5073, trappola div/0 in coda ---
    CordovaActivity.createViews.implementation = function () {
        const view = this.appView.value.getView();
        view.setId(0x64);
        view.setLayoutParams(FrameLayoutLP.$new(-1, -1)); // MATCH_PARENT, MATCH_PARENT

        this.setContentView(view);

        const prefs = this.preferences.value;
        if (prefs.contains('BackgroundColor')) {
            try {
                const bg = prefs.getInteger('BackgroundColor', -0x1000000);
                view.setBackgroundColor(bg);
            } catch (e) {
                console.log('[createViews] NumberFormatException su BackgroundColor: ' + e);
            }
        }

        view.requestFocusFromTouch();
        console.log('[createViews] eseguita senza trappola');
    };

    // --- init() -- riga 5243, due rami duplicati + un ramo NPE ---
    CordovaActivity.init.overload().implementation = function () {
        this.appView.value = this.makeWebView();
        this.createViews(); // richiama la versione patchata sopra

        if (!this.appView.value.isInitialized()) {
            this.appView.value.init(this.cordovaInterface.value, this.pluginEntries.value, this.preferences.value);
        }

        this.cordovaInterface.value.onCordovaInit(this.appView.value.getPluginManager());

        const pm = this.cordovaInterface.value.pluginManager.value;
        pm.postMessage('setupSplashScreen', this.splashScreen.value);

        const stream = this.preferences.value.getString('DefaultVolumeStream', '').toLowerCase(Locale.ENGLISH.value);
        if (stream === 'media') {
            this.setVolumeControlStream(3); // AudioManager.STREAM_MUSIC
        }

        console.log('[init] eseguita senza trappola');
    };

    // --- MainActivity.onPause() -- bypassa la trappola chiamando
    //     direttamente l'onPause "vero" di CordovaActivity ---
    // NB: se CordovaActivity.onPause() a sua volta contiene una trappola
    //     non ancora ricostruita, il crash si sposterebbe li'.
    MainActivity.onPause.implementation = function () {
        CordovaActivity.onPause.call(this);
        console.log('[MainActivity.onPause] bypass applicato');
    };

    MainActivity.onResume.implementation = function () {
        CordovaActivity.onResume.call(this);
        console.log('[MainActivity.onResume] bypass applicato');
    };

    console.log('[*] Bypass installati: createViews, init, MainActivity.onPause/onResume');
});
