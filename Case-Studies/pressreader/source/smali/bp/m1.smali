###### Class bp.m1 (bp.m1)
.class public final Lbp/m1;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lbp/m1$a;
    }
.end annotation


# static fields
.field public static final n:Llr/b;

.field public static final o:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field public static p:Ljava/lang/String;

.field public static q:Ljava/lang/Boolean;

.field public static final r:Ljava/util/LinkedList;


# instance fields
.field public final a:Ljava/lang/String;

.field public b:Ljava/lang/String;

.field public c:Z

.field public d:Z

.field public final e:Z

.field public final f:Landroid/sax/RootElement;

.field public final g:Landroid/sax/Element;

.field public final h:Ldx/b;

.field public i:Ldx/b;

.field public j:I

.field public k:Ljava/lang/String;

.field public final l:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;",
            ">;"
        }
    .end annotation
.end field

.field public m:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 1
    sget-object v0, Lzk/g;->a:Ljava/util/concurrent/atomic/AtomicBoolean;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    .line 4
    .line 5
    .line 6
    move-result v0

    .line 7
    if-eqz v0, :cond_e

    .line 8
    .line 9
    new-instance v0, Lbp/h2;

    .line 10
    .line 11
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    .line 12
    .line 13
    .line 14
    goto :goto_13

    .line 15
    :cond_e
    new-instance v0, Lbp/p2;

    .line 16
    .line 17
    invoke-direct {v0}, Lbp/p2;-><init>()V

    .line 18
    .line 19
    .line 20
    :goto_13
    sput-object v0, Lbp/m1;->n:Llr/b;

    .line 21
    .line 22
    new-instance v0, Ljava/util/HashMap;

    .line 23
    .line 24
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 25
    .line 26
    .line 27
    sput-object v0, Lbp/m1;->o:Ljava/util/HashMap;

    .line 28
    .line 29
    new-instance v0, Ljava/util/LinkedList;

    .line 30
    .line 31
    invoke-direct {v0}, Ljava/util/LinkedList;-><init>()V

    .line 32
    .line 33
    .line 34
    sput-object v0, Lbp/m1;->r:Ljava/util/LinkedList;

    .line 35
    .line 36
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Z)V
    .registers 6

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    const-string v0, ""

    .line 5
    .line 6
    iput-object v0, p0, Lbp/m1;->b:Ljava/lang/String;

    .line 7
    .line 8
    const/4 v0, 0x1

    .line 9
    iput-boolean v0, p0, Lbp/m1;->c:Z

    .line 10
    .line 11
    iput-boolean v0, p0, Lbp/m1;->d:Z

    .line 12
    .line 13
    new-instance v0, Ljava/util/ArrayList;

    .line 14
    .line 15
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 16
    .line 17
    .line 18
    iput-object v0, p0, Lbp/m1;->l:Ljava/util/ArrayList;

    .line 19
    .line 20
    const/4 v0, 0x0

    .line 21
    iput-object v0, p0, Lbp/m1;->m:Ljava/lang/String;

    .line 22
    .line 23
    sget-object v1, Lbp/m1;->q:Ljava/lang/Boolean;

    .line 24
    .line 25
    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    .line 26
    .line 27
    .line 28
    move-result v1

    .line 29
    if-nez v1, :cond_b4

    .line 30
    .line 31
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 32
    .line 33
    .line 34
    move-result v1

    .line 35
    if-nez v1, :cond_b3

    .line 36
    .line 37
    iput-object p1, p0, Lbp/m1;->a:Ljava/lang/String;

    .line 38
    .line 39
    iput-boolean p2, p0, Lbp/m1;->e:Z

    .line 40
    .line 41
    if-eqz p2, :cond_33

    .line 42
    .line 43
    new-instance p1, Ldx/b;

    .line 44
    .line 45
    invoke-direct {p1}, Ldx/b;-><init>()V

    .line 46
    .line 47
    .line 48
    iput-object p1, p0, Lbp/m1;->h:Ldx/b;

    .line 49
    .line 50
    goto/16 :goto_b2

    .line 51
    .line 52
    :cond_33
    new-instance p1, Landroid/sax/RootElement;

    .line 53
    .line 54
    const-string p2, "nd"

    .line 55
    .line 56
    invoke-direct {p1, p2}, Landroid/sax/RootElement;-><init>(Ljava/lang/String;)V

    .line 57
    .line 58
    .line 59
    iput-object p1, p0, Lbp/m1;->f:Landroid/sax/RootElement;

    .line 60
    .line 61
    const-string p2, "command"

    .line 62
    .line 63
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 64
    .line 65
    .line 66
    move-result-object p2

    .line 67
    new-instance v0, Llm/v;

    .line 68
    .line 69
    invoke-direct {v0}, Llm/v;-><init>()V

    .line 70
    .line 71
    .line 72
    new-instance v1, Lbp/f1;

    .line 73
    .line 74
    invoke-direct {v1, v0}, Lbp/f1;-><init>(Llm/v;)V

    .line 75
    .line 76
    .line 77
    invoke-virtual {p2, v1}, Landroid/sax/Element;->setStartElementListener(Landroid/sax/StartElementListener;)V

    .line 78
    .line 79
    .line 80
    const-string v1, "data"

    .line 81
    .line 82
    invoke-virtual {p2, v1}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 83
    .line 84
    .line 85
    move-result-object p2

    .line 86
    new-instance v1, Lbp/g1;

    .line 87
    .line 88
    const/4 v2, 0x0

    .line 89
    invoke-direct {v1, v0, v2}, Lbp/g1;-><init>(Llm/v;I)V

    .line 90
    .line 91
    .line 92
    invoke-virtual {p2, v1}, Landroid/sax/Element;->setEndTextElementListener(Landroid/sax/EndTextElementListener;)V

    .line 93
    .line 94
    .line 95
    const-string p2, "response"

    .line 96
    .line 97
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 98
    .line 99
    .line 100
    move-result-object p1

    .line 101
    iput-object p1, p0, Lbp/m1;->g:Landroid/sax/Element;

    .line 102
    .line 103
    new-instance p2, Lbp/h1;

    .line 104
    .line 105
    invoke-direct {p2, p0}, Lbp/h1;-><init>(Lbp/m1;)V

    .line 106
    .line 107
    .line 108
    invoke-virtual {p1, p2}, Landroid/sax/Element;->setStartElementListener(Landroid/sax/StartElementListener;)V

    .line 109
    .line 110
    .line 111
    const-string p2, "error-code"

    .line 112
    .line 113
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 114
    .line 115
    .line 116
    move-result-object p2

    .line 117
    new-instance v0, Lum/d0;

    .line 118
    .line 119
    const/4 v1, 0x2

    .line 120
    invoke-direct {v0, v1, p0}, Lum/d0;-><init>(ILjava/lang/Object;)V

    .line 121
    .line 122
    .line 123
    invoke-virtual {p2, v0}, Landroid/sax/Element;->setEndTextElementListener(Landroid/sax/EndTextElementListener;)V

    .line 124
    .line 125
    .line 126
    const-string p2, "error-message"

    .line 127
    .line 128
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 129
    .line 130
    .line 131
    move-result-object p2

    .line 132
    new-instance v0, Lbp/i1;

    .line 133
    .line 134
    const/4 v1, 0x0

    .line 135
    invoke-direct {v0, v1, p0}, Lbp/i1;-><init>(ILjava/lang/Object;)V

    .line 136
    .line 137
    .line 138
    invoke-virtual {p2, v0}, Landroid/sax/Element;->setEndTextElementListener(Landroid/sax/EndTextElementListener;)V

    .line 139
    .line 140
    .line 141
    const-string p2, "user-activations"

    .line 142
    .line 143
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 144
    .line 145
    .line 146
    move-result-object v0

    .line 147
    const-string v1, "activation"

    .line 148
    .line 149
    invoke-virtual {v0, v1}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 150
    .line 151
    .line 152
    move-result-object v0

    .line 153
    new-instance v1, Lbp/j1;

    .line 154
    .line 155
    invoke-direct {v1, p0}, Lbp/j1;-><init>(Lbp/m1;)V

    .line 156
    .line 157
    .line 158
    invoke-virtual {v0, v1}, Landroid/sax/Element;->setStartElementListener(Landroid/sax/StartElementListener;)V

    .line 159
    .line 160
    .line 161
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 162
    .line 163
    .line 164
    move-result-object p1

    .line 165
    const-string p2, "user-name"

    .line 166
    .line 167
    invoke-virtual {p1, p2}, Landroid/sax/Element;->getChild(Ljava/lang/String;)Landroid/sax/Element;

    .line 168
    .line 169
    .line 170
    move-result-object p1

    .line 171
    new-instance p2, Lbp/l1;

    .line 172
    .line 173
    invoke-direct {p2, p0}, Lbp/l1;-><init>(Lbp/m1;)V

    .line 174
    .line 175
    .line 176
    invoke-virtual {p1, p2}, Landroid/sax/Element;->setTextElementListener(Landroid/sax/TextElementListener;)V

    .line 177
    .line 178
    .line 179
    :goto_b2
    return-void

    .line 180
    :cond_b3
    throw v0

    .line 181
    :cond_b4
    new-instance p1, Ljava/lang/RuntimeException;

    .line 182
    .line 183
    const-string p2, "Not supported for instant apps"

    .line 184
    .line 185
    invoke-direct {p1, p2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    .line 186
    .line 187
    .line 188
    throw p1
.end method

.method public static a(Ljava/lang/String;)Ljava/net/HttpURLConnection;
    .registers 2

    .line 1
    new-instance v0, Ljava/net/URL;

    .line 2
    .line 3
    invoke-direct {v0, p0}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    .line 4
    .line 5
    .line 6
    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    .line 7
    .line 8
    .line 9
    move-result-object p0

    .line 10
    invoke-static {p0}, Lcom/google/firebase/perf/network/FirebasePerfUrlConnection;->instrument(Ljava/lang/Object;)Ljava/lang/Object;

    .line 11
    .line 12
    .line 13
    move-result-object p0

    .line 14
    check-cast p0, Ljava/net/URLConnection;

    .line 15
    .line 16
    check-cast p0, Ljava/net/HttpURLConnection;

    .line 17
    .line 18
    const/4 v0, 0x1

    .line 19
    invoke-virtual {p0, v0}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 20
    .line 21
    .line 22
    const/16 v0, 0x7530

    .line 23
    .line 24
    invoke-virtual {p0, v0}, Ljava/net/URLConnection;->setConnectTimeout(I)V

    .line 25
    .line 26
    .line 27
    invoke-virtual {p0, v0}, Ljava/net/URLConnection;->setReadTimeout(I)V

    .line 28
    .line 29
    .line 30
    const-string v0, "GET"

    .line 31
    .line 32
    invoke-virtual {p0, v0}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 33
    .line 34
    .line 35
    return-object p0
.end method

.method public static b(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/io/File;Ljava/lang/String;)Z
    .registers 9

    .line 1
    const-string v0, "downloadContent failed from "

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    const/4 v2, 0x0

    .line 5
    :try_start_4
    invoke-static {p2}, Lbp/m1;->a(Ljava/lang/String;)Ljava/net/HttpURLConnection;

    .line 6
    .line 7
    .line 8
    move-result-object v3
    :try_end_8
    .catchall {:try_start_4 .. :try_end_8} :catchall_33

    .line 9
    :try_start_8
    invoke-virtual {v3}, Ljava/net/HttpURLConnection;->getResponseCode()I

    .line 10
    .line 11
    .line 12
    move-result v4

    .line 13
    const/16 v5, 0xc8

    .line 14
    .line 15
    if-ne v4, v5, :cond_27

    .line 16
    .line 17
    invoke-virtual {v3}, Ljava/net/URLConnection;->getInputStream()Ljava/io/InputStream;

    .line 18
    .line 19
    .line 20
    move-result-object v2

    .line 21
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 22
    .line 23
    .line 24
    move-result-object v4

    .line 25
    invoke-static {v2, v4}, Lvw/c;->j(Ljava/io/InputStream;Ljava/lang/String;)V

    .line 26
    .line 27
    .line 28
    if-eqz p0, :cond_23

    .line 29
    .line 30
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 31
    .line 32
    .line 33
    move-result-wide v4

    .line 34
    iput-wide v4, p0, Lcom/newspaperdirect/pressreader/android/core/Service;->o:J
    :try_end_23
    .catchall {:try_start_8 .. :try_end_23} :catchall_25

    .line 35
    .line 36
    :cond_23
    const/4 v1, 0x1

    .line 37
    goto :goto_27

    .line 38
    :catchall_25
    move-exception p0

    .line 39
    goto :goto_35

    .line 40
    :cond_27
    :goto_27
    if-nez v1, :cond_2c

    .line 41
    .line 42
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    .line 43
    .line 44
    .line 45
    :cond_2c
    invoke-static {v2}, Lvw/c;->b(Ljava/io/Closeable;)V

    .line 46
    .line 47
    .line 48
    :goto_2f
    invoke-virtual {v3}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 49
    .line 50
    .line 51
    goto :goto_56

    .line 52
    :catchall_33
    move-exception p0

    .line 53
    move-object v3, v2

    .line 54
    :goto_35
    :try_start_35
    new-instance v4, Ljava/lang/StringBuilder;

    .line 55
    .line 56
    invoke-direct {v4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 57
    .line 58
    .line 59
    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 60
    .line 61
    .line 62
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 63
    .line 64
    .line 65
    move-result-object p2

    .line 66
    const-string v0, "HttpRequestHelper"

    .line 67
    .line 68
    sget-object v4, Lj70/a;->a:Lj70/a$a;

    .line 69
    .line 70
    invoke-virtual {v4, v0}, Lj70/a$a;->n(Ljava/lang/String;)V

    .line 71
    .line 72
    .line 73
    new-array v0, v1, [Ljava/lang/Object;

    .line 74
    .line 75
    invoke-virtual {v4, p0, p2, v0}, Lj70/a$a;->e(Ljava/lang/Throwable;Ljava/lang/String;[Ljava/lang/Object;)V
    :try_end_4d
    .catchall {:try_start_35 .. :try_end_4d} :catchall_57

    .line 76
    .line 77
    .line 78
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    .line 79
    .line 80
    .line 81
    invoke-static {v2}, Lvw/c;->b(Ljava/io/Closeable;)V

    .line 82
    .line 83
    .line 84
    if-eqz v3, :cond_56

    .line 85
    .line 86
    goto :goto_2f

    .line 87
    :cond_56
    :goto_56
    return v1

    .line 88
    :catchall_57
    move-exception p0

    .line 89
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    .line 90
    .line 91
    .line 92
    invoke-static {v2}, Lvw/c;->b(Ljava/io/Closeable;)V

    .line 93
    .line 94
    .line 95
    if-eqz v3, :cond_63

    .line 96
    .line 97
    invoke-virtual {v3}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 98
    .line 99
    .line 100
    :cond_63
    throw p0
.end method

.method public static c()Ljava/util/ArrayList;
    .registers 2

    .line 1
    sget-object v0, Lbp/m1;->r:Ljava/util/LinkedList;

    .line 2
    .line 3
    monitor-enter v0

    .line 4
    :try_start_3
    new-instance v1, Ljava/util/ArrayList;

    .line 5
    .line 6
    invoke-direct {v1, v0}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 7
    .line 8
    .line 9
    monitor-exit v0

    .line 10
    return-object v1

    .line 11
    :catchall_a
    move-exception v1

    .line 12
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_a

    .line 13
    throw v1
.end method

.method public static d(Ljava/lang/String;Lorg/xml/sax/ContentHandler;)V
    .registers 10

    .line 1
    const-string v0, "HttpRequestHelper"

    .line 2
    .line 3
    invoke-static {p0}, Lbp/m1;->a(Ljava/lang/String;)Ljava/net/HttpURLConnection;

    .line 4
    .line 5
    .line 6
    move-result-object v1

    .line 7
    const/4 v2, 0x0

    .line 8
    const/4 v3, 0x0

    .line 9
    :try_start_8
    invoke-virtual {v1}, Ljava/net/URLConnection;->getInputStream()Ljava/io/InputStream;

    .line 10
    .line 11
    .line 12
    move-result-object v3

    .line 13
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 14
    .line 15
    .line 16
    move-result-object v4

    .line 17
    invoke-virtual {v4}, Ljq/t0;->s()Lvn/j;

    .line 18
    .line 19
    .line 20
    move-result-object v4

    .line 21
    invoke-virtual {v4}, Lvn/j;->n()Z

    .line 22
    .line 23
    .line 24
    move-result v4

    .line 25
    if-eqz v4, :cond_5d

    .line 26
    .line 27
    new-instance v4, Ljava/io/BufferedReader;

    .line 28
    .line 29
    new-instance v5, Ljava/io/InputStreamReader;

    .line 30
    .line 31
    invoke-direct {v5, v3}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V

    .line 32
    .line 33
    .line 34
    invoke-direct {v4, v5}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 35
    .line 36
    .line 37
    new-instance v5, Ljava/lang/StringBuilder;

    .line 38
    .line 39
    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    .line 40
    .line 41
    .line 42
    :goto_29
    invoke-virtual {v4}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    .line 43
    .line 44
    .line 45
    move-result-object v6

    .line 46
    if-eqz v6, :cond_37

    .line 47
    .line 48
    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 49
    .line 50
    .line 51
    goto :goto_29

    .line 52
    :catchall_33
    move-exception p0

    .line 53
    goto :goto_94

    .line 54
    :catch_35
    move-exception p1

    .line 55
    goto :goto_70

    .line 56
    :cond_37
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 57
    .line 58
    .line 59
    move-result-object v4

    .line 60
    sget-object v5, Lj70/a;->a:Lj70/a$a;

    .line 61
    .line 62
    invoke-virtual {v5, v0}, Lj70/a$a;->n(Ljava/lang/String;)V

    .line 63
    .line 64
    .line 65
    new-instance v6, Ljava/lang/StringBuilder;

    .line 66
    .line 67
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    .line 68
    .line 69
    .line 70
    invoke-virtual {v6, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 71
    .line 72
    .line 73
    const-string v7, "->\n"

    .line 74
    .line 75
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 76
    .line 77
    .line 78
    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 79
    .line 80
    .line 81
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 82
    .line 83
    .line 84
    move-result-object v6

    .line 85
    new-array v7, v2, [Ljava/lang/Object;

    .line 86
    .line 87
    invoke-virtual {v5, v6, v7}, Lj70/a$a;->a(Ljava/lang/String;[Ljava/lang/Object;)V

    .line 88
    .line 89
    .line 90
    invoke-static {v4, p1}, Landroid/util/Xml;->parse(Ljava/lang/String;Lorg/xml/sax/ContentHandler;)V

    .line 91
    .line 92
    .line 93
    goto :goto_62

    .line 94
    :cond_5d
    sget-object v4, Landroid/util/Xml$Encoding;->UTF_8:Landroid/util/Xml$Encoding;

    .line 95
    .line 96
    invoke-static {v3, v4, p1}, Landroid/util/Xml;->parse(Ljava/io/InputStream;Landroid/util/Xml$Encoding;Lorg/xml/sax/ContentHandler;)V
    :try_end_62
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_62} :catch_35
    .catchall {:try_start_8 .. :try_end_62} :catchall_33

    .line 97
    .line 98
    .line 99
    :goto_62
    if-eqz v3, :cond_6c

    .line 100
    .line 101
    :try_start_64
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_67
    .catch Ljava/io/IOException; {:try_start_64 .. :try_end_67} :catch_68

    .line 102
    .line 103
    .line 104
    goto :goto_6c

    .line 105
    :catch_68
    move-exception p0

    .line 106
    :goto_69
    invoke-static {p0}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 107
    .line 108
    .line 109
    :cond_6c
    :goto_6c
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 110
    .line 111
    .line 112
    goto :goto_93

    .line 113
    :goto_70
    :try_start_70
    new-instance v4, Ljava/lang/StringBuilder;

    .line 114
    .line 115
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    .line 116
    .line 117
    .line 118
    const-string v5, "getContent failed from "

    .line 119
    .line 120
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 121
    .line 122
    .line 123
    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 124
    .line 125
    .line 126
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 127
    .line 128
    .line 129
    move-result-object p0

    .line 130
    sget-object v4, Lj70/a;->a:Lj70/a$a;

    .line 131
    .line 132
    invoke-virtual {v4, v0}, Lj70/a$a;->n(Ljava/lang/String;)V

    .line 133
    .line 134
    .line 135
    new-array v0, v2, [Ljava/lang/Object;

    .line 136
    .line 137
    invoke-virtual {v4, p1, p0, v0}, Lj70/a$a;->e(Ljava/lang/Throwable;Ljava/lang/String;[Ljava/lang/Object;)V
    :try_end_8b
    .catchall {:try_start_70 .. :try_end_8b} :catchall_33

    .line 138
    .line 139
    .line 140
    if-eqz v3, :cond_6c

    .line 141
    .line 142
    :try_start_8d
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_90
    .catch Ljava/io/IOException; {:try_start_8d .. :try_end_90} :catch_91

    .line 143
    .line 144
    .line 145
    goto :goto_6c

    .line 146
    :catch_91
    move-exception p0

    .line 147
    goto :goto_69

    .line 148
    :goto_93
    return-void

    .line 149
    :goto_94
    if-eqz v3, :cond_9e

    .line 150
    .line 151
    :try_start_96
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_99
    .catch Ljava/io/IOException; {:try_start_96 .. :try_end_99} :catch_9a

    .line 152
    .line 153
    .line 154
    goto :goto_9e

    .line 155
    :catch_9a
    move-exception p1

    .line 156
    invoke-static {p1}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 157
    .line 158
    .line 159
    :cond_9e
    :goto_9e
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 160
    .line 161
    .line 162
    throw p0
.end method

.method public static g(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;
    .registers 4

    .line 1
    if-eqz p0, :cond_d

    .line 2
    .line 3
    iget-object v0, p0, Lcom/newspaperdirect/pressreader/android/core/Service;->n:Ljava/lang/String;

    .line 4
    .line 5
    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 6
    .line 7
    .line 8
    move-result v0

    .line 9
    if-nez v0, :cond_d

    .line 10
    .line 11
    iget-object p0, p0, Lcom/newspaperdirect/pressreader/android/core/Service;->n:Ljava/lang/String;

    .line 12
    .line 13
    return-object p0

    .line 14
    :cond_d
    sget-object p0, Lbp/m1;->n:Llr/b;

    .line 15
    .line 16
    monitor-enter p0

    .line 17
    :goto_10
    :try_start_10
    sget-object v0, Lbp/m1;->n:Llr/b;

    .line 18
    .line 19
    invoke-interface {v0}, Llr/b;->isRunning()Z

    .line 20
    .line 21
    .line 22
    move-result v1
    :try_end_16
    .catchall {:try_start_10 .. :try_end_16} :catchall_1f

    .line 23
    if-eqz v1, :cond_26

    .line 24
    .line 25
    const-wide/32 v1, 0xea60

    .line 26
    .line 27
    .line 28
    :try_start_1b
    invoke-virtual {v0, v1, v2}, Ljava/lang/Object;->wait(J)V
    :try_end_1e
    .catch Ljava/lang/InterruptedException; {:try_start_1b .. :try_end_1e} :catch_21
    .catchall {:try_start_1b .. :try_end_1e} :catchall_1f

    .line 29
    .line 30
    .line 31
    goto :goto_10

    .line 32
    :catchall_1f
    move-exception v0

    .line 33
    goto :goto_36

    .line 34
    :catch_21
    move-exception v0

    .line 35
    :try_start_22
    invoke-static {v0}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 36
    .line 37
    .line 38
    goto :goto_10

    .line 39
    :cond_26
    monitor-exit p0
    :try_end_27
    .catchall {:try_start_22 .. :try_end_27} :catchall_1f

    .line 40
    sget-object p0, Lbp/m1;->o:Ljava/util/HashMap;

    .line 41
    .line 42
    sget-object v1, Lbp/m1;->p:Ljava/lang/String;

    .line 43
    .line 44
    invoke-virtual {p0, v1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 45
    .line 46
    .line 47
    move-result-object p0

    .line 48
    check-cast p0, Ljava/lang/String;

    .line 49
    .line 50
    invoke-interface {v0, p0}, Llr/b;->a(Ljava/lang/String;)Ljava/lang/String;

    .line 51
    .line 52
    .line 53
    move-result-object p0

    .line 54
    return-object p0

    .line 55
    :goto_36
    :try_start_36
    monitor-exit p0
    :try_end_37
    .catchall {:try_start_36 .. :try_end_37} :catchall_1f

    .line 56
    throw v0
.end method

.method public static h()[Ljava/lang/String;
    .registers 5

    .line 1
    sget-object v0, Lbp/m1;->o:Ljava/util/HashMap;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/util/HashMap;->size()I

    .line 4
    .line 5
    .line 6
    move-result v1

    .line 7
    new-array v1, v1, [Ljava/lang/String;

    .line 8
    .line 9
    invoke-virtual {v0}, Ljava/util/HashMap;->keySet()Ljava/util/Set;

    .line 10
    .line 11
    .line 12
    move-result-object v0

    .line 13
    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    .line 14
    .line 15
    .line 16
    move-result-object v0

    .line 17
    const/4 v2, 0x0

    .line 18
    :goto_11
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    .line 19
    .line 20
    .line 21
    move-result v3

    .line 22
    if-eqz v3, :cond_23

    .line 23
    .line 24
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 25
    .line 26
    .line 27
    move-result-object v3

    .line 28
    check-cast v3, Ljava/lang/String;

    .line 29
    .line 30
    add-int/lit8 v4, v2, 0x1

    .line 31
    .line 32
    aput-object v3, v1, v2

    .line 33
    .line 34
    move v2, v4

    .line 35
    goto :goto_11

    .line 36
    :cond_23
    return-object v1
.end method

.method public static i(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    .line 1
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-eqz v0, :cond_7

    .line 6
    .line 7
    goto :goto_b

    .line 8
    :cond_7
    invoke-static {p0}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    .line 9
    .line 10
    .line 11
    move-result-object p0

    .line 12
    :goto_b
    return-object p0
.end method

.method public static j(Lcom/newspaperdirect/pressreader/android/core/Service;)V
    .registers 5

    .line 1
    invoke-static {}, Lbp/m1;->c()Ljava/util/ArrayList;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    .line 6
    .line 7
    .line 8
    move-result-object v0

    .line 9
    :cond_8
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_31

    .line 14
    .line 15
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    check-cast v1, Lbp/m1$a;

    .line 20
    .line 21
    sget-object v2, Lbp/m1$a$a;->ReloadCatalog:Lbp/m1$a$a;

    .line 22
    .line 23
    iget-object v3, v1, Lbp/m1$a;->a:Lbp/m1$a$a;

    .line 24
    .line 25
    invoke-virtual {v2, v3}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    .line 26
    .line 27
    .line 28
    move-result v2

    .line 29
    if-eqz v2, :cond_8

    .line 30
    .line 31
    sget-object v2, Lbp/m1;->r:Ljava/util/LinkedList;

    .line 32
    .line 33
    monitor-enter v2

    .line 34
    :try_start_21
    invoke-virtual {v2, v1}, Ljava/util/LinkedList;->remove(Ljava/lang/Object;)Z

    .line 35
    .line 36
    .line 37
    monitor-exit v2
    :try_end_25
    .catchall {:try_start_21 .. :try_end_25} :catchall_2e

    .line 38
    const/4 v0, 0x0

    .line 39
    invoke-static {p0, v0}, Ldn/j;->a(Lcom/newspaperdirect/pressreader/android/core/Service;Z)Ldn/i;

    .line 40
    .line 41
    .line 42
    move-result-object p0

    .line 43
    invoke-virtual {p0}, Ldn/i;->e()V

    .line 44
    .line 45
    .line 46
    goto :goto_31

    .line 47
    :catchall_2e
    move-exception p0

    .line 48
    :try_start_2f
    monitor-exit v2
    :try_end_30
    .catchall {:try_start_2f .. :try_end_30} :catchall_2e

    .line 49
    throw p0

    .line 50
    :cond_31
    :goto_31
    return-void
.end method

.method public static declared-synchronized n()Z
    .registers 2

    .line 1
    const-class v0, Lbp/m1;

    .line 2
    .line 3
    monitor-enter v0

    .line 4
    :try_start_3
    sget-object v1, Lbp/m1;->n:Llr/b;

    .line 5
    .line 6
    invoke-interface {v1}, Llr/b;->b()Z

    .line 7
    .line 8
    .line 9
    move-result v1
    :try_end_9
    .catchall {:try_start_3 .. :try_end_9} :catchall_b

    .line 10
    monitor-exit v0

    .line 11
    return v1

    .line 12
    :catchall_b
    move-exception v1

    .line 13
    monitor-exit v0

    .line 14
    throw v1
.end method


# virtual methods
.method public final e(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;
    .registers 9

    .line 1
    iget-boolean v0, p0, Lbp/m1;->c:Z

    .line 2
    .line 3
    if-eqz v0, :cond_53

    .line 4
    .line 5
    if-nez p1, :cond_7

    .line 6
    .line 7
    goto :goto_53

    .line 8
    :cond_7
    new-instance v0, Ljava/lang/StringBuilder;

    .line 9
    .line 10
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 11
    .line 12
    .line 13
    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    .line 14
    .line 15
    invoke-virtual {p1}, Lcom/newspaperdirect/pressreader/android/core/Service;->f()Ljava/lang/String;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    invoke-static {v1}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 20
    .line 21
    .line 22
    move-result-object v1

    .line 23
    iget-object v2, p1, Lcom/newspaperdirect/pressreader/android/core/Service;->j:Ljava/lang/String;

    .line 24
    .line 25
    invoke-static {v2}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 26
    .line 27
    .line 28
    move-result-object v2

    .line 29
    iget-object p1, p1, Lcom/newspaperdirect/pressreader/android/core/Service;->k:Ljava/lang/String;

    .line 30
    .line 31
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 32
    .line 33
    .line 34
    move-result-object v3

    .line 35
    iget-object v3, v3, Ljq/t0;->A:Lvn/i;

    .line 36
    .line 37
    invoke-virtual {v3}, Lvn/i;->b()I

    .line 38
    .line 39
    .line 40
    move-result v3

    .line 41
    const-string v4, "<service-name>"

    .line 42
    .line 43
    const-string v5, "</service-name><authentication><user-name>"

    .line 44
    .line 45
    const-string v6, "</user-name><activation-number>"

    .line 46
    .line 47
    invoke-static {v4, v1, v5, v2, v6}, Landroidx/datastore/preferences/protobuf/e;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 48
    .line 49
    .line 50
    move-result-object v1

    .line 51
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 52
    .line 53
    .line 54
    const-string p1, "</activation-number><client-number>"

    .line 55
    .line 56
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 57
    .line 58
    .line 59
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 60
    .line 61
    .line 62
    const-string p1, "</client-number></authentication>"

    .line 63
    .line 64
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 65
    .line 66
    .line 67
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 68
    .line 69
    .line 70
    move-result-object p1

    .line 71
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 72
    .line 73
    .line 74
    iget-object p1, p0, Lbp/m1;->b:Ljava/lang/String;

    .line 75
    .line 76
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 77
    .line 78
    .line 79
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 80
    .line 81
    .line 82
    move-result-object p1

    .line 83
    return-object p1

    .line 84
    :cond_53
    :goto_53
    iget-object p1, p0, Lbp/m1;->b:Ljava/lang/String;

    .line 85
    .line 86
    return-object p1
.end method

.method public final f()Ljava/lang/String;
    .registers 17

    .line 1
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    iget-object v0, v0, Ljq/t0;->A:Lvn/i;

    .line 6
    .line 7
    iget-object v0, v0, Lvn/i;->f:Ljava/lang/String;

    .line 8
    .line 9
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 10
    .line 11
    .line 12
    move-result-object v1

    .line 13
    invoke-virtual {v1}, Ljq/t0;->a()Lvn/a;

    .line 14
    .line 15
    .line 16
    move-result-object v1

    .line 17
    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 18
    .line 19
    .line 20
    move-object/from16 v1, p0

    .line 21
    .line 22
    iget-boolean v2, v1, Lbp/m1;->d:Z

    .line 23
    .line 24
    if-eqz v2, :cond_ec

    .line 25
    .line 26
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 27
    .line 28
    .line 29
    move-result-object v2

    .line 30
    iget-object v2, v2, Ljq/t0;->A:Lvn/i;

    .line 31
    .line 32
    iget-object v2, v2, Lvn/i;->m:Ljava/lang/String;

    .line 33
    .line 34
    invoke-static {v2}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 35
    .line 36
    .line 37
    move-result-object v2

    .line 38
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 39
    .line 40
    .line 41
    move-result-object v3

    .line 42
    iget-object v3, v3, Ljq/t0;->A:Lvn/i;

    .line 43
    .line 44
    iget-object v3, v3, Lvn/i;->m:Ljava/lang/String;

    .line 45
    .line 46
    invoke-static {v3}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 47
    .line 48
    .line 49
    move-result-object v3

    .line 50
    invoke-static {}, Landroidx/datastore/preferences/protobuf/l1;->t()Z

    .line 51
    .line 52
    .line 53
    move-result v4

    .line 54
    if-eqz v4, :cond_3a

    .line 55
    .line 56
    const-string v4, "AndroidTablet"

    .line 57
    .line 58
    goto :goto_3c

    .line 59
    :cond_3a
    const-string v4, "AndroidPhone"

    .line 60
    .line 61
    :goto_3c
    invoke-static {v4}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 62
    .line 63
    .line 64
    move-result-object v4

    .line 65
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 66
    .line 67
    .line 68
    move-result-object v5

    .line 69
    iget-object v5, v5, Ljq/t0;->A:Lvn/i;

    .line 70
    .line 71
    iget-object v5, v5, Lvn/i;->c:Ljava/lang/String;

    .line 72
    .line 73
    invoke-static {v5}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 74
    .line 75
    .line 76
    move-result-object v5

    .line 77
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 78
    .line 79
    .line 80
    move-result-object v6

    .line 81
    iget-object v6, v6, Ljq/t0;->A:Lvn/i;

    .line 82
    .line 83
    iget-object v6, v6, Lvn/i;->d:Ljava/lang/String;

    .line 84
    .line 85
    invoke-static {v6}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 86
    .line 87
    .line 88
    move-result-object v6

    .line 89
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 90
    .line 91
    .line 92
    move-result-object v7

    .line 93
    iget-object v7, v7, Ljq/t0;->A:Lvn/i;

    .line 94
    .line 95
    iget-object v7, v7, Lvn/i;->b:Ljava/lang/String;

    .line 96
    .line 97
    invoke-static {v7}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 98
    .line 99
    .line 100
    move-result-object v7

    .line 101
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 102
    .line 103
    .line 104
    move-result-object v8

    .line 105
    iget-object v8, v8, Ljq/t0;->A:Lvn/i;

    .line 106
    .line 107
    iget-object v8, v8, Lvn/i;->k:Ljava/lang/String;

    .line 108
    .line 109
    invoke-static {v8}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 110
    .line 111
    .line 112
    move-result-object v8

    .line 113
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    .line 114
    .line 115
    .line 116
    move-result-object v9

    .line 117
    invoke-virtual {v9}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;

    .line 118
    .line 119
    .line 120
    move-result-object v9

    .line 121
    invoke-static {v9}, Ldn/w;->a(Ljava/lang/String;)Ljava/lang/String;

    .line 122
    .line 123
    .line 124
    move-result-object v9

    .line 125
    invoke-static {v9}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 126
    .line 127
    .line 128
    move-result-object v9

    .line 129
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    .line 130
    .line 131
    .line 132
    move-result-object v10

    .line 133
    invoke-virtual {v10}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    .line 134
    .line 135
    .line 136
    move-result-object v10

    .line 137
    invoke-static {v10}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 138
    .line 139
    .line 140
    move-result-object v10

    .line 141
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    .line 142
    .line 143
    .line 144
    move-result-object v11

    .line 145
    invoke-virtual {v11}, Ljava/util/Locale;->getVariant()Ljava/lang/String;

    .line 146
    .line 147
    .line 148
    move-result-object v11

    .line 149
    invoke-static {v11}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 150
    .line 151
    .line 152
    move-result-object v11

    .line 153
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 154
    .line 155
    .line 156
    move-result-object v12

    .line 157
    iget-object v12, v12, Ljq/t0;->d:Landroid/content/Context;

    .line 158
    .line 159
    invoke-virtual {v12}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    .line 160
    .line 161
    .line 162
    move-result-object v12

    .line 163
    invoke-static {v12}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 164
    .line 165
    .line 166
    move-result-object v12

    .line 167
    invoke-static {v0}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 168
    .line 169
    .line 170
    move-result-object v0

    .line 171
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 172
    .line 173
    .line 174
    move-result-object v13

    .line 175
    invoke-virtual {v13}, Ljq/t0;->s()Lvn/j;

    .line 176
    .line 177
    .line 178
    move-result-object v13

    .line 179
    iget-object v13, v13, Lvn/j;->q:Ljava/lang/String;

    .line 180
    .line 181
    invoke-static {v13}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    .line 182
    .line 183
    .line 184
    move-result-object v13

    .line 185
    const-string v14, "<?xml version=\'1.0\' encoding=\'UTF-8\'?><nd version=\'1.0\'><client-info><software>PRAndroid</software><version>"

    .line 186
    .line 187
    const-string v15, "</version><app-version>"

    .line 188
    .line 189
    const-string v1, "</app-version><client-type>PC</client-type><client-subtype>"

    .line 190
    .line 191
    invoke-static {v14, v2, v15, v3, v1}, Landroidx/datastore/preferences/protobuf/e;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 192
    .line 193
    .line 194
    move-result-object v1

    .line 195
    const-string v2, "</client-subtype><system-manufacturer>"

    .line 196
    .line 197
    const-string v3, "</system-manufacturer><system-model>"

    .line 198
    .line 199
    invoke-static {v1, v4, v2, v5, v3}, Lbp/g;->b(Ljava/lang/StringBuilder;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 200
    .line 201
    .line 202
    const-string v2, "</system-model><system-platform>"

    .line 203
    .line 204
    const-string v3, "</system-platform><installkey1>"

    .line 205
    .line 206
    invoke-static {v1, v6, v2, v7, v3}, Lbp/g;->b(Ljava/lang/StringBuilder;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 207
    .line 208
    .line 209
    const-string v2, "</installkey1><client-locale-language>"

    .line 210
    .line 211
    const-string v3, "</client-locale-language><client-locale-country>"

    .line 212
    .line 213
    invoke-static {v1, v8, v2, v9, v3}, Lbp/g;->b(Ljava/lang/StringBuilder;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 214
    .line 215
    .line 216
    const-string v2, "</client-locale-country><client-locale-variant>"

    .line 217
    .line 218
    const-string v3, "</client-locale-variant><application-id>"

    .line 219
    .line 220
    invoke-static {v1, v10, v2, v11, v3}, Lbp/g;->b(Ljava/lang/StringBuilder;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 221
    .line 222
    .line 223
    const-string v2, "</application-id><default-service-name>"

    .line 224
    .line 225
    const-string v3, "</default-service-name><device-token>"

    .line 226
    .line 227
    invoke-static {v1, v12, v2, v0, v3}, Lbp/g;->b(Ljava/lang/StringBuilder;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 228
    .line 229
    .line 230
    const-string v0, "</device-token></client-info><request id=\'0\' type=\'%s\'>%s</request></nd>"

    .line 231
    .line 232
    invoke-static {v1, v13, v0}, Landroidx/car/app/model/a;->c(Ljava/lang/StringBuilder;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 233
    .line 234
    .line 235
    move-result-object v0

    .line 236
    return-object v0

    .line 237
    :cond_ec
    const-string v0, "<?xml version=\'1.0\' encoding=\'UTF-8\'?><nd version=\'1.0\'><request id=\'0\' type=\'%s\'>%s</request></nd>"

    .line 238
    .line 239
    return-object v0
.end method

.method public final k()V
    .registers 5

    .line 1
    iget-object v0, p0, Lbp/m1;->h:Ldx/b;

    .line 2
    .line 3
    iget-object v0, v0, Ldx/b;->f:Ljava/util/ArrayList;

    .line 4
    .line 5
    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    .line 6
    .line 7
    .line 8
    move-result-object v0

    .line 9
    :cond_8
    :goto_8
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    .line 10
    .line 11
    .line 12
    move-result v1

    .line 13
    if-eqz v1, :cond_83

    .line 14
    .line 15
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 16
    .line 17
    .line 18
    move-result-object v1

    .line 19
    check-cast v1, Ldx/b;

    .line 20
    .line 21
    iget-object v2, v1, Ldx/b;->a:Ljava/lang/String;

    .line 22
    .line 23
    const-string v3, "command"

    .line 24
    .line 25
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 26
    .line 27
    .line 28
    move-result v2

    .line 29
    if-eqz v2, :cond_44

    .line 30
    .line 31
    new-instance v2, Lbp/m1$a;

    .line 32
    .line 33
    invoke-direct {v2}, Lbp/m1$a;-><init>()V

    .line 34
    .line 35
    .line 36
    const-string v3, "name"

    .line 37
    .line 38
    invoke-virtual {v1, v3}, Ldx/b;->c(Ljava/lang/String;)Ljava/lang/String;

    .line 39
    .line 40
    .line 41
    move-result-object v3

    .line 42
    invoke-virtual {v2, v3}, Lbp/m1$a;->a(Ljava/lang/String;)V

    .line 43
    .line 44
    .line 45
    iget-object v1, v1, Ldx/b;->f:Ljava/util/ArrayList;

    .line 46
    .line 47
    const/4 v3, 0x0

    .line 48
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 49
    .line 50
    .line 51
    move-result-object v1

    .line 52
    check-cast v1, Ldx/b;

    .line 53
    .line 54
    iget-object v1, v1, Ldx/b;->b:Ljava/lang/String;

    .line 55
    .line 56
    iput-object v1, v2, Lbp/m1$a;->b:Ljava/lang/String;

    .line 57
    .line 58
    sget-object v3, Lbp/m1;->r:Ljava/util/LinkedList;

    .line 59
    .line 60
    monitor-enter v3

    .line 61
    :try_start_3c
    invoke-virtual {v3, v2}, Ljava/util/LinkedList;->add(Ljava/lang/Object;)Z

    .line 62
    .line 63
    .line 64
    monitor-exit v3

    .line 65
    goto :goto_8

    .line 66
    :catchall_41
    move-exception v0

    .line 67
    monitor-exit v3
    :try_end_43
    .catchall {:try_start_3c .. :try_end_43} :catchall_41

    .line 68
    throw v0

    .line 69
    :cond_44
    iget-object v2, v1, Ldx/b;->a:Ljava/lang/String;

    .line 70
    .line 71
    const-string v3, "response"

    .line 72
    .line 73
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 74
    .line 75
    .line 76
    move-result v2

    .line 77
    if-eqz v2, :cond_8

    .line 78
    .line 79
    iput-object v1, p0, Lbp/m1;->i:Ldx/b;

    .line 80
    .line 81
    const-string v2, "error-code"

    .line 82
    .line 83
    iget-object v1, v1, Ldx/b;->g:Ljava/util/HashMap;

    .line 84
    .line 85
    invoke-virtual {v1, v2}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    .line 86
    .line 87
    .line 88
    move-result v1

    .line 89
    if-eqz v1, :cond_6a

    .line 90
    .line 91
    iget-object v1, p0, Lbp/m1;->i:Ldx/b;

    .line 92
    .line 93
    const-string v2, "error-code"

    .line 94
    .line 95
    invoke-virtual {v1, v2}, Ldx/b;->d(Ljava/lang/String;)Ldx/b;

    .line 96
    .line 97
    .line 98
    move-result-object v1

    .line 99
    iget-object v1, v1, Ldx/b;->b:Ljava/lang/String;

    .line 100
    .line 101
    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 102
    .line 103
    .line 104
    move-result v1

    .line 105
    iput v1, p0, Lbp/m1;->j:I

    .line 106
    .line 107
    :cond_6a
    iget-object v1, p0, Lbp/m1;->i:Ldx/b;

    .line 108
    .line 109
    const-string v2, "error-message"

    .line 110
    .line 111
    iget-object v1, v1, Ldx/b;->g:Ljava/util/HashMap;

    .line 112
    .line 113
    invoke-virtual {v1, v2}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    .line 114
    .line 115
    .line 116
    move-result v1

    .line 117
    if-eqz v1, :cond_8

    .line 118
    .line 119
    iget-object v1, p0, Lbp/m1;->i:Ldx/b;

    .line 120
    .line 121
    const-string v2, "error-message"

    .line 122
    .line 123
    invoke-virtual {v1, v2}, Ldx/b;->d(Ljava/lang/String;)Ldx/b;

    .line 124
    .line 125
    .line 126
    move-result-object v1

    .line 127
    iget-object v1, v1, Ldx/b;->b:Ljava/lang/String;

    .line 128
    .line 129
    iput-object v1, p0, Lbp/m1;->k:Ljava/lang/String;

    .line 130
    .line 131
    goto :goto_8

    .line 132
    :cond_83
    return-void
.end method

.method public final l(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;)V
    .registers 4

    .line 1
    const/16 v0, 0x7530

    .line 2
    .line 3
    invoke-virtual {p0, p1, p2, v0, v0}, Lbp/m1;->m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V

    .line 4
    .line 5
    .line 6
    return-void
.end method

.method public final m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V
    .registers 26

    .line 1
    move-object/from16 v1, p0

    .line 2
    .line 3
    move-object/from16 v2, p1

    .line 4
    .line 5
    const-string v3, "wc"

    .line 6
    .line 7
    const-string v4, " (wc:"

    .line 8
    .line 9
    const-string v5, "@"

    .line 10
    .line 11
    const-string v6, "HttpRequestHelper"

    .line 12
    .line 13
    iget-object v7, v1, Lbp/m1;->a:Ljava/lang/String;

    .line 14
    .line 15
    const/4 v8, 0x1

    .line 16
    invoke-static {v8}, Landroid/net/TrafficStats;->setThreadStatsTag(I)V

    .line 17
    .line 18
    .line 19
    invoke-static {}, Llm/a0;->c()Z

    .line 20
    .line 21
    .line 22
    move-result v9

    .line 23
    if-eqz v9, :cond_4d4

    .line 24
    .line 25
    iget-boolean v9, v1, Lbp/m1;->c:Z

    .line 26
    .line 27
    if-eqz v9, :cond_2b

    .line 28
    .line 29
    if-eqz v2, :cond_2b

    .line 30
    .line 31
    iget-boolean v9, v2, Lcom/newspaperdirect/pressreader/android/core/Service;->s:Z

    .line 32
    .line 33
    if-eqz v9, :cond_23

    .line 34
    .line 35
    goto :goto_2b

    .line 36
    :cond_23
    new-instance v2, Ljava/lang/IllegalArgumentException;

    .line 37
    .line 38
    const-string v3, "Service is not valid"

    .line 39
    .line 40
    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    .line 41
    .line 42
    .line 43
    throw v2

    .line 44
    :cond_2b
    :goto_2b
    invoke-static/range {p2 .. p2}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 45
    .line 46
    .line 47
    move-result v9

    .line 48
    if-eqz v9, :cond_36

    .line 49
    .line 50
    invoke-static/range {p1 .. p1}, Lbp/m1;->g(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;

    .line 51
    .line 52
    .line 53
    move-result-object v9

    .line 54
    goto :goto_38

    .line 55
    :cond_36
    move-object/from16 v9, p2

    .line 56
    .line 57
    :goto_38
    new-instance v10, Ljava/net/URL;

    .line 58
    .line 59
    invoke-direct {v10, v9}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    .line 60
    .line 61
    .line 62
    const/4 v12, 0x0

    .line 63
    :try_start_3e
    invoke-virtual {v10}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    .line 64
    .line 65
    .line 66
    move-result-object v10

    .line 67
    invoke-static {v10}, Lcom/google/firebase/perf/network/FirebasePerfUrlConnection;->instrument(Ljava/lang/Object;)Ljava/lang/Object;

    .line 68
    .line 69
    .line 70
    move-result-object v10

    .line 71
    check-cast v10, Ljava/net/URLConnection;

    .line 72
    .line 73
    check-cast v10, Ljava/net/HttpURLConnection;
    :try_end_4a
    .catch Ljava/net/SocketTimeoutException; {:try_start_3e .. :try_end_4a} :catch_389
    .catch Ljavax/net/ssl/SSLException; {:try_start_3e .. :try_end_4a} :catch_387
    .catch Ljava/net/ConnectException; {:try_start_3e .. :try_end_4a} :catch_37e
    .catch Ljava/io/FileNotFoundException; {:try_start_3e .. :try_end_4a} :catch_377
    .catchall {:try_start_3e .. :try_end_4a} :catchall_372

    .line 74
    .line 75
    :try_start_4a
    invoke-virtual {v10, v12}, Ljava/net/URLConnection;->setUseCaches(Z)V

    .line 76
    .line 77
    .line 78
    invoke-virtual {v10, v8}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 79
    .line 80
    .line 81
    const-string v13, "POST"

    .line 82
    .line 83
    invoke-virtual {v10, v13}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 84
    .line 85
    .line 86
    const-string v13, "Content-Type"

    .line 87
    .line 88
    const-string v14, "text/xml; charset=\"utf-8\""

    .line 89
    .line 90
    invoke-virtual {v10, v13, v14}, Ljava/net/URLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 91
    .line 92
    .line 93
    invoke-virtual {v10, v8}, Ljava/net/URLConnection;->setDoOutput(Z)V

    .line 94
    .line 95
    .line 96
    move/from16 v13, p3

    .line 97
    .line 98
    invoke-virtual {v10, v13}, Ljava/net/URLConnection;->setConnectTimeout(I)V

    .line 99
    .line 100
    .line 101
    move/from16 v14, p4

    .line 102
    .line 103
    invoke-virtual {v10, v14}, Ljava/net/URLConnection;->setReadTimeout(I)V

    .line 104
    .line 105
    .line 106
    const-string v15, "User-Agent"

    .line 107
    .line 108
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 109
    .line 110
    .line 111
    move-result-object v11
    :try_end_6f
    .catch Ljava/net/SocketTimeoutException; {:try_start_4a .. :try_end_6f} :catch_317
    .catch Ljavax/net/ssl/SSLException; {:try_start_4a .. :try_end_6f} :catch_315
    .catch Ljava/net/ConnectException; {:try_start_4a .. :try_end_6f} :catch_30b
    .catch Ljava/io/FileNotFoundException; {:try_start_4a .. :try_end_6f} :catch_301
    .catchall {:try_start_4a .. :try_end_6f} :catchall_2fb

    .line 112
    :try_start_6f
    iget-object v11, v11, Ljq/t0;->A:Lvn/i;
    :try_end_71
    .catch Ljava/net/SocketTimeoutException; {:try_start_6f .. :try_end_71} :catch_370
    .catch Ljavax/net/ssl/SSLException; {:try_start_6f .. :try_end_71} :catch_36e
    .catch Ljava/net/ConnectException; {:try_start_6f .. :try_end_71} :catch_36c
    .catch Ljava/io/FileNotFoundException; {:try_start_6f .. :try_end_71} :catch_301
    .catchall {:try_start_6f .. :try_end_71} :catchall_2fb

    .line 113
    .line 114
    if-eqz v11, :cond_9d

    .line 115
    .line 116
    :try_start_73
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 117
    .line 118
    .line 119
    move-result-object v11

    .line 120
    iget-object v11, v11, Ljq/t0;->A:Lvn/i;

    .line 121
    .line 122
    iget-object v11, v11, Lvn/i;->n:Ljava/lang/String;
    :try_end_7b
    .catch Ljava/net/SocketTimeoutException; {:try_start_73 .. :try_end_7b} :catch_9b
    .catch Ljavax/net/ssl/SSLException; {:try_start_73 .. :try_end_7b} :catch_99
    .catch Ljava/net/ConnectException; {:try_start_73 .. :try_end_7b} :catch_97
    .catch Ljava/io/FileNotFoundException; {:try_start_73 .. :try_end_7b} :catch_95
    .catchall {:try_start_73 .. :try_end_7b} :catchall_93

    .line 123
    .line 124
    goto :goto_9f

    .line 125
    :goto_7c
    move-object v2, v1

    .line 126
    const/4 v11, 0x0

    .line 127
    :goto_7e
    move-object v1, v0

    .line 128
    goto/16 :goto_4c3

    .line 129
    .line 130
    :goto_81
    move-object v2, v1

    .line 131
    move-object/from16 v17, v4

    .line 132
    .line 133
    move-object v11, v10

    .line 134
    const/16 v16, 0x0

    .line 135
    .line 136
    :goto_87
    move-object v1, v0

    .line 137
    goto/16 :goto_38b

    .line 138
    .line 139
    :goto_8a
    move-object v3, v0

    .line 140
    const/4 v11, 0x0

    .line 141
    move-object/from16 v20, v2

    .line 142
    .line 143
    move-object v2, v1

    .line 144
    move-object/from16 v1, v20

    .line 145
    .line 146
    goto/16 :goto_3e0

    .line 147
    .line 148
    :catchall_93
    move-exception v0

    .line 149
    goto :goto_7c

    .line 150
    :catch_95
    move-exception v0

    .line 151
    goto :goto_81

    .line 152
    :catch_97
    move-exception v0

    .line 153
    goto :goto_8a

    .line 154
    :catch_99
    move-exception v0

    .line 155
    goto :goto_8a

    .line 156
    :catch_9b
    move-exception v0

    .line 157
    goto :goto_8a

    .line 158
    :cond_9d
    :try_start_9d
    const-string v11, ""

    .line 159
    .line 160
    :goto_9f
    invoke-virtual {v10, v15, v11}, Ljava/net/URLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 161
    .line 162
    .line 163
    invoke-virtual {v10}, Ljava/net/URLConnection;->getOutputStream()Ljava/io/OutputStream;

    .line 164
    .line 165
    .line 166
    move-result-object v11
    :try_end_a6
    .catch Ljava/net/SocketTimeoutException; {:try_start_9d .. :try_end_a6} :catch_317
    .catch Ljavax/net/ssl/SSLException; {:try_start_9d .. :try_end_a6} :catch_315
    .catch Ljava/net/ConnectException; {:try_start_9d .. :try_end_a6} :catch_30b
    .catch Ljava/io/FileNotFoundException; {:try_start_9d .. :try_end_a6} :catch_301
    .catchall {:try_start_9d .. :try_end_a6} :catchall_2fb

    .line 167
    :try_start_a6
    new-instance v15, Ljava/io/OutputStreamWriter;

    .line 168
    .line 169
    const-string v8, "UTF-8"

    .line 170
    .line 171
    invoke-direct {v15, v11, v8}, Ljava/io/OutputStreamWriter;-><init>(Ljava/io/OutputStream;Ljava/lang/String;)V
    :try_end_ad
    .catchall {:try_start_a6 .. :try_end_ad} :catchall_336

    .line 172
    .line 173
    .line 174
    :try_start_ad
    invoke-virtual/range {p0 .. p0}, Lbp/m1;->f()Ljava/lang/String;

    .line 175
    .line 176
    .line 177
    move-result-object v8

    .line 178
    invoke-virtual/range {p0 .. p1}, Lbp/m1;->e(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;

    .line 179
    .line 180
    .line 181
    move-result-object v12

    .line 182
    filled-new-array {v7, v12}, [Ljava/lang/Object;

    .line 183
    .line 184
    .line 185
    move-result-object v12

    .line 186
    invoke-static {v8, v12}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    .line 187
    .line 188
    .line 189
    move-result-object v8

    .line 190
    invoke-virtual {v15, v8}, Ljava/io/Writer;->write(Ljava/lang/String;)V
    :try_end_c0
    .catchall {:try_start_ad .. :try_end_c0} :catchall_340

    .line 191
    .line 192
    .line 193
    :try_start_c0
    invoke-virtual {v15}, Ljava/io/OutputStreamWriter;->close()V
    :try_end_c3
    .catchall {:try_start_c0 .. :try_end_c3} :catchall_336

    .line 194
    .line 195
    .line 196
    if-eqz v11, :cond_c8

    .line 197
    .line 198
    :try_start_c5
    invoke-virtual {v11}, Ljava/io/OutputStream;->close()V
    :try_end_c8
    .catch Ljava/net/SocketTimeoutException; {:try_start_c5 .. :try_end_c8} :catch_9b
    .catch Ljavax/net/ssl/SSLException; {:try_start_c5 .. :try_end_c8} :catch_99
    .catch Ljava/net/ConnectException; {:try_start_c5 .. :try_end_c8} :catch_97
    .catch Ljava/io/FileNotFoundException; {:try_start_c5 .. :try_end_c8} :catch_95
    .catchall {:try_start_c5 .. :try_end_c8} :catchall_93

    .line 199
    .line 200
    .line 201
    :cond_c8
    :try_start_c8
    sget-object v11, Lj70/a;->a:Lj70/a$a;

    .line 202
    .line 203
    invoke-virtual {v11, v6}, Lj70/a$a;->n(Ljava/lang/String;)V
    :try_end_cd
    .catch Ljava/net/SocketTimeoutException; {:try_start_c8 .. :try_end_cd} :catch_32f
    .catch Ljavax/net/ssl/SSLException; {:try_start_c8 .. :try_end_cd} :catch_328
    .catch Ljava/net/ConnectException; {:try_start_c8 .. :try_end_cd} :catch_321
    .catch Ljava/io/FileNotFoundException; {:try_start_c8 .. :try_end_cd} :catch_31c
    .catchall {:try_start_c8 .. :try_end_cd} :catchall_319

    .line 204
    .line 205
    .line 206
    :try_start_cd
    new-instance v12, Ljava/lang/StringBuilder;

    .line 207
    .line 208
    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    .line 209
    .line 210
    .line 211
    invoke-virtual {v12, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 212
    .line 213
    .line 214
    invoke-virtual {v12, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 215
    .line 216
    .line 217
    invoke-virtual {v12, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 218
    .line 219
    .line 220
    const-string v15, " [RQ]: "

    .line 221
    .line 222
    invoke-virtual {v12, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 223
    .line 224
    .line 225
    invoke-virtual {v12, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 226
    .line 227
    .line 228
    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 229
    .line 230
    .line 231
    move-result-object v8

    .line 232
    const/4 v12, 0x0

    .line 233
    new-array v15, v12, [Ljava/lang/Object;

    .line 234
    .line 235
    invoke-virtual {v11, v8, v15}, Lj70/a$a;->a(Ljava/lang/String;[Ljava/lang/Object;)V

    .line 236
    .line 237
    .line 238
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 239
    .line 240
    .line 241
    move-result-wide v11

    .line 242
    invoke-virtual {v10}, Ljava/net/URLConnection;->getInputStream()Ljava/io/InputStream;

    .line 243
    .line 244
    .line 245
    move-result-object v8
    :try_end_f5
    .catch Ljava/net/SocketTimeoutException; {:try_start_cd .. :try_end_f5} :catch_317
    .catch Ljavax/net/ssl/SSLException; {:try_start_cd .. :try_end_f5} :catch_315
    .catch Ljava/net/ConnectException; {:try_start_cd .. :try_end_f5} :catch_30b
    .catch Ljava/io/FileNotFoundException; {:try_start_cd .. :try_end_f5} :catch_301
    .catchall {:try_start_cd .. :try_end_f5} :catchall_2fb

    .line 246
    :try_start_f5
    const-string v15, "get-titles"

    .line 247
    .line 248
    invoke-virtual {v15, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 249
    .line 250
    .line 251
    move-result v15
    :try_end_fb
    .catch Ljava/net/SocketTimeoutException; {:try_start_f5 .. :try_end_fb} :catch_2f9
    .catch Ljavax/net/ssl/SSLException; {:try_start_f5 .. :try_end_fb} :catch_2f7
    .catch Ljava/net/ConnectException; {:try_start_f5 .. :try_end_fb} :catch_2ed
    .catch Ljava/io/FileNotFoundException; {:try_start_f5 .. :try_end_fb} :catch_2e0
    .catchall {:try_start_f5 .. :try_end_fb} :catchall_2dd

    .line 252
    iget-object v13, v1, Lbp/m1;->f:Landroid/sax/RootElement;

    .line 253
    .line 254
    iget-object v14, v1, Lbp/m1;->h:Ldx/b;

    .line 255
    .line 256
    iget-boolean v2, v1, Lbp/m1;->e:Z

    .line 257
    .line 258
    if-eqz v15, :cond_16f

    .line 259
    .line 260
    :try_start_103
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 261
    .line 262
    .line 263
    move-result-object v15

    .line 264
    invoke-virtual {v15}, Ljq/t0;->s()Lvn/j;

    .line 265
    .line 266
    .line 267
    move-result-object v15

    .line 268
    invoke-virtual {v15}, Lvn/j;->n()Z

    .line 269
    .line 270
    .line 271
    move-result v15
    :try_end_10f
    .catch Ljava/net/SocketTimeoutException; {:try_start_103 .. :try_end_10f} :catch_141
    .catch Ljavax/net/ssl/SSLException; {:try_start_103 .. :try_end_10f} :catch_13f
    .catch Ljava/net/ConnectException; {:try_start_103 .. :try_end_10f} :catch_137
    .catch Ljava/io/FileNotFoundException; {:try_start_103 .. :try_end_10f} :catch_12e
    .catchall {:try_start_103 .. :try_end_10f} :catchall_129

    .line 272
    if-nez v15, :cond_16f

    .line 273
    .line 274
    if-eqz v2, :cond_165

    .line 275
    .line 276
    :try_start_113
    invoke-virtual {v14}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 277
    .line 278
    .line 279
    new-instance v2, Ljava/io/InputStreamReader;

    .line 280
    .line 281
    invoke-direct {v2, v8}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V

    .line 282
    .line 283
    .line 284
    invoke-virtual {v14, v2}, Ldx/b;->f(Ljava/io/Reader;)Z
    :try_end_11e
    .catch Ljava/net/SocketTimeoutException; {:try_start_113 .. :try_end_11e} :catch_163
    .catch Ljavax/net/ssl/SSLException; {:try_start_113 .. :try_end_11e} :catch_161
    .catch Ljava/net/ConnectException; {:try_start_113 .. :try_end_11e} :catch_15b
    .catch Ljava/io/FileNotFoundException; {:try_start_113 .. :try_end_11e} :catch_14d
    .catchall {:try_start_113 .. :try_end_11e} :catchall_143

    .line 285
    .line 286
    .line 287
    :try_start_11e
    invoke-virtual/range {p0 .. p0}, Lbp/m1;->k()V

    .line 288
    .line 289
    .line 290
    :goto_121
    move-object/from16 v1, p1

    .line 291
    .line 292
    move-object/from16 v17, v4

    .line 293
    .line 294
    move-object/from16 v16, v8

    .line 295
    .line 296
    goto/16 :goto_20d

    .line 297
    .line 298
    :catchall_129
    move-exception v0

    .line 299
    move-object v2, v1

    .line 300
    move-object v11, v8

    .line 301
    goto/16 :goto_7e

    .line 302
    .line 303
    :catch_12e
    move-exception v0

    .line 304
    move-object v2, v1

    .line 305
    move-object/from16 v17, v4

    .line 306
    .line 307
    move-object/from16 v16, v8

    .line 308
    .line 309
    move-object v11, v10

    .line 310
    goto/16 :goto_87

    .line 311
    .line 312
    :catch_137
    move-exception v0

    .line 313
    :goto_138
    move-object v3, v0

    .line 314
    move-object v2, v1

    .line 315
    move-object v11, v8

    .line 316
    :goto_13b
    move-object/from16 v1, p1

    .line 317
    .line 318
    goto/16 :goto_3e0

    .line 319
    .line 320
    :catch_13f
    move-exception v0

    .line 321
    goto :goto_138

    .line 322
    :catch_141
    move-exception v0

    .line 323
    goto :goto_138

    .line 324
    :catchall_143
    move-exception v0

    .line 325
    move-object v2, v0

    .line 326
    move-object v11, v8

    .line 327
    move-object/from16 v20, v2

    .line 328
    .line 329
    move-object v2, v1

    .line 330
    move-object/from16 v1, v20

    .line 331
    .line 332
    goto/16 :goto_4c3

    .line 333
    .line 334
    :catch_14d
    move-exception v0

    .line 335
    move-object v2, v0

    .line 336
    move-object/from16 v17, v4

    .line 337
    .line 338
    move-object/from16 v16, v8

    .line 339
    .line 340
    move-object v11, v10

    .line 341
    move-object/from16 v20, v2

    .line 342
    .line 343
    move-object v2, v1

    .line 344
    move-object/from16 v1, v20

    .line 345
    .line 346
    goto/16 :goto_38b

    .line 347
    .line 348
    :catch_15b
    move-exception v0

    .line 349
    :goto_15c
    move-object v2, v0

    .line 350
    move-object v3, v2

    .line 351
    move-object v11, v8

    .line 352
    move-object v2, v1

    .line 353
    goto :goto_13b

    .line 354
    :catch_161
    move-exception v0

    .line 355
    goto :goto_15c

    .line 356
    :catch_163
    move-exception v0

    .line 357
    goto :goto_15c

    .line 358
    :cond_165
    sget-object v2, Landroid/util/Xml$Encoding;->UTF_8:Landroid/util/Xml$Encoding;

    .line 359
    .line 360
    invoke-virtual {v13}, Landroid/sax/RootElement;->getContentHandler()Lorg/xml/sax/ContentHandler;

    .line 361
    .line 362
    .line 363
    move-result-object v11

    .line 364
    invoke-static {v8, v2, v11}, Landroid/util/Xml;->parse(Ljava/io/InputStream;Landroid/util/Xml$Encoding;Lorg/xml/sax/ContentHandler;)V
    :try_end_16e
    .catch Ljava/net/SocketTimeoutException; {:try_start_11e .. :try_end_16e} :catch_141
    .catch Ljavax/net/ssl/SSLException; {:try_start_11e .. :try_end_16e} :catch_13f
    .catch Ljava/net/ConnectException; {:try_start_11e .. :try_end_16e} :catch_137
    .catch Ljava/io/FileNotFoundException; {:try_start_11e .. :try_end_16e} :catch_12e
    .catchall {:try_start_11e .. :try_end_16e} :catchall_129

    .line 365
    .line 366
    .line 367
    goto :goto_121

    .line 368
    :cond_16f
    :try_start_16f
    new-instance v15, Ljava/io/BufferedReader;
    :try_end_171
    .catch Ljava/net/SocketTimeoutException; {:try_start_16f .. :try_end_171} :catch_2eb
    .catch Ljavax/net/ssl/SSLException; {:try_start_16f .. :try_end_171} :catch_2e9
    .catch Ljava/net/ConnectException; {:try_start_16f .. :try_end_171} :catch_2e3
    .catch Ljava/io/FileNotFoundException; {:try_start_16f .. :try_end_171} :catch_2e0
    .catchall {:try_start_16f .. :try_end_171} :catchall_2dd

    .line 369
    .line 370
    :try_start_171
    new-instance v1, Ljava/io/InputStreamReader;

    .line 371
    .line 372
    invoke-direct {v1, v8}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V

    .line 373
    .line 374
    .line 375
    invoke-direct {v15, v1}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V
    :try_end_179
    .catch Ljava/net/SocketTimeoutException; {:try_start_171 .. :try_end_179} :catch_2db
    .catch Ljavax/net/ssl/SSLException; {:try_start_171 .. :try_end_179} :catch_2d9
    .catch Ljava/net/ConnectException; {:try_start_171 .. :try_end_179} :catch_2d0
    .catch Ljava/io/FileNotFoundException; {:try_start_171 .. :try_end_179} :catch_2c7
    .catchall {:try_start_171 .. :try_end_179} :catchall_2c0

    .line 376
    .line 377
    .line 378
    :try_start_179
    new-instance v1, Ljava/lang/StringBuilder;

    .line 379
    .line 380
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    :try_end_17e
    .catchall {:try_start_179 .. :try_end_17e} :catchall_2ab

    .line 381
    .line 382
    .line 383
    move-object/from16 v16, v8

    .line 384
    .line 385
    :goto_180
    :try_start_180
    invoke-virtual {v15}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    .line 386
    .line 387
    .line 388
    move-result-object v8

    .line 389
    if-eqz v8, :cond_194

    .line 390
    .line 391
    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 392
    .line 393
    .line 394
    goto :goto_180

    .line 395
    :catchall_18a
    move-exception v0

    .line 396
    move-object/from16 v2, p0

    .line 397
    .line 398
    move-object/from16 v1, p1

    .line 399
    .line 400
    move-object/from16 v17, v4

    .line 401
    .line 402
    :goto_191
    move-object v4, v0

    .line 403
    goto/16 :goto_2b6

    .line 404
    .line 405
    :cond_194
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 406
    .line 407
    .line 408
    move-result-object v1
    :try_end_198
    .catchall {:try_start_180 .. :try_end_198} :catchall_18a

    .line 409
    :try_start_198
    invoke-virtual {v15}, Ljava/io/BufferedReader;->close()V
    :try_end_19b
    .catch Ljava/net/SocketTimeoutException; {:try_start_198 .. :try_end_19b} :catch_202
    .catch Ljavax/net/ssl/SSLException; {:try_start_198 .. :try_end_19b} :catch_200
    .catch Ljava/net/ConnectException; {:try_start_198 .. :try_end_19b} :catch_1f6
    .catch Ljava/io/FileNotFoundException; {:try_start_198 .. :try_end_19b} :catch_283
    .catchall {:try_start_198 .. :try_end_19b} :catchall_1e7

    .line 410
    .line 411
    .line 412
    :try_start_19b
    sget-object v8, Lj70/a;->a:Lj70/a$a;

    .line 413
    .line 414
    invoke-virtual {v8, v6}, Lj70/a$a;->n(Ljava/lang/String;)V
    :try_end_1a0
    .catch Ljava/net/SocketTimeoutException; {:try_start_19b .. :try_end_1a0} :catch_2a4
    .catch Ljavax/net/ssl/SSLException; {:try_start_19b .. :try_end_1a0} :catch_29d
    .catch Ljava/net/ConnectException; {:try_start_19b .. :try_end_1a0} :catch_296
    .catch Ljava/io/FileNotFoundException; {:try_start_19b .. :try_end_1a0} :catch_28f
    .catchall {:try_start_19b .. :try_end_1a0} :catchall_28a

    .line 415
    .line 416
    .line 417
    :try_start_1a0
    new-instance v15, Ljava/lang/StringBuilder;

    .line 418
    .line 419
    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    .line 420
    .line 421
    .line 422
    invoke-virtual {v15, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 423
    .line 424
    .line 425
    invoke-virtual {v15, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 426
    .line 427
    .line 428
    invoke-virtual {v15, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 429
    .line 430
    .line 431
    invoke-virtual {v15, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :try_end_1b1
    .catch Ljava/net/SocketTimeoutException; {:try_start_1a0 .. :try_end_1b1} :catch_202
    .catch Ljavax/net/ssl/SSLException; {:try_start_1a0 .. :try_end_1b1} :catch_200
    .catch Ljava/net/ConnectException; {:try_start_1a0 .. :try_end_1b1} :catch_1f6
    .catch Ljava/io/FileNotFoundException; {:try_start_1a0 .. :try_end_1b1} :catch_283
    .catchall {:try_start_1a0 .. :try_end_1b1} :catchall_1e7

    .line 432
    .line 433
    .line 434
    move-object/from16 v17, v4

    .line 435
    .line 436
    :try_start_1b3
    invoke-virtual {v10}, Ljava/net/URLConnection;->getHeaderFields()Ljava/util/Map;

    .line 437
    .line 438
    .line 439
    move-result-object v4

    .line 440
    invoke-interface {v4, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 441
    .line 442
    .line 443
    move-result-object v4

    .line 444
    invoke-virtual {v15, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 445
    .line 446
    .line 447
    const-string v4, "), "

    .line 448
    .line 449
    invoke-virtual {v15, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 450
    .line 451
    .line 452
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 453
    .line 454
    .line 455
    move-result-wide v18

    .line 456
    sub-long v11, v18, v11

    .line 457
    .line 458
    invoke-virtual {v15, v11, v12}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    .line 459
    .line 460
    .line 461
    const-string v4, "ms, [RS]: "

    .line 462
    .line 463
    invoke-virtual {v15, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 464
    .line 465
    .line 466
    invoke-virtual {v15, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 467
    .line 468
    .line 469
    invoke-virtual {v15}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 470
    .line 471
    .line 472
    move-result-object v4

    .line 473
    const/4 v11, 0x0

    .line 474
    new-array v12, v11, [Ljava/lang/Object;

    .line 475
    .line 476
    invoke-virtual {v8, v4, v12}, Lj70/a$a;->f(Ljava/lang/String;[Ljava/lang/Object;)V

    .line 477
    .line 478
    .line 479
    if-eqz v2, :cond_204

    .line 480
    .line 481
    invoke-virtual {v14, v1}, Ldx/b;->e(Ljava/lang/String;)V

    .line 482
    .line 483
    .line 484
    invoke-virtual/range {p0 .. p0}, Lbp/m1;->k()V

    .line 485
    .line 486
    .line 487
    goto :goto_20b

    .line 488
    :catchall_1e7
    move-exception v0

    .line 489
    move-object/from16 v2, p0

    .line 490
    .line 491
    :goto_1ea
    move-object v1, v0

    .line 492
    :goto_1eb
    move-object/from16 v11, v16

    .line 493
    .line 494
    goto/16 :goto_4c3

    .line 495
    .line 496
    :catch_1ef
    move-exception v0

    .line 497
    move-object/from16 v2, p0

    .line 498
    .line 499
    :goto_1f2
    move-object v1, v0

    .line 500
    move-object v11, v10

    .line 501
    goto/16 :goto_38b

    .line 502
    .line 503
    :catch_1f6
    move-exception v0

    .line 504
    :goto_1f7
    move-object/from16 v2, p0

    .line 505
    .line 506
    :goto_1f9
    move-object/from16 v1, p1

    .line 507
    .line 508
    :goto_1fb
    move-object v3, v0

    .line 509
    move-object/from16 v11, v16

    .line 510
    .line 511
    goto/16 :goto_3e0

    .line 512
    .line 513
    :catch_200
    move-exception v0

    .line 514
    goto :goto_1f7

    .line 515
    :catch_202
    move-exception v0

    .line 516
    goto :goto_1f7

    .line 517
    :cond_204
    invoke-virtual {v13}, Landroid/sax/RootElement;->getContentHandler()Lorg/xml/sax/ContentHandler;

    .line 518
    .line 519
    .line 520
    move-result-object v2

    .line 521
    invoke-static {v1, v2}, Landroid/util/Xml;->parse(Ljava/lang/String;Lorg/xml/sax/ContentHandler;)V
    :try_end_20b
    .catch Ljava/net/SocketTimeoutException; {:try_start_1b3 .. :try_end_20b} :catch_202
    .catch Ljavax/net/ssl/SSLException; {:try_start_1b3 .. :try_end_20b} :catch_200
    .catch Ljava/net/ConnectException; {:try_start_1b3 .. :try_end_20b} :catch_1f6
    .catch Ljava/io/FileNotFoundException; {:try_start_1b3 .. :try_end_20b} :catch_1ef
    .catchall {:try_start_1b3 .. :try_end_20b} :catchall_1e7

    .line 522
    .line 523
    .line 524
    :goto_20b
    move-object/from16 v1, p1

    .line 525
    .line 526
    :goto_20d
    if-eqz v1, :cond_271

    .line 527
    .line 528
    :try_start_20f
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 529
    .line 530
    .line 531
    move-result-wide v11

    .line 532
    iput-wide v11, v1, Lcom/newspaperdirect/pressreader/android/core/Service;->o:J
    :try_end_215
    .catch Ljava/net/SocketTimeoutException; {:try_start_20f .. :try_end_215} :catch_26d
    .catch Ljavax/net/ssl/SSLException; {:try_start_20f .. :try_end_215} :catch_269
    .catch Ljava/net/ConnectException; {:try_start_20f .. :try_end_215} :catch_265
    .catch Ljava/io/FileNotFoundException; {:try_start_20f .. :try_end_215} :catch_261
    .catchall {:try_start_20f .. :try_end_215} :catchall_25d

    .line 533
    .line 534
    move-object/from16 v2, p0

    .line 535
    .line 536
    :try_start_217
    iget v4, v2, Lbp/m1;->j:I

    .line 537
    .line 538
    if-nez v4, :cond_259

    .line 539
    .line 540
    iget-boolean v4, v1, Lcom/newspaperdirect/pressreader/android/core/Service;->s:Z

    .line 541
    .line 542
    if-nez v4, :cond_259

    .line 543
    .line 544
    iget-boolean v4, v2, Lbp/m1;->c:Z

    .line 545
    .line 546
    if-eqz v4, :cond_259

    .line 547
    .line 548
    const/4 v4, 0x1

    .line 549
    iput-boolean v4, v1, Lcom/newspaperdirect/pressreader/android/core/Service;->s:Z

    .line 550
    .line 551
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 552
    .line 553
    .line 554
    move-result-object v4

    .line 555
    invoke-virtual {v4}, Ljq/t0;->p()Llm/l1;

    .line 556
    .line 557
    .line 558
    move-result-object v4
    :try_end_22e
    .catch Ljava/net/SocketTimeoutException; {:try_start_217 .. :try_end_22e} :catch_257
    .catch Ljavax/net/ssl/SSLException; {:try_start_217 .. :try_end_22e} :catch_255
    .catch Ljava/net/ConnectException; {:try_start_217 .. :try_end_22e} :catch_253
    .catch Ljava/io/FileNotFoundException; {:try_start_217 .. :try_end_22e} :catch_251
    .catchall {:try_start_217 .. :try_end_22e} :catchall_24f

    .line 559
    const-wide/16 v11, 0x0

    .line 560
    .line 561
    :try_start_230
    iput-wide v11, v4, Llm/l1;->h:J

    .line 562
    .line 563
    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    .line 564
    .line 565
    .line 566
    move-result-object v8

    .line 567
    if-nez v8, :cond_239

    .line 568
    .line 569
    goto :goto_273

    .line 570
    :cond_239
    new-instance v8, Llm/m1;

    .line 571
    .line 572
    const/4 v11, 0x1

    .line 573
    invoke-direct {v8, v4, v11}, Llm/m1;-><init>(Llm/l1;Z)V

    .line 574
    .line 575
    .line 576
    iget-object v4, v4, Llm/l1;->c:Llm/q1;

    .line 577
    .line 578
    invoke-virtual {v4, v8}, Llm/q1;->a(Llm/q1$b;)V
    :try_end_244
    .catch Ljava/net/SocketTimeoutException; {:try_start_230 .. :try_end_244} :catch_24d
    .catch Ljavax/net/ssl/SSLException; {:try_start_230 .. :try_end_244} :catch_24b
    .catch Ljava/net/ConnectException; {:try_start_230 .. :try_end_244} :catch_249
    .catch Ljava/io/FileNotFoundException; {:try_start_230 .. :try_end_244} :catch_247
    .catchall {:try_start_230 .. :try_end_244} :catchall_245

    .line 579
    .line 580
    .line 581
    goto :goto_273

    .line 582
    :catchall_245
    move-exception v0

    .line 583
    goto :goto_1ea

    .line 584
    :catch_247
    move-exception v0

    .line 585
    goto :goto_1f2

    .line 586
    :catch_249
    move-exception v0

    .line 587
    goto :goto_1fb

    .line 588
    :catch_24b
    move-exception v0

    .line 589
    goto :goto_1fb

    .line 590
    :catch_24d
    move-exception v0

    .line 591
    goto :goto_1fb

    .line 592
    :catchall_24f
    move-exception v0

    .line 593
    goto :goto_1ea

    .line 594
    :catch_251
    move-exception v0

    .line 595
    goto :goto_1f2

    .line 596
    :catch_253
    move-exception v0

    .line 597
    goto :goto_1fb

    .line 598
    :catch_255
    move-exception v0

    .line 599
    goto :goto_1fb

    .line 600
    :catch_257
    move-exception v0

    .line 601
    goto :goto_1fb

    .line 602
    :cond_259
    const/4 v4, 0x1

    .line 603
    :try_start_25a
    iput-boolean v4, v1, Lcom/newspaperdirect/pressreader/android/core/Service;->s:Z
    :try_end_25c
    .catch Ljava/net/SocketTimeoutException; {:try_start_25a .. :try_end_25c} :catch_257
    .catch Ljavax/net/ssl/SSLException; {:try_start_25a .. :try_end_25c} :catch_255
    .catch Ljava/net/ConnectException; {:try_start_25a .. :try_end_25c} :catch_253
    .catch Ljava/io/FileNotFoundException; {:try_start_25a .. :try_end_25c} :catch_251
    .catchall {:try_start_25a .. :try_end_25c} :catchall_24f

    .line 604
    .line 605
    goto :goto_273

    .line 606
    :catchall_25d
    move-exception v0

    .line 607
    move-object/from16 v2, p0

    .line 608
    .line 609
    goto :goto_1ea

    .line 610
    :catch_261
    move-exception v0

    .line 611
    move-object/from16 v2, p0

    .line 612
    .line 613
    goto :goto_1f2

    .line 614
    :catch_265
    move-exception v0

    .line 615
    move-object/from16 v2, p0

    .line 616
    .line 617
    goto :goto_1fb

    .line 618
    :catch_269
    move-exception v0

    .line 619
    move-object/from16 v2, p0

    .line 620
    .line 621
    goto :goto_1fb

    .line 622
    :catch_26d
    move-exception v0

    .line 623
    move-object/from16 v2, p0

    .line 624
    .line 625
    goto :goto_1fb

    .line 626
    :cond_271
    move-object/from16 v2, p0

    .line 627
    .line 628
    :goto_273
    if-eqz v16, :cond_27e

    .line 629
    .line 630
    :try_start_275
    invoke-virtual/range {v16 .. v16}, Ljava/io/InputStream;->close()V
    :try_end_278
    .catch Ljava/io/IOException; {:try_start_275 .. :try_end_278} :catch_279

    .line 631
    .line 632
    .line 633
    goto :goto_27e

    .line 634
    :catch_279
    move-exception v0

    .line 635
    move-object v3, v0

    .line 636
    invoke-static {v3}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 637
    .line 638
    .line 639
    :cond_27e
    :goto_27e
    invoke-virtual {v10}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 640
    .line 641
    .line 642
    goto/16 :goto_439

    .line 643
    .line 644
    :catch_283
    move-exception v0

    .line 645
    move-object/from16 v2, p0

    .line 646
    .line 647
    move-object/from16 v17, v4

    .line 648
    .line 649
    goto/16 :goto_1f2

    .line 650
    .line 651
    :catchall_28a
    move-exception v0

    .line 652
    move-object/from16 v2, p0

    .line 653
    .line 654
    goto/16 :goto_1ea

    .line 655
    .line 656
    :catch_28f
    move-exception v0

    .line 657
    move-object/from16 v2, p0

    .line 658
    .line 659
    move-object/from16 v17, v4

    .line 660
    .line 661
    goto/16 :goto_1f2

    .line 662
    .line 663
    :catch_296
    move-exception v0

    .line 664
    move-object/from16 v2, p0

    .line 665
    .line 666
    move-object/from16 v1, p1

    .line 667
    .line 668
    goto/16 :goto_1fb

    .line 669
    .line 670
    :catch_29d
    move-exception v0

    .line 671
    move-object/from16 v2, p0

    .line 672
    .line 673
    move-object/from16 v1, p1

    .line 674
    .line 675
    goto/16 :goto_1fb

    .line 676
    .line 677
    :catch_2a4
    move-exception v0

    .line 678
    move-object/from16 v2, p0

    .line 679
    .line 680
    move-object/from16 v1, p1

    .line 681
    .line 682
    goto/16 :goto_1fb

    .line 683
    .line 684
    :catchall_2ab
    move-exception v0

    .line 685
    move-object/from16 v2, p0

    .line 686
    .line 687
    move-object/from16 v1, p1

    .line 688
    .line 689
    move-object/from16 v17, v4

    .line 690
    .line 691
    move-object/from16 v16, v8

    .line 692
    .line 693
    goto/16 :goto_191

    .line 694
    .line 695
    :goto_2b6
    :try_start_2b6
    invoke-virtual {v15}, Ljava/io/BufferedReader;->close()V
    :try_end_2b9
    .catchall {:try_start_2b6 .. :try_end_2b9} :catchall_2ba

    .line 696
    .line 697
    .line 698
    goto :goto_2bf

    .line 699
    :catchall_2ba
    move-exception v0

    .line 700
    move-object v8, v0

    .line 701
    :try_start_2bc
    invoke-virtual {v4, v8}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .line 702
    .line 703
    .line 704
    :goto_2bf
    throw v4
    :try_end_2c0
    .catch Ljava/net/SocketTimeoutException; {:try_start_2bc .. :try_end_2c0} :catch_257
    .catch Ljavax/net/ssl/SSLException; {:try_start_2bc .. :try_end_2c0} :catch_255
    .catch Ljava/net/ConnectException; {:try_start_2bc .. :try_end_2c0} :catch_253
    .catch Ljava/io/FileNotFoundException; {:try_start_2bc .. :try_end_2c0} :catch_251
    .catchall {:try_start_2bc .. :try_end_2c0} :catchall_24f

    .line 705
    :catchall_2c0
    move-exception v0

    .line 706
    move-object/from16 v2, p0

    .line 707
    .line 708
    :goto_2c3
    move-object/from16 v16, v8

    .line 709
    .line 710
    goto/16 :goto_1ea

    .line 711
    .line 712
    :catch_2c7
    move-exception v0

    .line 713
    move-object/from16 v2, p0

    .line 714
    .line 715
    :goto_2ca
    move-object/from16 v17, v4

    .line 716
    .line 717
    move-object/from16 v16, v8

    .line 718
    .line 719
    goto/16 :goto_1f2

    .line 720
    .line 721
    :catch_2d0
    move-exception v0

    .line 722
    :goto_2d1
    move-object/from16 v2, p0

    .line 723
    .line 724
    move-object/from16 v1, p1

    .line 725
    .line 726
    move-object/from16 v16, v8

    .line 727
    .line 728
    goto/16 :goto_1fb

    .line 729
    .line 730
    :catch_2d9
    move-exception v0

    .line 731
    goto :goto_2d1

    .line 732
    :catch_2db
    move-exception v0

    .line 733
    goto :goto_2d1

    .line 734
    :catchall_2dd
    move-exception v0

    .line 735
    move-object v2, v1

    .line 736
    goto :goto_2c3

    .line 737
    :catch_2e0
    move-exception v0

    .line 738
    move-object v2, v1

    .line 739
    goto :goto_2ca

    .line 740
    :catch_2e3
    move-exception v0

    .line 741
    :goto_2e4
    move-object v2, v1

    .line 742
    move-object/from16 v16, v8

    .line 743
    .line 744
    goto/16 :goto_1f9

    .line 745
    .line 746
    :catch_2e9
    move-exception v0

    .line 747
    goto :goto_2e4

    .line 748
    :catch_2eb
    move-exception v0

    .line 749
    goto :goto_2e4

    .line 750
    :catch_2ed
    move-exception v0

    .line 751
    :goto_2ee
    move-object/from16 v16, v8

    .line 752
    .line 753
    move-object/from16 v20, v2

    .line 754
    .line 755
    move-object v2, v1

    .line 756
    move-object/from16 v1, v20

    .line 757
    .line 758
    goto/16 :goto_1fb

    .line 759
    .line 760
    :catch_2f7
    move-exception v0

    .line 761
    goto :goto_2ee

    .line 762
    :catch_2f9
    move-exception v0

    .line 763
    goto :goto_2ee

    .line 764
    :catchall_2fb
    move-exception v0

    .line 765
    move-object v2, v1

    .line 766
    :goto_2fd
    move-object v1, v0

    .line 767
    :goto_2fe
    const/4 v11, 0x0

    .line 768
    goto/16 :goto_4c3

    .line 769
    .line 770
    :catch_301
    move-exception v0

    .line 771
    move-object v2, v1

    .line 772
    move-object/from16 v17, v4

    .line 773
    .line 774
    :goto_305
    move-object v1, v0

    .line 775
    move-object v11, v10

    .line 776
    :goto_307
    const/16 v16, 0x0

    .line 777
    .line 778
    goto/16 :goto_38b

    .line 779
    .line 780
    :catch_30b
    move-exception v0

    .line 781
    :goto_30c
    move-object/from16 v20, v2

    .line 782
    .line 783
    move-object v2, v1

    .line 784
    move-object/from16 v1, v20

    .line 785
    .line 786
    :goto_311
    move-object v3, v0

    .line 787
    :goto_312
    const/4 v11, 0x0

    .line 788
    goto/16 :goto_3e0

    .line 789
    .line 790
    :catch_315
    move-exception v0

    .line 791
    goto :goto_30c

    .line 792
    :catch_317
    move-exception v0

    .line 793
    goto :goto_30c

    .line 794
    :catchall_319
    move-exception v0

    .line 795
    move-object v2, v1

    .line 796
    goto :goto_2fd

    .line 797
    :catch_31c
    move-exception v0

    .line 798
    move-object v2, v1

    .line 799
    move-object/from16 v17, v4

    .line 800
    .line 801
    goto :goto_305

    .line 802
    :catch_321
    move-exception v0

    .line 803
    move-object/from16 v20, v2

    .line 804
    .line 805
    move-object v2, v1

    .line 806
    move-object/from16 v1, v20

    .line 807
    .line 808
    goto :goto_311

    .line 809
    :catch_328
    move-exception v0

    .line 810
    move-object/from16 v20, v2

    .line 811
    .line 812
    move-object v2, v1

    .line 813
    move-object/from16 v1, v20

    .line 814
    .line 815
    goto :goto_311

    .line 816
    :catch_32f
    move-exception v0

    .line 817
    move-object/from16 v20, v2

    .line 818
    .line 819
    move-object v2, v1

    .line 820
    move-object/from16 v1, v20

    .line 821
    .line 822
    goto :goto_311

    .line 823
    :catchall_336
    move-exception v0

    .line 824
    move-object/from16 v17, v4

    .line 825
    .line 826
    move-object/from16 v20, v2

    .line 827
    .line 828
    move-object v2, v1

    .line 829
    move-object/from16 v1, v20

    .line 830
    .line 831
    :goto_33e
    move-object v4, v0

    .line 832
    goto :goto_355

    .line 833
    :catchall_340
    move-exception v0

    .line 834
    move-object/from16 v17, v4

    .line 835
    .line 836
    move-object/from16 v20, v2

    .line 837
    .line 838
    move-object v2, v1

    .line 839
    move-object/from16 v1, v20

    .line 840
    .line 841
    move-object v4, v0

    .line 842
    :try_start_349
    invoke-virtual {v15}, Ljava/io/OutputStreamWriter;->close()V
    :try_end_34c
    .catchall {:try_start_349 .. :try_end_34c} :catchall_34d

    .line 843
    .line 844
    .line 845
    goto :goto_352

    .line 846
    :catchall_34d
    move-exception v0

    .line 847
    move-object v8, v0

    .line 848
    :try_start_34f
    invoke-virtual {v4, v8}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .line 849
    .line 850
    .line 851
    :goto_352
    throw v4
    :try_end_353
    .catchall {:try_start_34f .. :try_end_353} :catchall_353

    .line 852
    :catchall_353
    move-exception v0

    .line 853
    goto :goto_33e

    .line 854
    :goto_355
    if-eqz v11, :cond_36b

    .line 855
    .line 856
    :try_start_357
    invoke-virtual {v11}, Ljava/io/OutputStream;->close()V
    :try_end_35a
    .catchall {:try_start_357 .. :try_end_35a} :catchall_35b

    .line 857
    .line 858
    .line 859
    goto :goto_36b

    .line 860
    :catchall_35b
    move-exception v0

    .line 861
    move-object v8, v0

    .line 862
    :try_start_35d
    invoke-virtual {v4, v8}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .line 863
    .line 864
    .line 865
    goto :goto_36b

    .line 866
    :catchall_361
    move-exception v0

    .line 867
    goto :goto_2fd

    .line 868
    :catch_363
    move-exception v0

    .line 869
    goto :goto_305

    .line 870
    :catch_365
    move-exception v0

    .line 871
    goto :goto_311

    .line 872
    :catch_367
    move-exception v0

    .line 873
    goto :goto_311

    .line 874
    :catch_369
    move-exception v0

    .line 875
    goto :goto_311

    .line 876
    :cond_36b
    :goto_36b
    throw v4
    :try_end_36c
    .catch Ljava/net/SocketTimeoutException; {:try_start_35d .. :try_end_36c} :catch_369
    .catch Ljavax/net/ssl/SSLException; {:try_start_35d .. :try_end_36c} :catch_367
    .catch Ljava/net/ConnectException; {:try_start_35d .. :try_end_36c} :catch_365
    .catch Ljava/io/FileNotFoundException; {:try_start_35d .. :try_end_36c} :catch_363
    .catchall {:try_start_35d .. :try_end_36c} :catchall_361

    .line 877
    :catch_36c
    move-exception v0

    .line 878
    goto :goto_30c

    .line 879
    :catch_36e
    move-exception v0

    .line 880
    goto :goto_30c

    .line 881
    :catch_370
    move-exception v0

    .line 882
    goto :goto_30c

    .line 883
    :catchall_372
    move-exception v0

    .line 884
    move-object v2, v1

    .line 885
    move-object v1, v0

    .line 886
    const/4 v10, 0x0

    .line 887
    goto :goto_2fe

    .line 888
    :catch_377
    move-exception v0

    .line 889
    move-object v2, v1

    .line 890
    move-object/from16 v17, v4

    .line 891
    .line 892
    move-object v1, v0

    .line 893
    const/4 v11, 0x0

    .line 894
    goto :goto_307

    .line 895
    :catch_37e
    move-exception v0

    .line 896
    :goto_37f
    move-object/from16 v20, v2

    .line 897
    .line 898
    move-object v2, v1

    .line 899
    move-object/from16 v1, v20

    .line 900
    .line 901
    move-object v3, v0

    .line 902
    const/4 v10, 0x0

    .line 903
    goto :goto_312

    .line 904
    :catch_387
    move-exception v0

    .line 905
    goto :goto_37f

    .line 906
    :catch_389
    move-exception v0

    .line 907
    goto :goto_37f

    .line 908
    :goto_38b
    :try_start_38b
    sget-object v4, Lj70/a;->a:Lj70/a$a;

    .line 909
    .line 910
    invoke-virtual {v4, v6}, Lj70/a$a;->n(Ljava/lang/String;)V
    :try_end_390
    .catchall {:try_start_38b .. :try_end_390} :catchall_3de

    .line 911
    .line 912
    .line 913
    :try_start_390
    new-instance v6, Ljava/lang/StringBuilder;

    .line 914
    .line 915
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    .line 916
    .line 917
    .line 918
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 919
    .line 920
    .line 921
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 922
    .line 923
    .line 924
    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 925
    .line 926
    .line 927
    move-object/from16 v5, v17

    .line 928
    .line 929
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 930
    .line 931
    .line 932
    invoke-virtual {v11}, Ljava/net/URLConnection;->getHeaderFields()Ljava/util/Map;

    .line 933
    .line 934
    .line 935
    move-result-object v5

    .line 936
    invoke-interface {v5, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 937
    .line 938
    .line 939
    move-result-object v3

    .line 940
    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 941
    .line 942
    .line 943
    const-string v3, "), [RS]: "

    .line 944
    .line 945
    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 946
    .line 947
    .line 948
    invoke-virtual {v11}, Ljava/net/HttpURLConnection;->getResponseCode()I

    .line 949
    .line 950
    .line 951
    move-result v3

    .line 952
    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 953
    .line 954
    .line 955
    const-string v3, "\n"

    .line 956
    .line 957
    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 958
    .line 959
    .line 960
    invoke-virtual {v11}, Ljava/net/HttpURLConnection;->getErrorStream()Ljava/io/InputStream;

    .line 961
    .line 962
    .line 963
    move-result-object v3

    .line 964
    invoke-static {v3}, Lvw/c;->i(Ljava/io/InputStream;)Ljava/lang/StringBuilder;

    .line 965
    .line 966
    .line 967
    move-result-object v3

    .line 968
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 969
    .line 970
    .line 971
    move-result-object v3

    .line 972
    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 973
    .line 974
    .line 975
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 976
    .line 977
    .line 978
    move-result-object v3

    .line 979
    const/4 v5, 0x0

    .line 980
    new-array v5, v5, [Ljava/lang/Object;

    .line 981
    .line 982
    invoke-virtual {v4, v3, v5}, Lj70/a$a;->c(Ljava/lang/String;[Ljava/lang/Object;)V

    .line 983
    .line 984
    .line 985
    throw v1
    :try_end_3d9
    .catchall {:try_start_390 .. :try_end_3d9} :catchall_3d9

    .line 986
    :catchall_3d9
    move-exception v0

    .line 987
    :goto_3da
    move-object v1, v0

    .line 988
    move-object v10, v11

    .line 989
    goto/16 :goto_1eb

    .line 990
    .line 991
    :catchall_3de
    move-exception v0

    .line 992
    goto :goto_3da

    .line 993
    :goto_3e0
    :try_start_3e0
    invoke-static {v3}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 994
    .line 995
    .line 996
    invoke-static/range {p2 .. p2}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 997
    .line 998
    .line 999
    move-result v4

    .line 1000
    if-eqz v4, :cond_4c2

    .line 1001
    .line 1002
    invoke-static {}, Lbp/m1;->n()Z

    .line 1003
    .line 1004
    .line 1005
    move-result v4

    .line 1006
    if-eqz v4, :cond_4c2

    .line 1007
    .line 1008
    sget-object v4, Lj70/a;->a:Lj70/a$a;

    .line 1009
    .line 1010
    invoke-virtual {v4, v6}, Lj70/a$a;->n(Ljava/lang/String;)V

    .line 1011
    .line 1012
    .line 1013
    new-instance v5, Ljava/lang/StringBuilder;

    .line 1014
    .line 1015
    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    .line 1016
    .line 1017
    .line 1018
    const-string v8, "Switching server to "

    .line 1019
    .line 1020
    invoke-virtual {v5, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1021
    .line 1022
    .line 1023
    sget-object v8, Lbp/m1;->n:Llr/b;

    .line 1024
    .line 1025
    sget-object v9, Lbp/m1;->o:Ljava/util/HashMap;

    .line 1026
    .line 1027
    sget-object v12, Lbp/m1;->p:Ljava/lang/String;

    .line 1028
    .line 1029
    invoke-virtual {v9, v12}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    .line 1030
    .line 1031
    .line 1032
    move-result-object v9

    .line 1033
    check-cast v9, Ljava/lang/String;

    .line 1034
    .line 1035
    invoke-interface {v8, v9}, Llr/b;->a(Ljava/lang/String;)Ljava/lang/String;

    .line 1036
    .line 1037
    .line 1038
    move-result-object v8

    .line 1039
    invoke-virtual {v5, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1040
    .line 1041
    .line 1042
    const-string v8, ", Reason: "

    .line 1043
    .line 1044
    invoke-virtual {v5, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1045
    .line 1046
    .line 1047
    invoke-virtual {v3}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    .line 1048
    .line 1049
    .line 1050
    move-result-object v3

    .line 1051
    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1052
    .line 1053
    .line 1054
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 1055
    .line 1056
    .line 1057
    move-result-object v3

    .line 1058
    const/4 v5, 0x0

    .line 1059
    new-array v8, v5, [Ljava/lang/Object;

    .line 1060
    .line 1061
    invoke-virtual {v4, v3, v8}, Lj70/a$a;->j(Ljava/lang/String;[Ljava/lang/Object;)V

    .line 1062
    .line 1063
    .line 1064
    invoke-virtual/range {p0 .. p4}, Lbp/m1;->m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V
    :try_end_42a
    .catchall {:try_start_3e0 .. :try_end_42a} :catchall_4bf

    .line 1065
    .line 1066
    .line 1067
    if-eqz v11, :cond_435

    .line 1068
    .line 1069
    :try_start_42c
    invoke-virtual {v11}, Ljava/io/InputStream;->close()V
    :try_end_42f
    .catch Ljava/io/IOException; {:try_start_42c .. :try_end_42f} :catch_430

    .line 1070
    .line 1071
    .line 1072
    goto :goto_435

    .line 1073
    :catch_430
    move-exception v0

    .line 1074
    move-object v3, v0

    .line 1075
    invoke-static {v3}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 1076
    .line 1077
    .line 1078
    :cond_435
    :goto_435
    if-eqz v10, :cond_439

    .line 1079
    .line 1080
    goto/16 :goto_27e

    .line 1081
    .line 1082
    :cond_439
    :goto_439
    iget v3, v2, Lbp/m1;->j:I

    .line 1083
    .line 1084
    if-eqz v3, :cond_4bb

    .line 1085
    .line 1086
    sget-object v3, Lj70/a;->a:Lj70/a$a;

    .line 1087
    .line 1088
    invoke-virtual {v3, v6}, Lj70/a$a;->n(Ljava/lang/String;)V

    .line 1089
    .line 1090
    .line 1091
    new-instance v4, Ljava/lang/StringBuilder;

    .line 1092
    .line 1093
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    .line 1094
    .line 1095
    .line 1096
    iget-object v5, v2, Lbp/m1;->k:Ljava/lang/String;

    .line 1097
    .line 1098
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1099
    .line 1100
    .line 1101
    const-string v5, " ("

    .line 1102
    .line 1103
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1104
    .line 1105
    .line 1106
    iget v5, v2, Lbp/m1;->j:I

    .line 1107
    .line 1108
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 1109
    .line 1110
    .line 1111
    const-string v5, ") on "

    .line 1112
    .line 1113
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1114
    .line 1115
    .line 1116
    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1117
    .line 1118
    .line 1119
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 1120
    .line 1121
    .line 1122
    move-result-object v4

    .line 1123
    const/4 v5, 0x0

    .line 1124
    new-array v5, v5, [Ljava/lang/Object;

    .line 1125
    .line 1126
    invoke-virtual {v3, v4, v5}, Lj70/a$a;->c(Ljava/lang/String;[Ljava/lang/Object;)V

    .line 1127
    .line 1128
    .line 1129
    const/16 v3, 0xcc

    .line 1130
    .line 1131
    if-eqz v1, :cond_489

    .line 1132
    .line 1133
    invoke-virtual/range {p1 .. p1}, Lcom/newspaperdirect/pressreader/android/core/Service;->h()Z

    .line 1134
    .line 1135
    .line 1136
    move-result v4

    .line 1137
    if-nez v4, :cond_489

    .line 1138
    .line 1139
    iget v4, v2, Lbp/m1;->j:I

    .line 1140
    .line 1141
    const/16 v5, 0xcb

    .line 1142
    .line 1143
    if-eq v4, v5, :cond_47e

    .line 1144
    .line 1145
    if-eq v4, v3, :cond_47e

    .line 1146
    .line 1147
    const/16 v5, 0xce

    .line 1148
    .line 1149
    if-ne v4, v5, :cond_489

    .line 1150
    .line 1151
    :cond_47e
    sget-object v3, Lxv/c;->b:Lxv/c;

    .line 1152
    .line 1153
    new-instance v4, Lbo/c;

    .line 1154
    .line 1155
    invoke-direct {v4, v1}, Lbo/c;-><init>(Lcom/newspaperdirect/pressreader/android/core/Service;)V

    .line 1156
    .line 1157
    .line 1158
    invoke-virtual {v3, v4}, Lxv/c;->b(Ljava/lang/Object;)V

    .line 1159
    .line 1160
    .line 1161
    goto :goto_4bb

    .line 1162
    :cond_489
    iget v4, v2, Lbp/m1;->j:I

    .line 1163
    .line 1164
    if-ne v4, v3, :cond_49a

    .line 1165
    .line 1166
    if-eqz v1, :cond_4bb

    .line 1167
    .line 1168
    sget-object v3, Lxv/c;->b:Lxv/c;

    .line 1169
    .line 1170
    new-instance v4, Lbo/f0;

    .line 1171
    .line 1172
    invoke-direct {v4, v1}, Lbo/f0;-><init>(Lcom/newspaperdirect/pressreader/android/core/Service;)V

    .line 1173
    .line 1174
    .line 1175
    invoke-virtual {v3, v4}, Lxv/c;->b(Ljava/lang/Object;)V

    .line 1176
    .line 1177
    .line 1178
    goto :goto_4bb

    .line 1179
    :cond_49a
    const/16 v1, 0xc9

    .line 1180
    .line 1181
    if-eq v4, v1, :cond_4ad

    .line 1182
    .line 1183
    const/16 v1, 0xca

    .line 1184
    .line 1185
    if-ne v4, v1, :cond_4a3

    .line 1186
    .line 1187
    goto :goto_4ad

    .line 1188
    :cond_4a3
    new-instance v1, Lcom/newspaperdirect/pressreader/android/core/net/exception/ResponseException;

    .line 1189
    .line 1190
    iget v3, v2, Lbp/m1;->j:I

    .line 1191
    .line 1192
    iget-object v4, v2, Lbp/m1;->k:Ljava/lang/String;

    .line 1193
    .line 1194
    invoke-direct {v1, v3, v4}, Lcom/newspaperdirect/pressreader/android/core/net/exception/ResponseException;-><init>(ILjava/lang/String;)V

    .line 1195
    .line 1196
    .line 1197
    throw v1

    .line 1198
    :cond_4ad
    :goto_4ad
    new-instance v1, Lcom/newspaperdirect/pressreader/android/core/net/exception/DeviceLimitException;

    .line 1199
    .line 1200
    iget v3, v2, Lbp/m1;->j:I

    .line 1201
    .line 1202
    iget-object v4, v2, Lbp/m1;->k:Ljava/lang/String;

    .line 1203
    .line 1204
    iget-object v5, v2, Lbp/m1;->l:Ljava/util/ArrayList;

    .line 1205
    .line 1206
    iget-object v6, v2, Lbp/m1;->m:Ljava/lang/String;

    .line 1207
    .line 1208
    invoke-direct {v1, v3, v4, v5, v6}, Lcom/newspaperdirect/pressreader/android/core/net/exception/DeviceLimitException;-><init>(ILjava/lang/String;Ljava/util/ArrayList;Ljava/lang/String;)V

    .line 1209
    .line 1210
    .line 1211
    throw v1

    .line 1212
    :cond_4bb
    :goto_4bb
    invoke-static/range {p1 .. p1}, Lbp/m1;->j(Lcom/newspaperdirect/pressreader/android/core/Service;)V

    .line 1213
    .line 1214
    .line 1215
    return-void

    .line 1216
    :catchall_4bf
    move-exception v0

    .line 1217
    goto/16 :goto_7e

    .line 1218
    .line 1219
    :cond_4c2
    :try_start_4c2
    throw v3
    :try_end_4c3
    .catchall {:try_start_4c2 .. :try_end_4c3} :catchall_4bf

    .line 1220
    :goto_4c3
    if-eqz v11, :cond_4ce

    .line 1221
    .line 1222
    :try_start_4c5
    invoke-virtual {v11}, Ljava/io/InputStream;->close()V
    :try_end_4c8
    .catch Ljava/io/IOException; {:try_start_4c5 .. :try_end_4c8} :catch_4c9

    .line 1223
    .line 1224
    .line 1225
    goto :goto_4ce

    .line 1226
    :catch_4c9
    move-exception v0

    .line 1227
    move-object v3, v0

    .line 1228
    invoke-static {v3}, Lj70/a;->a(Ljava/lang/Throwable;)V

    .line 1229
    .line 1230
    .line 1231
    :cond_4ce
    :goto_4ce
    if-eqz v10, :cond_4d3

    .line 1232
    .line 1233
    invoke-virtual {v10}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 1234
    .line 1235
    .line 1236
    :cond_4d3
    throw v1

    .line 1237
    :cond_4d4
    move-object v2, v1

    .line 1238
    new-instance v1, Ljava/io/IOException;

    .line 1239
    .line 1240
    const-string v3, "No network connection"

    .line 1241
    .line 1242
    invoke-direct {v1, v3}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    .line 1243
    .line 1244
    .line 1245
    throw v1
.end method

###### Class bp.m1.a (bp.m1$a)
.class public final Lbp/m1$a;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lbp/m1;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "a"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lbp/m1$a$a;
    }
.end annotation


# instance fields
.field public a:Lbp/m1$a$a;

.field public b:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 2
    .line 3
    .line 4
    sget-object v0, Lbp/m1$a$a;->Action:Lbp/m1$a$a;

    .line 5
    .line 6
    iput-object v0, p0, Lbp/m1$a;->a:Lbp/m1$a$a;

    .line 7
    .line 8
    return-void
.end method


# virtual methods
.method public final a(Ljava/lang/String;)V
    .registers 3

    .line 1
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 2
    .line 3
    .line 4
    move-result v0

    .line 5
    if-nez v0, :cond_34

    .line 6
    .line 7
    const-string v0, "Alert"

    .line 8
    .line 9
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 10
    .line 11
    .line 12
    move-result v0

    .line 13
    if-eqz v0, :cond_13

    .line 14
    .line 15
    sget-object p1, Lbp/m1$a$a;->Alert:Lbp/m1$a$a;

    .line 16
    .line 17
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;

    .line 18
    .line 19
    goto :goto_34

    .line 20
    :cond_13
    const-string v0, "Action"

    .line 21
    .line 22
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 23
    .line 24
    .line 25
    move-result v0

    .line 26
    if-eqz v0, :cond_20

    .line 27
    .line 28
    sget-object p1, Lbp/m1$a$a;->Action:Lbp/m1$a$a;

    .line 29
    .line 30
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;

    .line 31
    .line 32
    goto :goto_34

    .line 33
    :cond_20
    const-string v0, "reload_catalog"

    .line 34
    .line 35
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 36
    .line 37
    .line 38
    move-result v0

    .line 39
    if-nez v0, :cond_30

    .line 40
    .line 41
    const-string v0, "ReloadCatalog"

    .line 42
    .line 43
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    .line 44
    .line 45
    .line 46
    move-result p1

    .line 47
    if-eqz p1, :cond_34

    .line 48
    .line 49
    :cond_30
    sget-object p1, Lbp/m1$a$a;->ReloadCatalog:Lbp/m1$a$a;

    .line 50
    .line 51
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;

    .line 52
    .line 53
    :cond_34
    :goto_34
    return-void
.end method

###### Class bp.m1.a.EnumC0116a (bp.m1$a$a)
.class public final enum Lbp/m1$a$a;
.super Ljava/lang/Enum;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lbp/m1$a;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "a"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lbp/m1$a$a;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lbp/m1$a$a;

.field public static final enum Action:Lbp/m1$a$a;

.field public static final enum Alert:Lbp/m1$a$a;

.field public static final enum ReloadCatalog:Lbp/m1$a$a;


# direct methods
.method private static synthetic $values()[Lbp/m1$a$a;
    .registers 3

    .line 1
    sget-object v0, Lbp/m1$a$a;->Alert:Lbp/m1$a$a;

    .line 2
    .line 3
    sget-object v1, Lbp/m1$a$a;->ReloadCatalog:Lbp/m1$a$a;

    .line 4
    .line 5
    sget-object v2, Lbp/m1$a$a;->Action:Lbp/m1$a$a;

    .line 6
    .line 7
    filled-new-array {v0, v1, v2}, [Lbp/m1$a$a;

    .line 8
    .line 9
    .line 10
    move-result-object v0

    .line 11
    return-object v0
.end method

.method static constructor <clinit>()V
    .registers 3

    .line 1
    new-instance v0, Lbp/m1$a$a;

    .line 2
    .line 3
    const-string v1, "Alert"

    .line 4
    .line 5
    const/4 v2, 0x0

    .line 6
    invoke-direct {v0, v1, v2}, Lbp/m1$a$a;-><init>(Ljava/lang/String;I)V

    .line 7
    .line 8
    .line 9
    sput-object v0, Lbp/m1$a$a;->Alert:Lbp/m1$a$a;

    .line 10
    .line 11
    new-instance v0, Lbp/m1$a$a;

    .line 12
    .line 13
    const-string v1, "ReloadCatalog"

    .line 14
    .line 15
    const/4 v2, 0x1

    .line 16
    invoke-direct {v0, v1, v2}, Lbp/m1$a$a;-><init>(Ljava/lang/String;I)V

    .line 17
    .line 18
    .line 19
    sput-object v0, Lbp/m1$a$a;->ReloadCatalog:Lbp/m1$a$a;

    .line 20
    .line 21
    new-instance v0, Lbp/m1$a$a;

    .line 22
    .line 23
    const-string v1, "Action"

    .line 24
    .line 25
    const/4 v2, 0x2

    .line 26
    invoke-direct {v0, v1, v2}, Lbp/m1$a$a;-><init>(Ljava/lang/String;I)V

    .line 27
    .line 28
    .line 29
    sput-object v0, Lbp/m1$a$a;->Action:Lbp/m1$a$a;

    .line 30
    .line 31
    invoke-static {}, Lbp/m1$a$a;->$values()[Lbp/m1$a$a;

    .line 32
    .line 33
    .line 34
    move-result-object v0

    .line 35
    sput-object v0, Lbp/m1$a$a;->$VALUES:[Lbp/m1$a$a;

    .line 36
    .line 37
    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 1
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 2
    .line 3
    .line 4
    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lbp/m1$a$a;
    .registers 2

    .line 1
    const-class v0, Lbp/m1$a$a;

    .line 2
    .line 3
    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    .line 4
    .line 5
    .line 6
    move-result-object p0

    .line 7
    check-cast p0, Lbp/m1$a$a;

    .line 8
    .line 9
    return-object p0
.end method

.method public static values()[Lbp/m1$a$a;
    .registers 1

    .line 1
    sget-object v0, Lbp/m1$a$a;->$VALUES:[Lbp/m1$a$a;

    .line 2
    .line 3
    invoke-virtual {v0}, [Lbp/m1$a$a;->clone()Ljava/lang/Object;

    .line 4
    .line 5
    .line 6
    move-result-object v0

    .line 7
    check-cast v0, [Lbp/m1$a$a;

    .line 8
    .line 9
    return-object v0
.end method

###### Class bp.f1 (bp.f1)
.class public final synthetic Lbp/f1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroid/sax/StartElementListener;


# instance fields
.field public final synthetic a:Llm/v;


# direct methods
.method public synthetic constructor <init>(Llm/v;)V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lbp/f1;->a:Llm/v;

    return-void
.end method


# virtual methods
.method public final start(Lorg/xml/sax/Attributes;)V
    .registers 5

    .line 1
    iget-object v0, p0, Lbp/f1;->a:Llm/v;

    .line 2
    .line 3
    new-instance v1, Lbp/m1$a;

    .line 4
    .line 5
    invoke-direct {v1}, Lbp/m1$a;-><init>()V

    .line 6
    .line 7
    .line 8
    iput-object v1, v0, Llm/v;->a:Ljava/lang/Object;

    .line 9
    .line 10
    const-string v2, "name"

    .line 11
    .line 12
    invoke-interface {p1, v2}, Lorg/xml/sax/Attributes;->getValue(Ljava/lang/String;)Ljava/lang/String;

    .line 13
    .line 14
    .line 15
    move-result-object p1

    .line 16
    invoke-virtual {v1, p1}, Lbp/m1$a;->a(Ljava/lang/String;)V

    .line 17
    .line 18
    .line 19
    sget-object p1, Lbp/m1;->r:Ljava/util/LinkedList;

    .line 20
    .line 21
    monitor-enter p1

    .line 22
    :try_start_15
    iget-object v0, v0, Llm/v;->a:Ljava/lang/Object;

    .line 23
    .line 24
    check-cast v0, Lbp/m1$a;

    .line 25
    .line 26
    invoke-virtual {p1, v0}, Ljava/util/LinkedList;->add(Ljava/lang/Object;)Z

    .line 27
    .line 28
    .line 29
    monitor-exit p1

    .line 30
    return-void

    .line 31
    :catchall_1e
    move-exception v0

    .line 32
    monitor-exit p1
    :try_end_20
    .catchall {:try_start_15 .. :try_end_20} :catchall_1e

    .line 33
    throw v0
.end method

###### Class bp.h1 (bp.h1)
.class public final synthetic Lbp/h1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroid/sax/StartElementListener;


# instance fields
.field public final synthetic a:Lbp/m1;


# direct methods
.method public synthetic constructor <init>(Lbp/m1;)V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lbp/h1;->a:Lbp/m1;

    return-void
.end method


# virtual methods
.method public final start(Lorg/xml/sax/Attributes;)V
    .registers 3

    .line 1
    const/4 p1, 0x0

    .line 2
    iget-object v0, p0, Lbp/h1;->a:Lbp/m1;

    .line 3
    .line 4
    iput p1, v0, Lbp/m1;->j:I

    .line 5
    .line 6
    const/4 p1, 0x0

    .line 7
    iput-object p1, v0, Lbp/m1;->k:Ljava/lang/String;

    .line 8
    .line 9
    iget-object p1, v0, Lbp/m1;->l:Ljava/util/ArrayList;

    .line 10
    .line 11
    invoke-virtual {p1}, Ljava/util/ArrayList;->clear()V

    .line 12
    .line 13
    .line 14
    return-void
.end method

###### Class bp.j1 (bp.j1)
.class public final synthetic Lbp/j1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroid/sax/StartElementListener;


# instance fields
.field public final synthetic a:Lbp/m1;


# direct methods
.method public synthetic constructor <init>(Lbp/m1;)V
    .registers 2

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lbp/j1;->a:Lbp/m1;

    return-void
.end method


# virtual methods
.method public final start(Lorg/xml/sax/Attributes;)V
    .registers 12

    .line 1
    iget-object v0, p0, Lbp/j1;->a:Lbp/m1;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 4
    .line 5
    .line 6
    new-instance v9, Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;

    .line 7
    .line 8
    const-string v1, "activation-number"

    .line 9
    .line 10
    invoke-interface {p1, v1}, Lorg/xml/sax/Attributes;->getValue(Ljava/lang/String;)Ljava/lang/String;

    .line 11
    .line 12
    .line 13
    move-result-object v2

    .line 14
    const-string v1, "client-number"

    .line 15
    .line 16
    invoke-interface {p1, v1}, Lorg/xml/sax/Attributes;->getValue(Ljava/lang/String;)Ljava/lang/String;

    .line 17
    .line 18
    .line 19
    move-result-object v3

    .line 20
    const-string v1, "client-name"

    .line 21
    .line 22
    invoke-interface {p1, v1}, Lorg/xml/sax/Attributes;->getValue(Ljava/lang/String;)Ljava/lang/String;

    .line 23
    .line 24
    .line 25
    move-result-object v4

    .line 26
    const-string v1, "last-active-at"

    .line 27
    .line 28
    invoke-interface {p1, v1}, Lorg/xml/sax/Attributes;->getValue(Ljava/lang/String;)Ljava/lang/String;

    .line 29
    .line 30
    .line 31
    move-result-object v1

    .line 32
    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 33
    .line 34
    .line 35
    move-result v1

    .line 36
    int-to-long v5, v1

    .line 37
    const-string v1, "created-at"

    .line 38
    .line 39
    invoke-interface {p1, v1}, Lorg/xml/sax/Attributes;->getValue(Ljava/lang/String;)Ljava/lang/String;

    .line 40
    .line 41
    .line 42
    move-result-object p1

    .line 43
    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    .line 44
    .line 45
    .line 46
    move-result p1

    .line 47
    int-to-long v7, p1

    .line 48
    move-object v1, v9

    .line 49
    invoke-direct/range {v1 .. v8}, Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JJ)V

    .line 50
    .line 51
    .line 52
    iget-object p1, v0, Lbp/m1;->l:Ljava/util/ArrayList;

    .line 53
    .line 54
    invoke-virtual {p1, v9}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 55
    .line 56
    .line 57
    return-void
.end method
