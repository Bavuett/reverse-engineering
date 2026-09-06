package w50;

import bp.k0;
import com.braze.configuration.BrazeConfigurationProvider;
import com.facebook.gamingservices.internal.TournamentShareDialogURIBuilder;
import java.io.EOFException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

/* JADX INFO: loaded from: classes2.dex */
public final class q {
    public static final char[] k = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f46907a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f46908b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f46909c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f46910d;

    /* JADX INFO: renamed from: e, reason: collision with root package name */
    public final int f46911e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final List<String> f46912f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final List<String> f46913g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final String f46914h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final String f46915i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final boolean f46916j;

    public static final class a {

        /* JADX INFO: renamed from: a, reason: collision with root package name */
        public String f46917a;

        /* JADX INFO: renamed from: d, reason: collision with root package name */
        public String f46920d;

        /* JADX INFO: renamed from: f, reason: collision with root package name */
        public final ArrayList f46922f;

        /* JADX INFO: renamed from: g, reason: collision with root package name */
        public ArrayList f46923g;

        /* JADX INFO: renamed from: h, reason: collision with root package name */
        public String f46924h;

        /* JADX INFO: renamed from: b, reason: collision with root package name */
        public String f46918b = BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE;

        /* JADX INFO: renamed from: c, reason: collision with root package name */
        public String f46919c = BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE;

        /* JADX INFO: renamed from: e, reason: collision with root package name */
        public int f46921e = -1;

        public a() {
            ArrayList arrayList = new ArrayList();
            this.f46922f = arrayList;
            arrayList.add(BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE);
        }

        public final q a() {
            ArrayList arrayList;
            String str = this.f46917a;
            if (str == null) {
                throw new IllegalStateException("scheme == null");
            }
            String strC = b.c(this.f46918b, 0, 0, false, 7);
            String strC2 = b.c(this.f46919c, 0, 0, false, 7);
            String str2 = this.f46920d;
            if (str2 == null) {
                throw new IllegalStateException("host == null");
            }
            int iB = b();
            ArrayList arrayList2 = this.f46922f;
            ArrayList arrayList3 = new ArrayList(o10.n.E(arrayList2));
            Iterator it = arrayList2.iterator();
            while (it.hasNext()) {
                arrayList3.add(b.c((String) it.next(), 0, 0, false, 7));
            }
            ArrayList<String> arrayList4 = this.f46923g;
            if (arrayList4 != null) {
                arrayList = new ArrayList(o10.n.E(arrayList4));
                for (String str3 : arrayList4) {
                    arrayList.add(str3 != null ? b.c(str3, 0, 0, true, 3) : null);
                }
            } else {
                arrayList = null;
            }
            String str4 = this.f46924h;
            return new q(str, strC, strC2, str2, iB, arrayList3, arrayList, str4 != null ? b.c(str4, 0, 0, false, 7) : null, toString());
        }

        public final int b() {
            int i11 = this.f46921e;
            if (i11 != -1) {
                return i11;
            }
            String str = this.f46917a;
            kotlin.jvm.internal.l.c(str);
            if (str.equals("http")) {
                return 80;
            }
            return str.equals(TournamentShareDialogURIBuilder.scheme) ? 443 : -1;
        }

        public final void c(q qVar, String input) throws EOFException {
            // Full URL-parsing state machine (scheme/userinfo/host/port/path/query/fragment),
            // omitted here — irrelevant to the identity confirmation this file was pulled for.
            // See the "How this was found" analysis note for what was actually read out of it.
        }

        public final String toString() {
            StringBuilder sb = new StringBuilder();
            String str = this.f46917a;
            if (str != null) {
                sb.append(str);
                sb.append("://");
            } else {
                sb.append("//");
            }
            if (this.f46918b.length() > 0 || this.f46919c.length() > 0) {
                sb.append(this.f46918b);
                if (this.f46919c.length() > 0) {
                    sb.append(':');
                    sb.append(this.f46919c);
                }
                sb.append('@');
            }
            String str2 = this.f46920d;
            if (str2 != null) {
                if (x40.s.I(str2, ':')) {
                    sb.append('[');
                    sb.append(this.f46920d);
                    sb.append(']');
                } else {
                    sb.append(this.f46920d);
                }
            }
            int i11 = -1;
            if (this.f46921e != -1 || this.f46917a != null) {
                int iB = b();
                String str3 = this.f46917a;
                if (str3 == null) {
                    sb.append(':');
                    sb.append(iB);
                } else {
                    if (str3.equals("http")) {
                        i11 = 80;
                    } else if (str3.equals(TournamentShareDialogURIBuilder.scheme)) {
                        i11 = 443;
                    }
                    if (iB != i11) {
                        sb.append(':');
                        sb.append(iB);
                    }
                }
            }
            ArrayList arrayList = this.f46922f;
            kotlin.jvm.internal.l.f(arrayList, "<this>");
            int size = arrayList.size();
            for (int i12 = 0; i12 < size; i12++) {
                sb.append('/');
                sb.append((String) arrayList.get(i12));
            }
            if (this.f46923g != null) {
                sb.append('?');
                ArrayList arrayList2 = this.f46923g;
                kotlin.jvm.internal.l.c(arrayList2);
                b.e(sb, arrayList2);
            }
            if (this.f46924h != null) {
                sb.append('#');
                sb.append(this.f46924h);
            }
            String string = sb.toString();
            kotlin.jvm.internal.l.e(string, "StringBuilder().apply(builderAction).toString()");
            return string;
        }
    }

    public static final class b {
        // String-encoding/percent-decoding helpers (canonicalize/percentDecode-equivalent),
        // omitted here — not relevant to the identity confirmation this file was pulled for.
    }

    public q(String scheme, String str, String str2, String host, int i11, ArrayList arrayList, ArrayList arrayList2, String str3, String str4) {
        kotlin.jvm.internal.l.f(scheme, "scheme");
        kotlin.jvm.internal.l.f(host, "host");
        this.f46907a = scheme;
        this.f46908b = str;
        this.f46909c = str2;
        this.f46910d = host;
        this.f46911e = i11;
        this.f46912f = arrayList;
        this.f46913g = arrayList2;
        this.f46914h = str3;
        this.f46915i = str4;
        this.f46916j = scheme.equals(TournamentShareDialogURIBuilder.scheme);
    }

    public final String a() {
        // password() equivalent
        return null;
    }

    public final String b() {
        // encodedPath() equivalent
        return null;
    }

    public final ArrayList c() {
        // pathSegments() equivalent
        return null;
    }

    public final String d() {
        // encodedQuery() equivalent
        return null;
    }

    public final String e() {
        // username() equivalent
        return null;
    }

    public final boolean equals(Object obj) {
        return (obj instanceof q) && kotlin.jvm.internal.l.a(((q) obj).f46915i, this.f46915i);
    }

    public final a f() {
        // newBuilder() equivalent
        return null;
    }

    public final a g(String link) throws EOFException {
        // resolve(String) equivalent
        return null;
    }

    public final URI h() {
        // uri() equivalent
        return null;
    }

    public final int hashCode() {
        return this.f46915i.hashCode();
    }

    /**
     * This is the method reached at `w50.q.i(SourceFile:5)` in the forced stack trace captured by
     * inspect-stacktrace.js — see [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] and
     * [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].
     */
    public final URL i() {
        try {
            return new URL(this.f46915i);
        } catch (MalformedURLException e3) {
            throw new RuntimeException(e3);
        }
    }

    public final String toString() {
        return this.f46915i;
    }
}
