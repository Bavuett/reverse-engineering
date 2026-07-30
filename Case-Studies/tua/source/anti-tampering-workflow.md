# Workflow per individuare pattern di anti-tampering nello smali

Note raccolte durante l'analisi di `net.pluservice.tua`, utili come metodo generale
(non solo per questa app) prima di passare a un tool automatico.

## Come siamo arrivati qui: la cronologia dell'indagine

Questo file non nasce da una ricerca pianificata a tavolino — nasce da un percorso
in cui la ricerca statica alla cieca ha fallito ripetutamente, e solo l'analisi
dinamica (Frida + logcat) ha rivelato dove guardare. Vale la pena ricostruirlo,
perché il "come ci siamo arrivati" è il vero insegnamento, più delle liste di file.

**1. Il primo tentativo (fallito): grep per parole chiave.**
La domanda di partenza era "dove inizia la protezione che rileva dispositivi
inaffidabili?". Il primo istinto è stato cercare le stringhe tipiche di un root-check
(`su`, `test-keys`, `Superuser`, `RootBeer`, `Magisk`, `Xposed`, `SafetyNet`...)
direttamente nello smali decompilato. **Zero risultati.** Motivo scoperto solo dopo:
quasi tutte le stringhe letterali dell'app sono cifrate a runtime (campi statici
`$$d`/`$$j`/`$$l` come byte-array, decifrati solo quando servono) — cercare
"root" o "security" come testo non poteva funzionare per costruzione.

**2. Esplorazione di piste plausibili ma sbagliate.**
Si è seguita la pista di `FirebaseInstanceId` (usato in `DeviceIdProvider` per
generare un fingerprint del dispositivo) e quella del sistema di cifratura dei
bundle JS (`EncryptionProvider`/`KeyKeeper`/`PluserviceKeyStore`, con chiave AES
gestita via `AccountManager`). Entrambe piste legittime da investigare, ma
**nessuna delle due era il vero meccanismo di blocco** — lo si è scoperto solo
continuando a testare, non deducendolo a priori.

**3. Il crash durante il test di hooking, e la svolta verso l'analisi dinamica.**
Cercando di agganciare `EncryptionProvider` con Frida, l'app crashava prima ancora
che l'hook potesse osservare qualcosa. Da qui il vero cambio di metodo: invece di
continuare a leggere smali offuscato a occhio, si è **letto `adb logcat`** durante
il crash, trovando la riga chiave:
```
E SCRTYMANAGER: RunningOnRootedDeviceException exception: -7
```
Una stringa in chiaro nel log (perché il messaggio, una volta decifrato a runtime
e passato a `Log.e`, non è più cifrato) — il logcat ha aggirato completamente il
problema della cifratura statica.

**Perché il crash non dava alcun segnale, all'inizio.** Vale la pena motivarlo,
perché non è stato un limite degli strumenti usati ma una scelta di design precisa
di chi ha protetto l'app. Il primo crash osservato con Frida produceva solo
`Process terminated` in console — nessuno stack trace, nessun messaggio, nulla su
cui ragionare. Le ragioni:

- **Non è un'eccezione non gestita.** Le trappole div/0 e NPE trovate più avanti
  *sono* vere eccezioni Java (`ArithmeticException`, `NullPointerException`) — se
  una di quelle avesse causato questo crash, si sarebbe visto `FATAL EXCEPTION` con
  stack trace completo in logcat fin da subito. Il blocco reale, invece, chiama
  `System.exit(status)` **direttamente**: una terminazione pulita e deliberata,
  non un errore. Senza eccezione da propagare non c'è stack trace da generare —
  è indistinguibile, per il sistema, da un'app che decide volontariamente di
  chiudersi.
- **Frida non distingue le cause.** Il messaggio `Process terminated` della REPL
  è generico per costruzione: compare sia per un'eccezione non gestita, sia per un
  processo ucciso dal sistema, sia per un `System.exit()` volontario. Zero
  informazione diagnostica da solo.
- **Il vero segnale viveva in un flusso separato, non mostrato di default.** La
  riga `SCRTYMANAGER: RunningOnRootedDeviceException exception: -7` esisteva solo
  in `adb logcat`, un flusso che Frida non legge/mostra automaticamente. Bisognava
  saperlo aprire in parallelo, nel momento esatto del crash — sono righe non
  bufferizzate: un secondo di ritardo, o uno scroll troppo veloce, e si perdono.
