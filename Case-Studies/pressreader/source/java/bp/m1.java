package bp;

import android.sax.Element;
import android.sax.RootElement;
import android.sax.StartElementListener;
import android.text.TextUtils;
import android.util.Xml;
import com.braze.Constants;
import com.braze.configuration.BrazeConfigurationProvider;
import com.google.firebase.perf.network.FirebasePerfUrlConnection;
import com.newspaperdirect.pressreader.android.core.Service;
import com.newspaperdirect.pressreader.android.devicemanagement.model.AccountDevice;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.ProtocolException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Locale;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;

/* JADX INFO: loaded from: classes2.dex */
public final class m1 {

    public static final lr.b f8634n;
    public static final HashMap<String, String> f8635o;
    public static String f8636p;
    public static Boolean f8637q;
    public static final LinkedList f8638r;

    public final String f8639a;
    public final boolean f8643e;
    public final RootElement f8644f;
    public final Element f8645g;
    public final dx.b f8646h;
    public dx.b f8647i;
    public int f8648j;
    public String k;

    public String f8640b = BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE;
    public boolean f8641c = true;
    public boolean f8642d = true;
    public final ArrayList<AccountDevice> f8649l = new ArrayList<>();
    public String f8650m = null;

    // Command queue entry: parsed out of a <command name="..."><data>...</data></command> block
    // in a server response, or (constructor path) out of the "nd" SAX document directly.
    public static class a {
        public EnumC0116a f8651a = EnumC0116a.Action;
        public String f8652b;

        public enum EnumC0116a {
            Alert,
            ReloadCatalog,
            Action
        }

        public final void a(String str) {
            if (TextUtils.isEmpty(str)) {
                return;
            }
            if ("Alert".equalsIgnoreCase(str)) {
                this.f8651a = EnumC0116a.Alert;
                return;
            }
            if ("Action".equalsIgnoreCase(str)) {
                this.f8651a = EnumC0116a.Action;
            } else if ("reload_catalog".equalsIgnoreCase(str) || "ReloadCatalog".equalsIgnoreCase(str)) {
                this.f8651a = EnumC0116a.ReloadCatalog;
            }
        }
    }

    static {
        f8634n = zk.g.f49985a.get() ? new h2() : new p2();
        f8635o = new HashMap<>();
        f8638r = new LinkedList();
    }

    // NOTE: `Constants.BRAZE_PUSH_NOTIFICATION_DURATION_KEY` here is almost certainly an R8
    // string-pool-dedup artifact, not a real dependency on Braze: R8 can rewrite a literal to
    // reference an existing `public static final String` elsewhere in the app when its value is
    // identical, rather than embedding a second copy of the same constant. The root SAX element
    // this feeds is literally named "nd" in the request/response XML (see f() below), which is
    // unrelated to anything Braze does — see the case-study note's "plausible but wrong lead"
    // discussion for how this was confirmed harmless.
    public m1(String str, boolean z10) {
        if (f8637q.booleanValue()) {
            throw new RuntimeException("Not supported for instant apps");
        }
        if (TextUtils.isEmpty(str)) {
            throw null;
        }
        this.f8639a = str;
        this.f8643e = z10;
        if (z10) {
            this.f8646h = new dx.b();
            return;
        }
        RootElement rootElement = new RootElement(Constants.BRAZE_PUSH_NOTIFICATION_DURATION_KEY);
        this.f8644f = rootElement;
        Element child = rootElement.getChild("command");
        // ...SAX StartElementListener/EndTextElementListener wiring for <command>/<data>, elided...
        Element child2 = rootElement.getChild("response");
        this.f8645g = child2;
        // ...SAX listeners for <response>, <error-code>, <error-message>,
        // <user-activations><activation activation-number=... client-number=... client-name=...
        // last-active-at=... created-at=...> and <user-name>, elided...
    }

    // Opens a plain HttpURLConnection (NOT okhttp3), instrumented by Firebase Performance
    // Monitoring's HttpURLConnection hook (a sibling of FirebasePerfOkHttpClient, seen elsewhere
    // in this case study wrapping okhttp3 calls instead).
    public static HttpURLConnection a(String str) throws ProtocolException {
        HttpURLConnection httpURLConnection = (HttpURLConnection) ((URLConnection)
            FirebasePerfUrlConnection.instrument(new URL(str).openConnection()));
        httpURLConnection.setInstanceFollowRedirects(true);
        httpURLConnection.setConnectTimeout(30000);
        httpURLConnection.setReadTimeout(30000);
        httpURLConnection.setRequestMethod("GET");
        return httpURLConnection;
    }

