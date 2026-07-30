/*
 * Neutralizza il controllo di root/tamper nascosto dentro
 * com.google.zxing.oned.UPCEANExtension2Support.onMessageChannelReady(JJ)V
 * (metodo ZXing reale riusato come contenitore per codice iniettato,
 * invocato per reflection da com.google.firebase.provider.FirebaseInitProvider,
 * che parte prima di qualsiasi Activity/Application.onCreate()).
 *
 * Non serve capire la logica interna (reflection + stringhe cifrate a runtime
 * + eccezione custom usata come goto): sovrascriviamo l'intero metodo con un
 * no-op. Qualunque chiamante, anche via reflection, colpisce comunque questa
 * implementazione perche' Frida rimpiazza lo slot del metodo a livello ART.
 *
 * IMPORTANTE: va lanciato in modalita' SPAWN (-f), non attach, perche'
 * FirebaseInitProvider.onCreate() gira in handleBindApplication(), PRIMA di
 * qualunque Application.onCreate()/Activity: se il processo e' gia' partito
 * quando ci si aggancia, il controllo e' gia' scattato.
 *
 * Uso:
 *   frida -U -f <package> -l neutralize_root_check.js --no-pause
 */

Java.perform(function () {
    const UPCEANExtension2Support = Java.use('com.google.zxing.oned.UPCEANExtension2Support');

    UPCEANExtension2Support.onMessageChannelReady.overload('long', 'long').implementation = function (a, b) {
        console.log('[*] UPCEANExtension2Support.onMessageChannelReady neutralizzato (args=' + a + ', ' + b + ') - root/tamper check saltato');
        // no-op: il vero controllo (root detection nascosta) non viene mai eseguito
    };

    console.log('[*] Hook installato su UPCEANExtension2Support.onMessageChannelReady(JJ)');
});