- **Il rumore di sistema ha aggiunto un ulteriore livello di mimetizzazione.** Nello
  stesso blocco di log comparivano decine di righe irrilevanti (`AppUtils`,
  `AppButtonsPrefCtl`, `ActivityManager`, `CompatibilityChangeReporter`...) — il
  segnale utile era una riga su cinquanta, facile da perdere senza filtrare
  esplicitamente (`grep SCRTYMANAGER`, `grep "FATAL EXCEPTION"`).

In sintesi: il crash "senza segni" non era un limite di Frida o del metodo usato,
ma il risultato voluto di una scelta implementativa (`System.exit` invece di
un'eccezione) pensata apposta per non lasciare tracce facilmente osservabili —
la stessa logica anti-forensics vista anche altrove in questa app (stringhe
cifrate, reflection per nascondere le chiamate, nomi di classi/metodi presi in
prestito da API reali, vedi sezione dedicata più sotto).

**4. Frida per risalire dal sintomo alla causa.**
Sapendo *cosa* cercare ("SCRTYMANAGER" nel log) ma non *da dove* venisse, si è
scritto uno script Frida che aggancia tutti gli overload di `android.util.Log`
(`d`/`i`/`w`/`v`/`e`) e, quando il messaggio contiene quella stringa, stampa lo
stack trace Java completo (`Throwable.$new().getStackTrace()`) di chi ha chiamato
il log. Questo ha rivelato la catena reale:
```
FirebaseInitProvider.onCreate()  (il vero ContentProvider Firebase, dirottato)
  → reflection → UPCEANExtension2Support.onMessageChannelReady(J J)  (classe ZXing, riusata come nascondiglio)
    → Log.e("SCRTYMANAGER", "RunningOnRootedDeviceException exception: -7")
```
`FirebaseInitProvider` parte prima di qualunque Activity/`Application.onCreate()`
(gira in `handleBindApplication()`), il che spiegava perché il crash avvenisse
"prima che succedesse qualunque cosa" — non c'è nulla di più precoce in cui
agganciarsi. Questo ha anche validato retroattivamente l'intuizione iniziale
sul coinvolgimento di Firebase, anche se il meccanismo reale (dirottamento di
`FirebaseInitProvider`) era diverso da quello ipotizzato all'inizio
(`FirebaseInstanceId`).

**5. Ogni fix rivelava il livello successivo (whack-a-mole controllato).**
Neutralizzato quel metodo specifico via Frida (override no-op), il crash si
è ripresentato con un **secondo** messaggio SCRTYMANAGER (`AppDebuggableException`),
da un'altra classe-nascondiglio (`MediaBrowserCompatApi26`, AndroidX). Ripetendo
la stessa tecnica (hook su `Log.*`, stack trace, individuazione della classe) si è
trovato anche questo. A quel punto, contando quante chiamate reflection facesse
`FirebaseInitProvider.onCreate()` in totale (`grep` su `Method;->invoke` nel file:
più di 60 occorrenze), è diventato chiaro che inseguire ogni nascondiglio uno per
uno non era sostenibile.

**6. Da "inseguire ogni check" a "generalizzare il pattern".**
Le tre classi-nascondiglio trovate fino a quel punto condividevano tutte la stessa
firma di metodo: `(JJ)V`. Da lì l'idea di **generalizzare**: invece di continuare
a scoprire nascondigli uno alla volta via Frida, cercare **staticamente** tutti i
metodi con quella firma esatta in tutto l'albero smali (`grep -rn
"^\.method public static \w+(JJ)V" smali/`) — trovandone 15 in un colpo solo,
molti mai scoperti dinamicamente. Parallelamente, si è notato che ogni check,
qualunque fosse, finiva sempre per chiamare `System.exit(status)` (visibile anche
in logcat: `System.exit called, status: -7`) — quindi si è aggiunto anche un
hook "rete di sicurezza" su `Runtime.exit`/`Runtime.halt`/`Process.killProcess`,
che neutralizza l'effetto di *qualunque* check, anche quelli non ancora scoperti.

**7. Lo stesso schema si è ripetuto per le trappole div/0.**
Analogamente: la prima trappola (`div-int/lit8 v1, v1, 0x0` dentro
`MainActivity.onPause()`) è stata trovata **leggendo il codice a occhio** dopo
aver notato un pattern strutturale sospetto (un contatore di stato che condiziona
un ramo che esplode sempre). Una volta riconosciuta la forma esatta
dell'istruzione, si è generalizzato con un grep sull'intero albero smali,
trovando 224 occorrenze in 98 file — inclusi file di librerie di terze parti
(Gson, ZXing) mai scritti a mano dagli sviluppatori dell'app, prova che la
trappola è iniettata meccanicamente da uno strumento di hardening al momento
della build, non codice applicativo.

**Il filo conduttore**: la ricerca statica per parole chiave non ha mai funzionato
da sola (le stringhe sono cifrate). Quello che ha funzionato è sempre stato lo
stesso ciclo: *osservare dinamicamente un sintomo reale (logcat/crash) → usare
Frida per risalire dallo stack trace alla causa esatta → riconoscere la forma
esatta del pattern bytecode → generalizzare quella forma con grep su tutto
l'albero per trovare le istanze sorelle*. Le sezioni seguenti sono il risultato
cristallizzato di questo processo, non il punto di partenza.

## File già mappati in questa sessione

### Trappole div-by-zero (224 occorrenze, 98 file)

Comando per rigenerare la lista:
```
grep -rn "div-int(/lit8)\? [vp][0-9]\+, [vp][0-9]\+, 0x0" smali/
```
(verificare a occhio che i due registri coincidano — in tutti i casi osservati era così)

File prioritari (sul path di avvio reale, non librerie di terze parti):
- `smali/net/pluservice/tua/MainActivity.smali` (1 occorrenza, in `onPause`)
- `smali/org/apache/cordova/CordovaActivity.smali` (6 occorrenze: `createViews`, `init`,
  `onDestroy`, `onMessage`, `onNewIntent`, `onOptionsItemSelected`)
- `smali/org/apache/cordova/CordovaPlugin.smali` (4 occorrenze — non ancora esaminate)

Le restanti ~90 occorrenze sono sparse in librerie di terze parti (Gson, ZXing,
Play Services) — meno prioritarie da editare a mano.

### Metodi-nascondiglio con firma `(JJ)V` (15 totali)

Comando per rigenerare la lista:
```
grep -rn "^\.method public static \w\+(JJ)V" smali/
```

```
android/support/v4/media/MediaBrowserCompatApi26.smali
net/pluservice/plusnetworking/R$anim.smali
com/google/zxing/RGBLuminanceSource.smali
com/google/zxing/pdf417/decoder/ec/ModulusPoly.smali
com/google/zxing/oned/UPCEANExtension2Support.smali
com/google/firebase/R$drawable.smali
com/google/gson/internal/UnsafeAllocator$2.smali
com/google/zxing/client/android/encode/VCardContactEncoder.smali
com/google/android/gms/measurement/internal/zzep.smali
com/google/android/gms/dynamite/DynamiteModule$LoadingException.smali
com/google/android/gms/common/api/internal/ApiKey.smali
com/google/android/gms/common/api/internal/zaf.smali
o/setButtonDrawable.smali
o/setImeOptions.smali
o/setOnSearchClickListener.smali
```

## Workflow generale

1. **Triage dinamico prima di tutto, non statico.** Non partire a fare grep alla
   cieca in un binario da centinaia di migliaia di righe. Usare Frida per capire
   *dove* scatta un comportamento sospetto (agganciare `Log.e`/`RuntimeException.<init>`
   e leggere lo stack trace) dice la classe/metodo esatto prima ancora di aprire un
   editor. La ricerca statica alla cieca è l'ultima risorsa, non la prima.

2. **Una volta capita la "forma" di una trappola, grep-are quella forma esatta, non
   il concetto.** Non cercare "root check" o "security" (le stringhe sono cifrate,
   non si trovano mai) — cercare il **bytecode pattern** osservato: un'istruzione
   che matematicamente esplode sempre (`div-int ..., 0x0`), o un pattern come
   `const/4 vX, 0x0` seguito a poche righe da `invoke-virtual {vX}, ...` e poi
   `throw vX` (chiamata su null seguita da throw).

3. **Per la reflection-hiding, il segnale è "dichiarato ma mai chiamato
   direttamente".** Due grep separati (dichiarazioni vs chiamate dirette via
   `invoke-static`/`invoke-virtual`) e set-difference — un metodo con firma
   sospetta mai referenziato direttamente in tutto l'albero è quasi certamente
   raggiunto solo per reflection.

4. **Seguire i nomi riusati come indizio di camuffamento.** L'offuscatore riusa
   nomi di metodi/campi reali di Android (`onNavigationEvent`, `ICustomTabsCallback`,
   `asInterface`, `onMessageChannelReady`...) come "maschera" per contatori di stato
   e nascondigli, sparsi su classi scorrelate. Lo stesso nome di metodo improbabile
   dentro una classe che non c'entra nulla con quel nome è un segnale forte.

5. **Verificare ogni modifica in isolamento prima di combinarle.** Prima validare
   via Frida (no-op runtime, costo zero) che neutralizzare quella specifica
   istruzione/metodo non rompa nulla — solo dopo portare la modifica nel file
   smali statico.

## Perché la firma `(JJ)V` è diventata un segnale (e i suoi limiti)

Non è che `(JJ)V` sia sospetta in astratto — è una firma banale che potrebbe avere
qualunque metodo legittimo. È diventata un segnale utile **in questo caso specifico**
per un motivo empirico, non teorico:

1. Con Frida sono stati osservati dinamicamente (stack trace reali, non ipotesi) tre
   controlli di sicurezza nascosti — root-check, debuggable-check, e un terzo —
   richiamati via reflection da `FirebaseInitProvider.onCreate()`.
2. Tutti e tre condividevano esattamente la stessa firma: `(JJ)V`.
3. Ipotesi: se lo strumento di offuscamento genera questi nascondigli con un
   template/codegen automatico, è plausibile che usi sempre la stessa forma di
   firma per tutti i controlli iniettati, qualunque sia la classe-contenitore
   scelta come mimetizzazione. Cercare quella firma esatta è un modo per trovare
   "fratelli" dello stesso pattern già confermato — non una regola generale.

**Il vero segnale non è la firma, è la firma abbinata alla classe sbagliata.**
`VCardContactEncoder` (encoder di vCard per QR code) non ha nessuna ragione
legittima di avere un metodo pubblico statico che prende due long opachi e non
ritorna nulla. Lo stesso per `RGBLuminanceSource` o per una classe risorse
`R$drawable`/`R$anim` (che dovrebbero contenere solo costanti `int`, mai metodi
con logica). È l'incoerenza semantica tra contesto e contenuto il vero indizio;
la firma è solo la scorciatoia pratica per trovarla via grep.

Perché due `long`, probabilmente (speculazione non verificata): comodi per
impacchettare in un solo parametro un selettore/flag/magic-value (gli argomenti
catturati, es. `5571322406892470000, 1297174580`, sembrano valori opachi), e uno
schema a firma fissa `(long, long)` assomiglia a vere callback Android, il che si
allinea con la strategia di camuffamento vista ovunque in questa app.

**Limiti dell'euristica:**
- Falsi positivi possibili: un metodo legittimo altrove potrebbe avere
  coincidenzialmente la stessa firma.
- Falsi negativi certi: se l'offuscatore usa firme diverse per altri controlli non
  ancora scoperti dinamicamente, questo grep non li troverà — per quelli serve
  tornare al punto 1 del workflow (triage dinamico) prima di aggiornare la firma
  da cercare.

## Esempi di nomi/firme riusati come camuffamento

Il punto 4 del workflow generale dice di "seguire i nomi riusati" — ecco i casi
concreti trovati in questa app, con il confronto tra il vero significato del nome
nell'API Android e l'uso (scorretto/estraneo) che ne fa l'offuscatore. In ogni
caso il nome è identico, ma firma, classe e scopo non c'entrano nulla con
l'originale — è proprio questo scollamento il segnale da cercare, non il nome
in sé.

| Nome riusato | Vero significato (API Android) | Uso trovato nell'app | Differenza chiave |
|---|---|---|---|
| `onNavigationEvent` | Metodo dell'interfaccia AIDL `ICustomTabsCallback.onNavigationEvent(int, Bundle)` — il browser notifica eventi di navigazione (START, FINISHED, FAILED...) a un'app che ha aperto una Custom Tab | Campo statico `private static onNavigationEvent:I` usato come contatore di stato (in `CordovaActivity`, `MainActivity`, `PluserviceKeyStore`); altrove è invece un metodo statico `(JJ)V` (`o/setImeOptions.smali`, `ApiKey.smali`) | La vera firma è `(int, Bundle): void` dentro un'interfaccia AIDL. Qui è ora un semplice `int`, ora un metodo con firma completamente diversa — nessuna relazione con Custom Tabs |
| `onMessageChannelReady` | `ICustomTabsCallback.onMessageChannelReady(Bundle)` — notifica che un canale di postMessage app↔browser è pronto | `UPCEANExtension2Support.onMessageChannelReady(long, long): void` — **il nascondiglio del root-check** trovato con Frida | Firma diversa (`(JJ)V` invece di `(Bundle)V`), dentro una classe di decodifica barcode ZXing che non ha nulla a che fare con browser tab |
| `ICustomTabsCallback` | Nome dell'intera **interfaccia** AIDL (non un metodo), con più metodi al suo interno | Riusato come nome di *singolo metodo* statico in `VCardContactEncoder.smali` (`(JJ)V`) e in `PluserviceKeyStore.smali` (`(Context, int, int): Object[]`) | Un'interfaccia con più metodi è stata "appiattita" a un singolo nome di metodo, riusato con firme diverse in classi scorrelate tra loro |
| `asInterface` | Pattern standard AIDL-generated: `XXX.Stub.asInterface(IBinder)` converte un Binder grezzo nell'interfaccia tipizzata | Campo statico `private static asInterface:I`, un banale contatore (`CordovaActivity`, `PluserviceKeyStore`) | La vera API è un metodo che riceve un `IBinder` e ritorna un oggetto; qui è solo un numero che sale e scende |
| `getActiveNotifications` | `NotificationListenerService.getActiveNotifications()` — ritorna le notifiche attive per un servizio di ascolto notifiche | `.super Lo/getActiveNotifications;` — **l'intera superclasse di `CordovaActivity`** rinominata così (in realtà `androidx.appcompat.app.AppCompatActivity`) | Il caso più estremo: qui il "riuso" non è nemmeno un metodo, ma il nome di un'**intera classe** — tanto aggressivo da poter essere scambiato per un'API legittima non identificata |
| `getEnterTransitionCallback` | Riconducibile alle API di transizioni condivise dei Fragment (`SharedElementCallback`, animazioni tra schermate) | `Lo/getEnterTransitionCallback` è una **classe eccezione custom** (con campo `Enum`), lanciata e catturata nello stesso metodo solo come goto camuffato — non un'eccezione vera | Nella vera API è una callback per animazioni UI; qui è un trucco di controllo di flusso che non lancia/cattura un errore reale |

**Perché questo inganna anche un lettore umano attento**: durante l'analisi, vedere
`invoke-super {p0, p1}, Lo/getActiveNotifications;->onCreate(...)` fa pensare
istintivamente a una classe reale non ancora vista, non a `AppCompatActivity`
rinominata — serve seguire la gerarchia (`.super`) e verificare cosa il metodo fa
davvero (chiama `setContentView`, gestisce l'`ActionBar`...) prima di fidarsi del
nome. La stessa cautela vale per ogni nome "familiare" incontrato in una classe che,
a pensarci, non dovrebbe averne bisogno.

## Guida rapida a grep e alle regex usate

### Le flag di grep

Sintassi base: `grep [flag...] PATTERN file...`

| Flag | Cosa fa | Esempio da questa sessione |
|---|---|---|
| `-n` | Mostra il numero di riga davanti a ogni match | `grep -n "onCreate" file.smali` → `6980:.method public onCreate...` |
| `-r` / `-R` | Cerca ricorsivamente in tutte le sottocartelle | `grep -rn "pattern" smali/` |
| `-i` | Case-insensitive (ignora maiuscole/minuscole) | cercare `root\|Rooted\|ROOT` con un solo pattern |
| `-v` | **Inverte** il match: stampa le righe che NON corrispondono | utile per escludere rumore |
| `-c` | Conta le righe con match (non le occorrenze totali!) per file | `grep -rc "pattern" smali/` |
| `-o` | Stampa **solo** la parte che ha fatto match, non l'intera riga | utile con `wc -l` per contare occorrenze totali invece di righe |
| `-l` | Stampa solo i nomi dei file con almeno un match | equivalente a `output_mode: files_with_matches` |
| `-A N` | Stampa N righe **dopo** ogni match (After) | `grep -A 30 "FATAL EXCEPTION" logcat.txt` |
| `-B N` | Stampa N righe **prima** di ogni match (Before) | vedere il contesto prima di `div-int/lit8` |
| `-C N` | Contesto: N righe prima E dopo (Context) | scorciatoia per `-A N -B N` insieme |
| `-w` | Match solo su parole intere (non substring) | evita falsi positivi su nomi parziali |
| `-E` | Extended regex: abilita `+ ? \| ( )` come metacaratteri senza backslash | **fondamentale**, vedi sotto |
| `-P` | Perl-compatible regex (solo GNU grep): abilita `\d`, `\w`, lookahead | alternativa a `-E` con sintassi più ricca |
| `--include="*.smali"` | Filtra per pattern di nome file quando usi `-r` | equivalente al parametro `glob` |

⚠️ **Attenzione pratica**: `-c` conta le **righe** che matchano, non le occorrenze
totali. Se una riga contiene il pattern due volte, conta comunque 1. Per contare
occorrenze totali: `grep -o "pattern" file | wc -l`.

### `grep` semplice vs `grep -E` (differenza cruciale)

Il `grep` "nudo" usa **BRE** (Basic Regular Expressions): caratteri come `+ ? | ( )`
sono **letterali**, non speciali. Per renderli speciali serve il backslash davanti
(`\+`, `\?`, `\|`, `\(`, `\)`).

Con `-E` (o `egrep`) si usa **ERE** (Extended): `+ ? | ( )` sono speciali di default,
e per matcharli letteralmente serve il backslash (`\+` per un `+` letterale).

Uno strumento basato su ripgrep si comporta sempre come `-E` (anzi, più ricco, stile
Rust-regex/PCRE) — non serve mai un flag equivalente. Ma copiando questi pattern in
un terminale con `grep` puro, senza `-E` non funzionano come previsto.

### Le regex spiegate sui pattern reali usati in questa sessione

**Pattern 1 — le trappole div/0**
```
div-int(/lit8)? [vp]\d+, [vp]\d+, 0x0
```
| Pezzo | Significato |
|---|---|
| `div-int` | Testo letterale — matcha se stesso |
| `(/lit8)?` | `( )` raggruppa `/lit8`; `?` dopo il gruppo = "0 o 1 volta" → cattura sia `div-int` che `div-int/lit8` |
| `[vp]` | Classe di caratteri: matcha esattamente un carattere, `v` oppure `p` |
| `\d` | Scorciatoia per "una cifra" (`[0-9]`) |
| `+` | Quantificatore: "una o più ripetizioni dell'elemento precedente" |
| `0x0` | Letterale — le tre lettere/cifre `0`, `x`, `0` |

Si legge: *"`div-int`, opzionalmente seguito da `/lit8`, poi un registro (`v`/`p` +
numero), virgola, un altro registro nella stessa forma, virgola, `0x0`"*.

**Pattern 2 — i metodi nascondiglio**
```
^\.method public static \w+\(JJ\)V
```
| Pezzo | Significato |
|---|---|
| `^` | Ancora: "inizio riga" (posizione, non carattere) |
| `\.` | Il punto `.` da solo significa "qualsiasi carattere"; escapato con `\` matcha un punto letterale |
| `\w+` | `\w` = carattere di parola (lettere/cifre/underscore); `+` = una o più volte |
| `\(` `\)` | Le parentesi tonde sono metacaratteri di raggruppamento; escapate matchano parentesi letterali |

**Pattern 3 — alternanza**
```
SCRTYMANAGER|RunningOnRootedDeviceException
```
`|` è un OR logico: matcha il testo a sinistra oppure quello a destra.

### Tabella riassuntiva dei simboli

| Simbolo | Nome | Significato |
|---|---|---|
| `.` | Punto (non escapato) | Qualsiasi carattere singolo |
| `\.` | Punto escapato | Il carattere `.` letterale |
| `*` | Asterisco | 0 o più ripetizioni del carattere/gruppo precedente |
| `+` | Più | 1 o più ripetizioni |
| `?` | Punto interrogativo | 0 o 1 ripetizione (rende opzionale ciò che precede) |
| `^` | Cappello | Ancora: inizio riga |
| `$` | Dollaro | Ancora: fine riga |
| `[abc]` | Classe di caratteri | Uno qualsiasi tra i caratteri elencati |
| `\d` | Shorthand | Una cifra `[0-9]` |
| `\w` | Shorthand | Un carattere di parola `[a-zA-Z0-9_]` |
| `(...)` | Gruppo | Raggruppa più caratteri per applicarci un quantificatore insieme |
| `\(` `\)` | Parentesi escapate | Parentesi tonde letterali (non raggruppamento) |
| `\|` | Pipe | OR tra alternative |

### Esercizi pratici

```bash
# conta le righe con "onCreate" in tutti i file smali
grep -rc "onCreate" smali/ | grep -v ":0"

# trova tutte le classi ZXing che hanno un metodo sospetto
grep -rEn "^\.method public static \w+\(JJ\)V" smali/com/google/zxing/

# stampa 5 righe di contesto prima e dopo ogni "div-int...0x0"
grep -B 5 -A 2 "div-int/lit8.*0x0" smali/net/pluservice/tua/MainActivity.smali
```