    public static boolean b(Service service, File file, String str) {
        // Plain file download over the connection built by a(str); body elided, not relevant to
        // the XML request/response protocol this note documents.
        return false;
    }

    public static ArrayList c() {
        ArrayList arrayList;
        LinkedList linkedList = f8638r;
        synchronized (linkedList) {
            arrayList = new ArrayList(linkedList);
        }
        return arrayList;
    }

    public static void d(String str, ContentHandler contentHandler) throws ProtocolException {
        // GET str via a(str), then feed the response body to an arbitrary SAX ContentHandler
        // (android.util.Xml.parse), with an optional raw-body debug log path; body elided.
    }

    public static String g(Service service) {
        // Blocks (bVar.wait(60000)) until f8634n (an lr.b — h2 or p2, chosen by an A/B flag in
        // <clinit>) finishes running, then returns bVar.a(f8635o.get(f8636p)) — reads as some kind
        // of session/auth-token cache keyed by f8636p, refreshed asynchronously by f8634n; neither
        // h2/p2 nor what f8636p holds was imported into this case study.
        return null;
    }

    public static String[] h() {
        // Returns f8635o's key set as a String[] — the same cache g() reads from.
        return null;
    }

    public static String i(String str) {
        return TextUtils.isEmpty(str) ? str : TextUtils.htmlEncode(str);
    }

    public static void j(Service service) {
        // Pops the first queued ReloadCatalog command (from f8638r, populated by the constructor's
        // SAX listeners or by k() below) and triggers a catalog reload.
    }

    public static synchronized boolean n() {
        return f8634n.b();
    }

    // Builds the <authentication>...</authentication> fragment appended to every request body,
    // once html-encoding the service name/username via i(). Only included if f8641c is set and a
    // Service is supplied — otherwise returns the constructor-cached, unauthenticated f8640b body.
    public final String e(Service service) {
        StringBuilder sb = new StringBuilder();
        Locale locale = Locale.US;
        String strI = i(service.f());
        String strI2 = i(service.f15073j);
        String str = service.k;
        // ...string-builds <service-name>/<user-name>/<activation-number>/<client-number>, elided...
        return sb.toString();
    }

    // Builds the full <?xml ...?><nd version='1.0'><client-info>...</client-info>
    // <request id='0' type='%s'>%s</request></nd> envelope — every request this class sends is
    // this same "nd" document, with `%s` placeholders for the command type and body (see m()).
    public final String f() {
        String str = jq.t0.e().A.f45391f;
        if (!this.f8642d) {
            return "<?xml version='1.0' encoding='UTF-8'?><nd version='1.0'><request id='0' type='%s'>%s</request></nd>";
        }
        // ...html-encodes device model/manufacturer/platform/locale/app id/device token etc. into
        // <client-info>, elided — see the case-study note's excerpt for the literal tag names.
        return null;
    }

    // SAX post-processing after a response document has been parsed: promotes queued command(s)
    // and any parsed <error-code>/<error-message> onto this instance's own fields.
    public final void k() {
        for (dx.b bVar : this.f8646h.f19629f) {
            if (bVar.f19624a.equals("command")) {
                a aVar = new a();
                aVar.a(bVar.c("name"));
                aVar.f8652b = bVar.f19629f.get(0).f19625b;
                LinkedList linkedList = f8638r;
                synchronized (linkedList) {
                    linkedList.add(aVar);
                }
            } else if (bVar.f19624a.equals("response")) {
                this.f8647i = bVar;
                if (bVar.f19630g.containsKey("error-code")) {
                    this.f8648j = Integer.parseInt(this.f8647i.d("error-code").f19625b);
                }
                if (this.f8647i.f19630g.containsKey("error-message")) {
                    this.k = this.f8647i.d("error-message").f19625b;
                }
            }
        }
    }

    public final void l(Service service, String str) {
        m(service, str, 30000, 30000);
    }

    /*
     * JADX could not reconstruct this method's body ("Method dump skipped, instruction units
     * count: 1245" — too large/irregular for its Java-reconstruction pass) — the actual dispatch
     * logic (assembling f()'s envelope around a command type + e()'s auth fragment, POSTing it via
     * a plain HttpURLConnection, and feeding the response into k()'s SAX parser) is not visible
     * through JADX at all. Reading it would need raw baksmali output instead, per
     * [[Reading-Raw-Dalvik]]'s own rationale for when JADX's decompilation gives up.
     */
    public final void m(com.newspaperdirect.pressreader.android.core.Service service, java.lang.String str,
            int connectTimeout, int readTimeout) throws java.lang.Throwable {
        throw new UnsupportedOperationException("Method not decompiled: bp.m1.m(...)");
    }
}
