.class public final Lnet/pluservice/plusnetworking/PlusNetworking;
.super Ljava/lang/Object;


# static fields
.field private static final $$a:[B

.field private static final $$b:I

.field private static $10:I

.field private static $11:I

.field private static ICustomTabsCallback:J

.field private static asBinder:I

.field private static asInterface:I

.field private static extraCallback:C

.field private static extraCallbackWithResult:[C

.field private static final i:Lokhttp3/MediaType;

.field private static onMessageChannelReady:I

.field private static onNavigationEvent:C

.field private static onPostMessage:I

.field private static onRelationshipValidationResult:I


# instance fields
.field protected a:Lnet/pluservice/plusnetworking/Ambiente;

.field private b:Ljava/lang/String;

.field private c:Ljava/lang/String;

.field private d:Ljava/lang/String;

.field private e:Ljava/lang/String;

.field private f:Ljava/lang/String;

.field private g:Lokhttp3/OkHttpClient;

.field private h:Lnet/pluservice/plusnetworking/a/a;


# direct methods
.method private static $$c(BSI)Ljava/lang/String;
    .locals 6

    add-int/lit8 p2, p2, 0x4

    sget-object v0, Lnet/pluservice/plusnetworking/PlusNetworking;->$$a:[B

    rsub-int/lit8 p0, p0, 0x73

    mul-int/lit8 p1, p1, 0x3

    add-int/lit8 p1, p1, 0x1

    new-array v1, p1, [B

    const/4 v2, 0x0

    if-nez v0, :cond_0

    move v3, p0

    move p0, p1

    move v4, v2

    goto :goto_1

    :cond_0
    move v3, v2

    :goto_0
    add-int/lit8 v4, v3, 0x1

    int-to-byte v5, p0

    aput-byte v5, v1, v3

    add-int/lit8 p2, p2, 0x1

    if-ne v4, p1, :cond_1

    new-instance p0, Ljava/lang/String;

    invoke-direct {p0, v1, v2}, Ljava/lang/String;-><init>([BI)V

    return-object p0

    :cond_1
    aget-byte v3, v0, p2

    :goto_1
    add-int/2addr p0, v3

    move v3, v4

    goto :goto_0
.end method

.method static constructor <clinit>()V
    .locals 10

    const/4 v0, 0x4

    new-array v1, v0, [B

    fill-array-data v1, :array_0

    sput-object v1, Lnet/pluservice/plusnetworking/PlusNetworking;->$$a:[B

    const/16 v1, 0x53

    sput v1, Lnet/pluservice/plusnetworking/PlusNetworking;->$$b:I

    const/4 v1, 0x0

    .line 65354
    sput v1, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    const/4 v2, 0x1

    sput v2, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    sput v1, Lnet/pluservice/plusnetworking/PlusNetworking;->onRelationshipValidationResult:I

    sput v2, Lnet/pluservice/plusnetworking/PlusNetworking;->asBinder:I

    sput v1, Lnet/pluservice/plusnetworking/PlusNetworking;->onPostMessage:I

    sput v2, Lnet/pluservice/plusnetworking/PlusNetworking;->asInterface:I

    invoke-static {}, Lnet/pluservice/plusnetworking/PlusNetworking;->ICustomTabsCallback()V

    const/16 v3, 0x1f

    new-array v4, v3, [C

    fill-array-data v4, :array_1

    invoke-static {}, Landroid/view/ViewConfiguration;->getDoubleTapTimeout()I

    move-result v3

    shr-int/lit8 v3, v3, 0x10

    const v5, 0x79fbbbbd

    add-int/2addr v5, v3

    new-array v6, v0, [C

    fill-array-data v6, :array_2

    invoke-static {}, Landroid/view/KeyEvent;->getMaxKeyCode()I

    move-result v3

    shr-int/lit8 v3, v3, 0x10

    rsub-int v3, v3, 0x7399

    int-to-char v7, v3

    new-array v8, v0, [C

    fill-array-data v8, :array_3

    new-array v0, v2, [Ljava/lang/Object;

    move-object v9, v0

    invoke-static/range {v4 .. v9}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v0, v0, v1

    check-cast v0, Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lokhttp3/MediaType;->parse(Ljava/lang/String;)Lokhttp3/MediaType;

    move-result-object v0

    sput-object v0, Lnet/pluservice/plusnetworking/PlusNetworking;->i:Lokhttp3/MediaType;

    sget v0, Lnet/pluservice/plusnetworking/PlusNetworking;->asInterface:I

    add-int/lit8 v0, v0, 0x29

    rem-int/lit16 v1, v0, 0x80

    sput v1, Lnet/pluservice/plusnetworking/PlusNetworking;->onPostMessage:I

    rem-int/lit8 v0, v0, 0x2

    return-void

    :array_0
    .array-data 1
        0x31t
        0x1at
        -0x58t
        -0x23t
    .end array-data

    :array_1
    .array-data 2
        -0x5d9fs
        0x13f1s
        -0x3268s
        0x13ecs
        0x528cs
        0x1d3cs
        -0x4297s
        0x5e0ds
        0x6f06s
        0x2c80s
        -0x201es
        -0x15d2s
        -0x7930s
        -0x77ads
        -0x2fbfs
        -0x2fd1s
        -0x5846s
        -0x7686s
        -0x1f83s
        -0x2e2s
        0x6a31s
        0x78e5s
        -0x26d6s
        0x624es
        0x38dds
        0x274fs
        0x3f5fs
        -0x72e7s
        0x66as
        0x7b6bs
        -0x260as
    .end array-data

    nop

    :array_2
    .array-data 2
        -0x42d2s
        -0x445s
        -0x6687s
        0x2273s
    .end array-data

    :array_3
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Lnet/pluservice/plusnetworking/Ambiente;)V
    .locals 6

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move-object v3, p3

    .line 65353
    invoke-direct/range {v0 .. v5}, Lnet/pluservice/plusnetworking/PlusNetworking;-><init>(Ljava/lang/String;Ljava/lang/String;Lnet/pluservice/plusnetworking/Ambiente;[Lnet/pluservice/plusnetworking/CertificatePinningRule;B)V

    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Lnet/pluservice/plusnetworking/Ambiente;[Lnet/pluservice/plusnetworking/CertificatePinningRule;)V
    .locals 6

    const/4 v5, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move-object v3, p3

    move-object v4, p4

    .line 65352
    invoke-direct/range {v0 .. v5}, Lnet/pluservice/plusnetworking/PlusNetworking;-><init>(Ljava/lang/String;Ljava/lang/String;Lnet/pluservice/plusnetworking/Ambiente;[Lnet/pluservice/plusnetworking/CertificatePinningRule;B)V

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;Ljava/lang/String;Lnet/pluservice/plusnetworking/Ambiente;[Lnet/pluservice/plusnetworking/CertificatePinningRule;B)V
    .locals 17

    move-object/from16 v0, p0

    move-object/from16 v1, p4

    .line 65351
    invoke-direct/range {p0 .. p0}, Ljava/lang/Object;-><init>()V

    const/16 v2, 0xb

    new-array v3, v2, [C

    fill-array-data v3, :array_0

    const-string v2, ""

    const/4 v9, 0x0

    invoke-static {v2, v9}, Landroid/text/TextUtils;->getOffsetBefore(Ljava/lang/CharSequence;I)I

    move-result v2

    const v4, 0x20754a5c

    sub-int/2addr v4, v2

    const/4 v2, 0x4

    new-array v5, v2, [C

    fill-array-data v5, :array_1

    invoke-static {}, Landroid/view/ViewConfiguration;->getMaximumDrawingCacheSize()I

    move-result v6

    shr-int/lit8 v6, v6, 0x18

    int-to-char v6, v6

    new-array v7, v2, [C

    fill-array-data v7, :array_2

    const/4 v10, 0x1

    new-array v11, v10, [Ljava/lang/Object;

    move-object v8, v11

    invoke-static/range {v3 .. v8}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v3, v11, v9

    check-cast v3, Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v3

    iput-object v3, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->d:Ljava/lang/String;

    const/16 v3, 0x45

    new-array v11, v3, [C

    fill-array-data v11, :array_3

    invoke-static {}, Landroid/view/KeyEvent;->getModifierMetaStateMask()I

    move-result v3

    int-to-byte v3, v3

    const v4, 0x50f896af

    add-int v12, v3, v4

    new-array v13, v2, [C

    fill-array-data v13, :array_4

    invoke-static {v9}, Landroid/graphics/Color;->red(I)I

    move-result v3

    rsub-int v3, v3, 0x1d79

    int-to-char v14, v3

    new-array v15, v2, [C

    fill-array-data v15, :array_5

    new-array v2, v10, [Ljava/lang/Object;

    move-object/from16 v16, v2

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v2, v2, v9

    check-cast v2, Ljava/lang/String;

    invoke-virtual {v2}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v2

    iput-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->e:Ljava/lang/String;

    move-object/from16 v2, p1

    iput-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->b:Ljava/lang/String;

    move-object/from16 v2, p2

    iput-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->c:Ljava/lang/String;

    move-object/from16 v2, p3

    iput-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->a:Lnet/pluservice/plusnetworking/Ambiente;

    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v2

    invoke-virtual {v2}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v2

    iput-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->f:Ljava/lang/String;

    new-instance v2, Lnet/pluservice/plusnetworking/a/a;

    iget-object v3, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->d:Ljava/lang/String;

    iget-object v4, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->e:Ljava/lang/String;

    invoke-direct {v2, v3, v4}, Lnet/pluservice/plusnetworking/a/a;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    iput-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->h:Lnet/pluservice/plusnetworking/a/a;

    new-instance v2, Lokhttp3/OkHttpClient$Builder;

    invoke-direct {v2}, Lokhttp3/OkHttpClient$Builder;-><init>()V

    const/4 v3, 0x2

    if-eqz v1, :cond_1

    new-instance v4, Lokhttp3/CertificatePinner$Builder;

    invoke-direct {v4}, Lokhttp3/CertificatePinner$Builder;-><init>()V

    array-length v5, v1

    move v6, v9

    :goto_0
    if-ge v6, v5, :cond_0

    sget v7, Lnet/pluservice/plusnetworking/PlusNetworking;->asBinder:I

    add-int/lit8 v7, v7, 0x19

    rem-int/lit16 v8, v7, 0x80

    sput v8, Lnet/pluservice/plusnetworking/PlusNetworking;->onRelationshipValidationResult:I

    rem-int/2addr v7, v3

    aget-object v7, v1, v6

    iget-object v8, v7, Lnet/pluservice/plusnetworking/CertificatePinningRule;->a:Ljava/lang/String;

    iget-object v7, v7, Lnet/pluservice/plusnetworking/CertificatePinningRule;->b:[Ljava/lang/String;

    invoke-virtual {v4, v8, v7}, Lokhttp3/CertificatePinner$Builder;->add(Ljava/lang/String;[Ljava/lang/String;)Lokhttp3/CertificatePinner$Builder;

    add-int/lit8 v6, v6, 0x1

    goto :goto_0

    :cond_0
    invoke-virtual {v4}, Lokhttp3/CertificatePinner$Builder;->build()Lokhttp3/CertificatePinner;

    move-result-object v1

    invoke-virtual {v2, v1}, Lokhttp3/OkHttpClient$Builder;->certificatePinner(Lokhttp3/CertificatePinner;)Lokhttp3/OkHttpClient$Builder;

    rem-int v1, v3, v3

    :cond_1
    invoke-virtual {v2}, Lokhttp3/OkHttpClient$Builder;->build()Lokhttp3/OkHttpClient;

    move-result-object v1

    iput-object v1, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->g:Lokhttp3/OkHttpClient;

    sget v1, Lnet/pluservice/plusnetworking/PlusNetworking;->onRelationshipValidationResult:I

    add-int/lit8 v1, v1, 0x59

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/plusnetworking/PlusNetworking;->asBinder:I

    rem-int/2addr v1, v3

    if-nez v1, :cond_2

    const/16 v1, 0x16

    div-int/2addr v1, v9

    :cond_2
    return-void

    :array_0
    .array-data 2
        -0x8s
        -0x57fas
        0x640es
        -0x17e8s
        -0x554cs
        0x335s
        0x6727s
        0x3cf2s
        0x30ebs
        0x4cbds
        0x5bbds
    .end array-data

    nop

    :array_1
    .array-data 2
        0x5c37s
        0x754as
        -0x47e0s
        0x1b25s
    .end array-data

    :array_2
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_3
    .array-data 2
        -0x7ae4s
        -0x6fe8s
        0x137es
        -0x5c66s
        0x479bs
        0x716bs
        0x34cs
        -0x6aecs
        0x781ds
        0xb97s
        0x469fs
        -0x313fs
        0x6a2s
        -0xcces
        0x181cs
        -0x3436s
        -0x39acs
        -0x2ad7s
        -0x534fs
        -0x5e08s
        -0x6f77s
        -0x7fb9s
        -0x51dcs
        -0x361cs
        -0x98es
        -0x5c07s
        -0x3859s
        0x396cs
        0x2722s
        -0x3e68s
        -0x21d2s
        -0x30e0s
        0x230s
        0x2c13s
        0x5db7s
        0x7d1es
        -0x2f7cs
        -0x1e13s
        -0x7fcs
        0x3519s
        0x6ees
        -0x77f8s
        0x10b9s
        -0x65fbs
        0x42c4s
        -0x3426s
        -0x8a1s
        0x1ddes
        0x709ds
        -0x3ac7s
        -0x4399s
        -0x5620s
        0x5c91s
        0x6f4as
        -0x57ccs
        -0x1b06s
        -0x2d71s
        0x20d0s
        0x6727s
        0xb05s
        -0x56f9s
        0x6e89s
        0x6487s
        0xb61s
        -0x5c7bs
        0x4080s
        -0x69fds
        -0x9e0s
        -0xf95s
    .end array-data

    nop

    :array_4
    .array-data 2
        -0x5102s
        -0x76as
        0x7950s
        -0xde3s
    .end array-data

    :array_5
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data
.end method

.method static ICustomTabsCallback()V
    .locals 2

    const-wide v0, -0x120f87db1000b25bL    # -3.720765724564847E221

    .line 65349
    sput-wide v0, Lnet/pluservice/plusnetworking/PlusNetworking;->ICustomTabsCallback:J

    const v0, -0x36134583

    sput v0, Lnet/pluservice/plusnetworking/PlusNetworking;->onMessageChannelReady:I

    const v0, 0xba7d

    sput-char v0, Lnet/pluservice/plusnetworking/PlusNetworking;->onNavigationEvent:C

    const/16 v0, 0x19

    new-array v0, v0, [C

    fill-array-data v0, :array_0

    sput-object v0, Lnet/pluservice/plusnetworking/PlusNetworking;->extraCallbackWithResult:[C

    const v0, 0xeb67

    sput-char v0, Lnet/pluservice/plusnetworking/PlusNetworking;->extraCallback:C

    return-void

    :array_0
    .array-data 2
        -0x217fs
        -0x217as
        -0x2166s
        -0x216fs
        -0x2179s
        -0x2178s
        -0x2129s
        -0x2139s
        -0x2180s
        -0x2169s
        -0x2174s
        -0x2176s
        -0x217cs
        -0x216cs
        -0x213bs
        -0x2173s
        -0x2171s
        -0x216bs
        -0x2170s
        -0x2167s
        -0x2177s
        -0x212as
        -0x2175s
        -0x213es
        -0x217bs
    .end array-data
.end method

.method private static j([CI[CC[C[Ljava/lang/Object;)V
    .locals 26

    move-object/from16 v0, p0

    move-object/from16 v1, p2

    move-object/from16 v2, p4

    const/4 v3, 0x2

    .line 127
    rem-int v4, v3, v3

    .line 95
    new-instance v4, Lo/getLifecycle;

    invoke-direct {v4}, Lo/getLifecycle;-><init>()V

    .line 97
    array-length v5, v1

    new-array v6, v5, [C

    .line 98
    array-length v7, v2

    new-array v8, v7, [C

    const/4 v9, 0x0

    .line 99
    invoke-static {v1, v9, v6, v9, v5}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 100
    invoke-static {v2, v9, v8, v9, v7}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 101
    aget-char v1, v6, v9

    xor-int v1, v1, p3

    int-to-char v1, v1

    aput-char v1, v6, v9

    .line 102
    aget-char v1, v8, v3

    move/from16 v2, p1

    int-to-char v2, v2

    add-int/2addr v1, v2

    int-to-char v1, v1

    aput-char v1, v8, v3

    .line 104
    array-length v1, v0

    .line 105
    new-array v2, v1, [C

    .line 106
    iput v9, v4, Lo/getLifecycle;->onNavigationEvent:I

    :goto_0
    iget v5, v4, Lo/getLifecycle;->onNavigationEvent:I

    if-ge v5, v1, :cond_5

    .line 127
    sget v5, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    add-int/lit8 v5, v5, 0x4f

    rem-int/lit16 v7, v5, 0x80

    sput v7, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    rem-int/2addr v5, v3

    .line 107
    :try_start_0
    filled-new-array {v4}, [Ljava/lang/Object;

    move-result-object v5

    const v7, 0x2478f869

    invoke-static {v7}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v7
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    const-string v10, ""

    const/4 v11, 0x1

    if-nez v7, :cond_0

    :try_start_1
    invoke-static {v10, v10, v9, v9}, Landroid/text/TextUtils;->indexOf(Ljava/lang/CharSequence;Ljava/lang/CharSequence;II)I

    move-result v7

    int-to-char v12, v7

    invoke-static {}, Landroid/view/ViewConfiguration;->getFadingEdgeLength()I

    move-result v7

    shr-int/lit8 v7, v7, 0x10

    add-int/lit16 v13, v7, 0x7e1

    const/4 v7, 0x0

    invoke-static {v7, v7}, Landroid/graphics/PointF;->length(FF)F

    move-result v14

    cmpl-float v7, v14, v7

    rsub-int/lit8 v14, v7, 0x15

    const/16 v16, 0x0

    const/16 v7, 0x2f

    int-to-byte v7, v7

    int-to-byte v3, v9

    add-int/lit8 v15, v3, -0x1

    int-to-byte v15, v15

    invoke-static {v7, v3, v15}, Lnet/pluservice/plusnetworking/PlusNetworking;->$$c(BSI)Ljava/lang/String;

    move-result-object v17

    new-array v3, v11, [Ljava/lang/Class;

    const-class v7, Ljava/lang/Object;

    aput-object v7, v3, v9

    const v7, -0x31511e7b

    move v15, v7

    move-object/from16 v18, v3

    invoke-static/range {v12 .. v18}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v7

    :cond_0
    check-cast v7, Ljava/lang/reflect/Method;

    const/4 v3, 0x0

    invoke-virtual {v7, v3, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/Integer;

    invoke-virtual {v5}, Ljava/lang/Integer;->intValue()I

    move-result v5

    .line 108
    filled-new-array {v4}, [Ljava/lang/Object;

    move-result-object v7

    const v12, 0x5ffbe649

    invoke-static {v12}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v12

    const-wide/16 v13, 0x0

    if-nez v12, :cond_1

    invoke-static {v9, v9}, Landroid/view/View;->combineMeasuredStates(II)I

    move-result v12

    add-int/lit16 v12, v12, 0x7cb5

    int-to-char v12, v12

    invoke-static {v10, v9}, Landroid/text/TextUtils;->getOffsetAfter(Ljava/lang/CharSequence;I)I

    move-result v15

    rsub-int v15, v15, 0x460

    invoke-static {}, Landroid/view/ViewConfiguration;->getGlobalActionKeyTimeout()J

    move-result-wide v16

    cmp-long v16, v16, v13

    add-int/lit8 v21, v16, 0x15

    const v22, -0x4ad2005b

    const/16 v23, 0x0

    sget-object v16, Lnet/pluservice/plusnetworking/PlusNetworking;->$$a:[B

    aget-byte v13, v16, v9

    int-to-byte v13, v13

    int-to-byte v14, v9

    add-int/lit8 v3, v14, -0x1

    int-to-byte v3, v3

    invoke-static {v13, v14, v3}, Lnet/pluservice/plusnetworking/PlusNetworking;->$$c(BSI)Ljava/lang/String;

    move-result-object v24

    new-array v3, v11, [Ljava/lang/Class;

    const-class v13, Ljava/lang/Object;

    aput-object v13, v3, v9

    move/from16 v19, v12

    move/from16 v20, v15

    move-object/from16 v25, v3

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v12

    :cond_1
    check-cast v12, Ljava/lang/reflect/Method;

    const/4 v3, 0x0

    invoke-virtual {v12, v3, v7}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/Integer;

    invoke-virtual {v7}, Ljava/lang/Integer;->intValue()I

    move-result v3
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 111
    iget v7, v4, Lo/getLifecycle;->onNavigationEvent:I

    rem-int/lit8 v7, v7, 0x4

    aget-char v7, v6, v7

    mul-int/lit16 v7, v7, 0x7fce

    aget-char v12, v8, v5

    const/4 v13, 0x3

    :try_start_2
    new-array v14, v13, [Ljava/lang/Object;

    invoke-static {v12}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    const/4 v15, 0x2

    aput-object v12, v14, v15

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    aput-object v7, v14, v11

    aput-object v4, v14, v9

    const v7, -0x426a27e6

    invoke-static {v7}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v7

    if-nez v7, :cond_2

    invoke-static {}, Landroid/view/ViewConfiguration;->getTouchSlop()I

    move-result v7

    shr-int/lit8 v7, v7, 0x8

    rsub-int v7, v7, 0x5d15

    int-to-char v7, v7

    invoke-static {v9}, Landroid/graphics/Color;->green(I)I

    move-result v12

    rsub-int v12, v12, 0x436

    invoke-static {v9, v9, v9}, Landroid/view/View;->resolveSizeAndState(III)I

    move-result v15

    add-int/lit8 v21, v15, 0x14

    const v22, 0x5743c1f6

    const/16 v23, 0x0

    sget-object v15, Lnet/pluservice/plusnetworking/PlusNetworking;->$$a:[B

    aget-byte v15, v15, v9

    add-int/2addr v15, v11

    int-to-byte v15, v15

    int-to-byte v11, v9

    add-int/lit8 v9, v11, -0x1

    int-to-byte v9, v9

    invoke-static {v15, v11, v9}, Lnet/pluservice/plusnetworking/PlusNetworking;->$$c(BSI)Ljava/lang/String;

    move-result-object v24

    new-array v9, v13, [Ljava/lang/Class;

    const-class v11, Ljava/lang/Object;

    const/4 v13, 0x0

    aput-object v11, v9, v13

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v13, 0x1

    aput-object v11, v9, v13

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v13, 0x2

    aput-object v11, v9, v13

    move/from16 v19, v7

    move/from16 v20, v12

    move-object/from16 v25, v9

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v7

    :cond_2
    check-cast v7, Ljava/lang/reflect/Method;

    const/4 v9, 0x0

    invoke-virtual {v7, v9, v14}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 113
    aget-char v7, v6, v3

    mul-int/lit16 v7, v7, 0x7fce

    aget-char v5, v8, v5

    const/4 v9, 0x2

    :try_start_3
    new-array v11, v9, [Ljava/lang/Object;

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    const/4 v9, 0x1

    aput-object v5, v11, v9

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    const/4 v7, 0x0

    aput-object v5, v11, v7

    const v5, -0x1310d330

    invoke-static {v5}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v5

    if-nez v5, :cond_3

    invoke-static {v10, v7}, Landroid/text/TextUtils;->getOffsetAfter(Ljava/lang/CharSequence;I)I

    move-result v5

    int-to-char v5, v5

    const-wide/16 v9, 0x0

    invoke-static {v9, v10}, Landroid/widget/ExpandableListView;->getPackedPositionGroup(J)I

    move-result v7

    add-int/lit16 v7, v7, 0xff

    invoke-static {}, Landroid/view/ViewConfiguration;->getFadingEdgeLength()I

    move-result v9

    shr-int/lit8 v9, v9, 0x10

    rsub-int/lit8 v21, v9, 0x1a

    const v22, 0x639353c

    const/16 v23, 0x0

    const-string v24, "H"

    const/4 v9, 0x2

    new-array v10, v9, [Ljava/lang/Class;

    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v12, 0x0

    aput-object v9, v10, v12

    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v12, 0x1

    aput-object v9, v10, v12

    move/from16 v19, v5

    move/from16 v20, v7

    move-object/from16 v25, v10

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v5

    :cond_3
    check-cast v5, Ljava/lang/reflect/Method;

    const/4 v7, 0x0

    invoke-virtual {v5, v7, v11}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/Character;

    invoke-virtual {v5}, Ljava/lang/Character;->charValue()C

    move-result v5
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    aput-char v5, v8, v3

    .line 115
    iget-char v5, v4, Lo/getLifecycle;->extraCallbackWithResult:C

    aput-char v5, v6, v3

    .line 118
    iget v5, v4, Lo/getLifecycle;->onNavigationEvent:I

    iget v7, v4, Lo/getLifecycle;->onNavigationEvent:I

    aget-char v7, v0, v7

    aget-char v3, v6, v3

    xor-int/2addr v3, v7

    int-to-long v9, v3

    sget-wide v11, Lnet/pluservice/plusnetworking/PlusNetworking;->ICustomTabsCallback:J

    const-wide v13, 0x10516a81c9ecba7dL    # 4.487172936872151E-230

    xor-long/2addr v11, v13

    xor-long/2addr v9, v11

    sget v3, Lnet/pluservice/plusnetworking/PlusNetworking;->onMessageChannelReady:I

    int-to-long v11, v3

    xor-long/2addr v11, v13

    long-to-int v3, v11

    int-to-long v11, v3

    xor-long/2addr v9, v11

    sget-char v3, Lnet/pluservice/plusnetworking/PlusNetworking;->onNavigationEvent:C

    int-to-long v11, v3

    xor-long/2addr v11, v13

    long-to-int v3, v11

    int-to-char v3, v3

    int-to-long v11, v3

    xor-long/2addr v9, v11

    long-to-int v3, v9

    int-to-char v3, v3

    aput-char v3, v2, v5

    .line 106
    iget v3, v4, Lo/getLifecycle;->onNavigationEvent:I

    const/4 v5, 0x1

    add-int/2addr v3, v5

    iput v3, v4, Lo/getLifecycle;->onNavigationEvent:I

    .line 127
    sget v3, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    add-int/lit8 v3, v3, 0x17

    rem-int/lit16 v5, v3, 0x80

    sput v5, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    const/4 v5, 0x2

    rem-int/2addr v3, v5

    move v3, v5

    const/4 v9, 0x0

    goto/16 :goto_0

    :catchall_0
    move-exception v0

    .line 107
    invoke-virtual {v0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_4

    throw v1

    :cond_4
    throw v0

    .line 127
    :cond_5
    new-instance v0, Ljava/lang/String;

    invoke-direct {v0, v2}, Ljava/lang/String;-><init>([C)V

    const/4 v1, 0x0

    aput-object v0, p5, v1

    return-void
.end method

.method private static k(BI[C[Ljava/lang/Object;)V
    .locals 31

    move/from16 v0, p1

    const/4 v1, 0x2

    .line 273
    rem-int v2, v1, v1

    .line 190
    new-instance v2, Lo/addOnPictureInPictureModeChangedListener;

    invoke-direct {v2}, Lo/addOnPictureInPictureModeChangedListener;-><init>()V

    .line 195
    sget-object v3, Lnet/pluservice/plusnetworking/PlusNetworking;->extraCallbackWithResult:[C

    const v4, -0x79eba608

    const/4 v5, 0x0

    const-string v6, ""

    const/4 v7, 0x0

    const/4 v8, 0x1

    if-eqz v3, :cond_3

    array-length v9, v3

    new-array v10, v9, [C

    move v11, v7

    :goto_0
    if-ge v11, v9, :cond_2

    aget-char v12, v3, v11

    :try_start_0
    new-array v13, v8, [Ljava/lang/Object;

    invoke-static {v12}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    aput-object v12, v13, v7

    invoke-static {v4}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v12

    if-nez v12, :cond_0

    const/16 v12, 0x30

    invoke-static {v6, v12, v7}, Landroid/text/TextUtils;->lastIndexOf(Ljava/lang/CharSequence;CI)I

    move-result v12

    rsub-int v12, v12, 0x7ab2

    int-to-char v14, v12

    invoke-static {v6}, Landroid/os/Process;->getGidForName(Ljava/lang/String;)I

    move-result v12

    rsub-int v15, v12, 0x5e7

    invoke-static {v6, v7}, Landroid/text/TextUtils;->getOffsetAfter(Ljava/lang/CharSequence;I)I

    move-result v12

    add-int/lit8 v16, v12, 0x15

    const v17, 0x6cc24014

    const/16 v18, 0x0

    sget v12, Lnet/pluservice/plusnetworking/PlusNetworking;->$$b:I

    and-int/lit8 v12, v12, 0xf

    int-to-byte v12, v12

    add-int/lit8 v1, v12, -0x3

    int-to-byte v1, v1

    add-int/lit8 v4, v1, -0x1

    int-to-byte v4, v4

    invoke-static {v12, v1, v4}, Lnet/pluservice/plusnetworking/PlusNetworking;->$$c(BSI)Ljava/lang/String;

    move-result-object v19

    new-array v1, v8, [Ljava/lang/Class;

    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v4, v1, v7

    move-object/from16 v20, v1

    invoke-static/range {v14 .. v20}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v12

    :cond_0
    check-cast v12, Ljava/lang/reflect/Method;

    invoke-virtual {v12, v5, v13}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Character;

    invoke-virtual {v1}, Ljava/lang/Character;->charValue()C

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    aput-char v1, v10, v11

    add-int/lit8 v11, v11, 0x1

    const/4 v1, 0x2

    const v4, -0x79eba608

    goto :goto_0

    :catchall_0
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_1

    throw v1

    :cond_1
    throw v0

    :cond_2
    move-object v3, v10

    .line 197
    :cond_3
    sget-char v1, Lnet/pluservice/plusnetworking/PlusNetworking;->extraCallback:C

    :try_start_1
    new-array v4, v8, [Ljava/lang/Object;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    aput-object v1, v4, v7

    const v1, -0x79eba608

    invoke-static {v1}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v1

    const-wide/16 v9, 0x0

    const/16 v11, 0x8

    if-nez v1, :cond_4

    invoke-static {}, Landroid/view/ViewConfiguration;->getWindowTouchSlop()I

    move-result v1

    shr-int/2addr v1, v11

    add-int/lit16 v1, v1, 0x7ab3

    int-to-char v12, v1

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v13

    cmp-long v1, v13, v9

    rsub-int v13, v1, 0x5e9

    invoke-static {v6, v6, v7}, Landroid/text/TextUtils;->indexOf(Ljava/lang/CharSequence;Ljava/lang/CharSequence;I)I

    move-result v1

    add-int/lit8 v14, v1, 0x15

    const v15, 0x6cc24014

    const/16 v16, 0x0

    sget v1, Lnet/pluservice/plusnetworking/PlusNetworking;->$$b:I

    and-int/lit8 v1, v1, 0xf

    int-to-byte v1, v1

    add-int/lit8 v6, v1, -0x3

    int-to-byte v6, v6

    add-int/lit8 v9, v6, -0x1

    int-to-byte v9, v9

    invoke-static {v1, v6, v9}, Lnet/pluservice/plusnetworking/PlusNetworking;->$$c(BSI)Ljava/lang/String;

    move-result-object v17

    new-array v1, v8, [Ljava/lang/Class;

    sget-object v6, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v6, v1, v7

    move-object/from16 v18, v1

    invoke-static/range {v12 .. v18}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    :cond_4
    check-cast v1, Ljava/lang/reflect/Method;

    invoke-virtual {v1, v5, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Character;

    invoke-virtual {v1}, Ljava/lang/Character;->charValue()C

    move-result v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 201
    new-array v4, v0, [C

    .line 204
    rem-int/lit8 v6, v0, 0x2

    if-eqz v6, :cond_5

    .line 273
    sget v6, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    add-int/lit8 v6, v6, 0x49

    rem-int/lit16 v9, v6, 0x80

    sput v9, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    const/4 v10, 0x2

    rem-int/2addr v6, v10

    add-int/lit8 v6, v0, -0x1

    .line 206
    aget-char v10, p2, v6

    sub-int v10, v10, p0

    int-to-char v10, v10

    aput-char v10, v4, v6

    add-int/lit8 v9, v9, 0x1b

    .line 273
    rem-int/lit16 v10, v9, 0x80

    sput v10, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    const/4 v10, 0x2

    rem-int/2addr v9, v10

    goto :goto_1

    :cond_5
    move v6, v0

    :goto_1
    if-le v6, v8, :cond_c

    .line 210
    iput v7, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    :goto_2
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    if-ge v9, v6, :cond_c

    .line 213
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    aget-char v9, p2, v9

    iput-char v9, v2, Lo/addOnPictureInPictureModeChangedListener;->ICustomTabsCallback:C

    .line 214
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    add-int/2addr v9, v8

    aget-char v9, p2, v9

    iput-char v9, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallback:C

    .line 217
    iget-char v9, v2, Lo/addOnPictureInPictureModeChangedListener;->ICustomTabsCallback:C

    iget-char v10, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallback:C

    if-ne v9, v10, :cond_7

    .line 273
    sget v9, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    add-int/lit8 v9, v9, 0x1b

    rem-int/lit16 v10, v9, 0x80

    sput v10, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    rem-int/lit8 v9, v9, 0x2

    if-nez v9, :cond_6

    .line 218
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    iget-char v10, v2, Lo/addOnPictureInPictureModeChangedListener;->ICustomTabsCallback:C

    shl-int v10, v10, p0

    int-to-char v10, v10

    aput-char v10, v4, v9

    .line 219
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    iget-char v10, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallback:C

    sub-int v10, v10, p0

    int-to-char v10, v10

    aput-char v10, v4, v9

    goto :goto_3

    .line 218
    :cond_6
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    iget-char v10, v2, Lo/addOnPictureInPictureModeChangedListener;->ICustomTabsCallback:C

    sub-int v10, v10, p0

    int-to-char v10, v10

    aput-char v10, v4, v9

    .line 219
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    add-int/2addr v9, v8

    iget-char v10, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallback:C

    sub-int v10, v10, p0

    int-to-char v10, v10

    aput-char v10, v4, v9

    :goto_3
    move-object v12, v5

    move v15, v11

    const-wide/16 v10, 0x0

    goto/16 :goto_5

    :cond_7
    const/16 v9, 0xd

    .line 228
    :try_start_2
    new-array v10, v9, [Ljava/lang/Object;

    const/16 v12, 0xc

    aput-object v2, v10, v12

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v12

    const/16 v13, 0xb

    aput-object v12, v10, v13

    const/16 v12, 0xa

    aput-object v2, v10, v12

    const/16 v14, 0x9

    aput-object v2, v10, v14

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v15

    aput-object v15, v10, v11

    const/4 v15, 0x7

    aput-object v2, v10, v15

    const/16 v16, 0x6

    aput-object v2, v10, v16

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v17

    const/16 v18, 0x5

    aput-object v17, v10, v18

    const/16 v17, 0x4

    aput-object v2, v10, v17

    const/16 v22, 0x3

    aput-object v2, v10, v22

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v23

    const/16 v21, 0x2

    aput-object v23, v10, v21

    aput-object v2, v10, v8

    aput-object v2, v10, v7

    const v23, 0x2f81b986

    invoke-static/range {v23 .. v23}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v23

    if-nez v23, :cond_8

    invoke-static {}, Landroid/view/ViewConfiguration;->getLongPressTimeout()I

    move-result v23

    shr-int/lit8 v5, v23, 0x10

    int-to-char v5, v5

    invoke-static {}, Landroid/view/ViewConfiguration;->getDoubleTapTimeout()I

    move-result v23

    shr-int/lit8 v13, v23, 0x10

    add-int/lit16 v13, v13, 0x1d3

    invoke-static {v7, v7}, Landroid/view/View;->getDefaultSize(II)I

    move-result v23

    rsub-int/lit8 v26, v23, 0xe

    const v27, -0x3aa85f96

    const/16 v28, 0x0

    int-to-byte v12, v7

    int-to-byte v14, v12

    add-int/lit8 v11, v14, -0x1

    int-to-byte v11, v11

    invoke-static {v12, v14, v11}, Lnet/pluservice/plusnetworking/PlusNetworking;->$$c(BSI)Ljava/lang/String;

    move-result-object v29

    new-array v9, v9, [Ljava/lang/Class;

    const-class v11, Ljava/lang/Object;

    aput-object v11, v9, v7

    const-class v11, Ljava/lang/Object;

    aput-object v11, v9, v8

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v12, 0x2

    aput-object v11, v9, v12

    const-class v11, Ljava/lang/Object;

    aput-object v11, v9, v22

    const-class v11, Ljava/lang/Object;

    aput-object v11, v9, v17

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v11, v9, v18

    const-class v11, Ljava/lang/Object;

    aput-object v11, v9, v16

    const-class v11, Ljava/lang/Object;

    aput-object v11, v9, v15

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/16 v12, 0x8

    aput-object v11, v9, v12

    const-class v11, Ljava/lang/Object;

    const/16 v12, 0x9

    aput-object v11, v9, v12

    const-class v11, Ljava/lang/Object;

    const/16 v12, 0xa

    aput-object v11, v9, v12

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/16 v12, 0xb

    aput-object v11, v9, v12

    const-class v11, Ljava/lang/Object;

    const/16 v12, 0xc

    aput-object v11, v9, v12

    move/from16 v24, v5

    move/from16 v25, v13

    move-object/from16 v30, v9

    invoke-static/range {v24 .. v30}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v23

    :cond_8
    move-object/from16 v5, v23

    check-cast v5, Ljava/lang/reflect/Method;

    const/4 v9, 0x0

    invoke-virtual {v5, v9, v10}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/Integer;

    invoke-virtual {v5}, Ljava/lang/Integer;->intValue()I

    move-result v5
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onPostMessage:I

    if-ne v5, v9, :cond_a

    const/16 v5, 0xb

    .line 232
    :try_start_3
    new-array v9, v5, [Ljava/lang/Object;

    const/16 v5, 0xa

    aput-object v2, v9, v5

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    const/16 v10, 0x9

    aput-object v5, v9, v10

    const/16 v5, 0x8

    aput-object v2, v9, v5

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    aput-object v5, v9, v15

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    aput-object v5, v9, v16

    aput-object v2, v9, v18

    aput-object v2, v9, v17

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    aput-object v5, v9, v22

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    const/4 v10, 0x2

    aput-object v5, v9, v10

    aput-object v2, v9, v8

    aput-object v2, v9, v7

    const v5, 0x260e1885

    invoke-static {v5}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v5

    if-nez v5, :cond_9

    const-wide/16 v10, 0x0

    invoke-static {v10, v11}, Landroid/widget/ExpandableListView;->getPackedPositionType(J)I

    move-result v5

    int-to-char v5, v5

    invoke-static {}, Landroid/view/ViewConfiguration;->getJumpTapTimeout()I

    move-result v12

    shr-int/lit8 v12, v12, 0x10

    rsub-int v12, v12, 0xdc

    invoke-static {v10, v11}, Landroid/widget/ExpandableListView;->getPackedPositionGroup(J)I

    move-result v13

    add-int/lit8 v26, v13, 0xf

    const v27, -0x3327fe97

    const/16 v28, 0x0

    const-string v29, "v"

    const/16 v13, 0xb

    new-array v13, v13, [Ljava/lang/Class;

    const-class v14, Ljava/lang/Object;

    aput-object v14, v13, v7

    const-class v14, Ljava/lang/Object;

    aput-object v14, v13, v8

    sget-object v14, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/16 v19, 0x2

    aput-object v14, v13, v19

    sget-object v14, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v14, v13, v22

    const-class v14, Ljava/lang/Object;

    aput-object v14, v13, v17

    const-class v14, Ljava/lang/Object;

    aput-object v14, v13, v18

    sget-object v14, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v14, v13, v16

    sget-object v14, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v14, v13, v15

    const-class v14, Ljava/lang/Object;

    const/16 v15, 0x8

    aput-object v14, v13, v15

    sget-object v14, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/16 v16, 0x9

    aput-object v14, v13, v16

    const-class v14, Ljava/lang/Object;

    const/16 v16, 0xa

    aput-object v14, v13, v16

    move/from16 v24, v5

    move/from16 v25, v12

    move-object/from16 v30, v13

    invoke-static/range {v24 .. v30}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v5

    goto :goto_4

    :cond_9
    const-wide/16 v10, 0x0

    const/16 v15, 0x8

    :goto_4
    check-cast v5, Ljava/lang/reflect/Method;

    const/4 v12, 0x0

    invoke-virtual {v5, v12, v9}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/Integer;

    invoke-virtual {v5}, Ljava/lang/Integer;->intValue()I

    move-result v5
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    .line 233
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onNavigationEvent:I

    mul-int/2addr v9, v1

    iget v13, v2, Lo/addOnPictureInPictureModeChangedListener;->onPostMessage:I

    add-int/2addr v9, v13

    .line 235
    iget v13, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    aget-char v5, v3, v5

    aput-char v5, v4, v13

    .line 236
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    add-int/2addr v5, v8

    aget-char v9, v3, v9

    aput-char v9, v4, v5

    goto :goto_5

    :cond_a
    const-wide/16 v10, 0x0

    const/4 v12, 0x0

    const/16 v15, 0x8

    .line 241
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallbackWithResult:I

    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onNavigationEvent:I

    if-ne v5, v9, :cond_b

    .line 273
    sget v5, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    const/16 v9, 0x9

    add-int/2addr v5, v9

    rem-int/lit16 v9, v5, 0x80

    sput v9, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    const/4 v9, 0x2

    rem-int/2addr v5, v9

    .line 242
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->asBinder:I

    add-int/2addr v5, v1

    sub-int/2addr v5, v8

    rem-int/2addr v5, v1

    iput v5, v2, Lo/addOnPictureInPictureModeChangedListener;->asBinder:I

    .line 243
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onPostMessage:I

    add-int/2addr v5, v1

    sub-int/2addr v5, v8

    rem-int/2addr v5, v1

    iput v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onPostMessage:I

    .line 245
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallbackWithResult:I

    mul-int/2addr v5, v1

    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->asBinder:I

    add-int/2addr v5, v9

    .line 246
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onNavigationEvent:I

    mul-int/2addr v9, v1

    iget v13, v2, Lo/addOnPictureInPictureModeChangedListener;->onPostMessage:I

    add-int/2addr v9, v13

    .line 248
    iget v13, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    aget-char v5, v3, v5

    aput-char v5, v4, v13

    .line 249
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    add-int/2addr v5, v8

    aget-char v9, v3, v9

    aput-char v9, v4, v5

    goto :goto_5

    .line 258
    :cond_b
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->extraCallbackWithResult:I

    mul-int/2addr v5, v1

    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onPostMessage:I

    add-int/2addr v5, v9

    .line 259
    iget v9, v2, Lo/addOnPictureInPictureModeChangedListener;->onNavigationEvent:I

    mul-int/2addr v9, v1

    iget v13, v2, Lo/addOnPictureInPictureModeChangedListener;->asBinder:I

    add-int/2addr v9, v13

    .line 261
    iget v13, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    aget-char v5, v3, v5

    aput-char v5, v4, v13

    .line 262
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    add-int/2addr v5, v8

    aget-char v9, v3, v9

    aput-char v9, v4, v5

    .line 210
    :goto_5
    iget v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    const/4 v9, 0x2

    add-int/2addr v5, v9

    iput v5, v2, Lo/addOnPictureInPictureModeChangedListener;->onMessageChannelReady:I

    move-object v5, v12

    move v11, v15

    goto/16 :goto_2

    :cond_c
    move v1, v7

    :goto_6
    if-ge v1, v0, :cond_e

    .line 219
    sget v2, Lnet/pluservice/plusnetworking/PlusNetworking;->$10:I

    add-int/lit8 v2, v2, 0x7b

    rem-int/lit16 v3, v2, 0x80

    sput v3, Lnet/pluservice/plusnetworking/PlusNetworking;->$11:I

    const/4 v3, 0x2

    rem-int/2addr v2, v3

    if-nez v2, :cond_d

    .line 270
    aget-char v2, v4, v1

    xor-int/lit16 v2, v2, 0x5cf0

    int-to-char v2, v2

    aput-char v2, v4, v1

    add-int/lit8 v1, v1, 0x28

    goto :goto_6

    :cond_d
    aget-char v2, v4, v1

    xor-int/lit16 v2, v2, 0x359a

    int-to-char v2, v2

    aput-char v2, v4, v1

    add-int/lit8 v1, v1, 0x1

    goto :goto_6

    .line 273
    :cond_e
    new-instance v0, Ljava/lang/String;

    invoke-direct {v0, v4}, Ljava/lang/String;-><init>([C)V

    aput-object v0, p3, v7

    return-void

    :catchall_1
    move-exception v0

    .line 197
    invoke-virtual {v0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_f

    throw v1

    :cond_f
    throw v0
.end method


# virtual methods
.method public final post(Ljava/lang/String;Lorg/json/JSONObject;Lokhttp3/Callback;)V
    .locals 22

    move-object/from16 v0, p0

    const/4 v1, 0x2

    .line 65350
    rem-int v2, v1, v1

    new-instance v2, Lokhttp3/Request$Builder;

    invoke-direct {v2}, Lokhttp3/Request$Builder;-><init>()V

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v4, Lnet/pluservice/plusnetworking/PlusNetworking$1;->a:[I

    iget-object v5, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->a:Lnet/pluservice/plusnetworking/Ambiente;

    invoke-virtual {v5}, Lnet/pluservice/plusnetworking/Ambiente;->ordinal()I

    move-result v5

    aget v4, v4, v5

    const-wide/16 v5, 0x0

    const-string v7, ""

    const/4 v8, 0x1

    const/4 v9, 0x4

    const/4 v10, 0x0

    if-eq v4, v8, :cond_2

    if-eq v4, v1, :cond_1

    sget v11, Lnet/pluservice/plusnetworking/PlusNetworking;->asBinder:I

    add-int/lit8 v12, v11, 0x63

    rem-int/lit16 v13, v12, 0x80

    sput v13, Lnet/pluservice/plusnetworking/PlusNetworking;->onRelationshipValidationResult:I

    rem-int/2addr v12, v1

    const/4 v12, 0x3

    if-eq v4, v12, :cond_0

    add-int/lit8 v11, v11, 0x77

    rem-int/lit16 v4, v11, 0x80

    sput v4, Lnet/pluservice/plusnetworking/PlusNetworking;->onRelationshipValidationResult:I

    rem-int/2addr v11, v1

    move-object v4, v7

    goto/16 :goto_1

    :cond_0
    invoke-static {v7}, Landroid/os/Process;->getGidForName(Ljava/lang/String;)I

    move-result v4

    rsub-int/lit8 v4, v4, 0xd

    int-to-byte v4, v4

    const/16 v11, 0x30

    invoke-static {v7, v11}, Landroid/text/TextUtils;->lastIndexOf(Ljava/lang/CharSequence;C)I

    move-result v11

    add-int/lit8 v11, v11, 0x33

    const/16 v12, 0x32

    new-array v12, v12, [C

    fill-array-data v12, :array_0

    new-array v13, v8, [Ljava/lang/Object;

    invoke-static {v4, v11, v12, v13}, Lnet/pluservice/plusnetworking/PlusNetworking;->k(BI[C[Ljava/lang/Object;)V

    aget-object v4, v13, v10

    goto :goto_0

    :cond_1
    const/16 v4, 0x35

    new-array v11, v4, [C

    fill-array-data v11, :array_1

    invoke-static {}, Landroid/view/ViewConfiguration;->getZoomControlsTimeout()J

    move-result-wide v12

    cmp-long v4, v12, v5

    const v12, -0x2c9f3a06

    sub-int/2addr v12, v4

    new-array v13, v9, [C

    fill-array-data v13, :array_2

    invoke-static {v10, v10}, Landroid/widget/ExpandableListView;->getPackedPositionForChild(II)J

    move-result-wide v14

    cmp-long v4, v14, v5

    add-int/lit16 v4, v4, 0x4cce

    int-to-char v14, v4

    new-array v15, v9, [C

    fill-array-data v15, :array_3

    new-array v4, v8, [Ljava/lang/Object;

    move-object/from16 v16, v4

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v4, v4, v10

    goto :goto_0

    :cond_2
    const/16 v4, 0x39

    new-array v11, v4, [C

    fill-array-data v11, :array_4

    const v4, -0x12e14465

    invoke-static {v10, v10, v10}, Landroid/graphics/Color;->rgb(III)I

    move-result v12

    add-int/2addr v12, v4

    new-array v13, v9, [C

    fill-array-data v13, :array_5

    const v4, 0x93bb

    invoke-static {v10, v10}, Landroid/graphics/drawable/Drawable;->resolveOpacity(II)I

    move-result v14

    sub-int/2addr v4, v14

    int-to-char v14, v4

    new-array v15, v9, [C

    fill-array-data v15, :array_6

    new-array v4, v8, [Ljava/lang/Object;

    move-object/from16 v16, v4

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v4, v4, v10

    :goto_0
    check-cast v4, Ljava/lang/String;

    invoke-virtual {v4}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v4

    :goto_1
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-object/from16 v4, p1

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v2

    const/4 v3, 0x6

    new-array v11, v3, [C

    fill-array-data v11, :array_7

    invoke-static {}, Landroid/os/Process;->getElapsedCpuTime()J

    move-result-wide v3

    cmp-long v3, v3, v5

    rsub-int/lit8 v12, v3, 0x1

    new-array v13, v9, [C

    fill-array-data v13, :array_8

    invoke-static {v10, v10}, Landroid/view/Gravity;->getAbsoluteGravity(II)I

    move-result v3

    rsub-int v3, v3, 0x72a4

    int-to-char v14, v3

    new-array v15, v9, [C

    fill-array-data v15, :array_9

    new-array v3, v8, [Ljava/lang/Object;

    move-object/from16 v16, v3

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v3, v3, v10

    check-cast v3, Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v3

    iget-object v4, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->c:Ljava/lang/String;

    invoke-virtual {v2, v3, v4}, Lokhttp3/Request$Builder;->header(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v2

    const/16 v3, 0xc

    new-array v11, v3, [C

    fill-array-data v11, :array_a

    invoke-static {v7}, Landroid/view/KeyEvent;->keyCodeFromString(Ljava/lang/String;)I

    move-result v12

    new-array v13, v9, [C

    fill-array-data v13, :array_b

    const/high16 v3, -0x1000000

    invoke-static {v10, v10, v10}, Landroid/graphics/Color;->rgb(III)I

    move-result v4

    sub-int/2addr v3, v4

    int-to-char v14, v3

    new-array v15, v9, [C

    fill-array-data v15, :array_c

    new-array v3, v8, [Ljava/lang/Object;

    move-object/from16 v16, v3

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v3, v3, v10

    check-cast v3, Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v3

    const/16 v4, 0x1f

    new-array v11, v4, [C

    fill-array-data v11, :array_d

    invoke-static {}, Landroid/view/ViewConfiguration;->getScrollFriction()F

    move-result v4

    const/4 v12, 0x0

    cmpl-float v4, v4, v12

    const v12, 0x79fbbbbe

    sub-int/2addr v12, v4

    new-array v13, v9, [C

    fill-array-data v13, :array_e

    invoke-static {}, Landroid/os/Process;->getElapsedCpuTime()J

    move-result-wide v14

    cmp-long v4, v14, v5

    rsub-int v4, v4, 0x739a

    int-to-char v14, v4

    new-array v15, v9, [C

    fill-array-data v15, :array_f

    new-array v4, v8, [Ljava/lang/Object;

    move-object/from16 v16, v4

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v4, v4, v10

    check-cast v4, Ljava/lang/String;

    invoke-virtual {v4}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Lokhttp3/Request$Builder;->header(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v2

    iget-object v3, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->h:Lnet/pluservice/plusnetworking/a/a;

    iget-object v4, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->b:Ljava/lang/String;

    iget-object v11, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->f:Ljava/lang/String;

    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v13

    invoke-virtual {v12, v13, v14}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v12

    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v14, v3, Lnet/pluservice/plusnetworking/a/a;->a:Ljava/lang/String;

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    new-array v15, v8, [C

    const/16 v14, 0x1519

    aput-char v14, v15, v10

    invoke-static {v7, v10}, Landroid/text/TextUtils;->getOffsetAfter(Ljava/lang/CharSequence;I)I

    move-result v16

    const v21, -0x5e35ee07

    add-int v16, v16, v21

    new-array v1, v9, [C

    fill-array-data v1, :array_10

    invoke-static {v10, v10}, Landroid/widget/ExpandableListView;->getPackedPositionForChild(II)J

    move-result-wide v17

    cmp-long v5, v17, v5

    add-int/lit16 v5, v5, 0x314d

    int-to-char v5, v5

    new-array v6, v9, [C

    fill-array-data v6, :array_11

    new-array v9, v8, [Ljava/lang/Object;

    move-object/from16 v17, v1

    move/from16 v18, v5

    move-object/from16 v19, v6

    move-object/from16 v20, v9

    invoke-static/range {v15 .. v20}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v1, v9, v10

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v13, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v13, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    new-array v15, v8, [C

    aput-char v14, v15, v10

    invoke-static {v10, v10}, Landroid/view/View$MeasureSpec;->makeMeasureSpec(II)I

    move-result v1

    add-int v16, v1, v21

    const/4 v1, 0x4

    new-array v5, v1, [C

    fill-array-data v5, :array_12

    invoke-static {v7, v10}, Landroid/text/TextUtils;->getOffsetAfter(Ljava/lang/CharSequence;I)I

    move-result v6

    add-int/lit16 v6, v6, 0x314c

    int-to-char v6, v6

    new-array v9, v1, [C

    fill-array-data v9, :array_13

    new-array v1, v8, [Ljava/lang/Object;

    move-object/from16 v17, v5

    move/from16 v18, v6

    move-object/from16 v19, v9

    move-object/from16 v20, v1

    invoke-static/range {v15 .. v20}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v1, v1, v10

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v13, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v13, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    new-array v15, v8, [C

    aput-char v14, v15, v10

    invoke-static {}, Landroid/view/ViewConfiguration;->getTapTimeout()I

    move-result v1

    shr-int/lit8 v1, v1, 0x10

    sub-int v16, v21, v1

    const/4 v1, 0x4

    new-array v5, v1, [C

    fill-array-data v5, :array_14

    invoke-static {}, Landroid/view/ViewConfiguration;->getJumpTapTimeout()I

    move-result v6

    shr-int/lit8 v6, v6, 0x10

    rsub-int v6, v6, 0x314c

    int-to-char v6, v6

    new-array v9, v1, [C

    fill-array-data v9, :array_15

    new-array v1, v8, [Ljava/lang/Object;

    move-object/from16 v17, v5

    move/from16 v18, v6

    move-object/from16 v19, v9

    move-object/from16 v20, v1

    invoke-static/range {v15 .. v20}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v1, v1, v10

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v13, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v6, v3, Lnet/pluservice/plusnetworking/a/a;->a:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5, v4}, Lnet/pluservice/plusnetworking/a/a;->a(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x4

    new-array v11, v4, [C

    fill-array-data v11, :array_16

    const/16 v5, 0x30

    invoke-static {v7, v5}, Landroid/text/TextUtils;->indexOf(Ljava/lang/CharSequence;C)I

    move-result v5

    add-int/lit8 v12, v5, 0x1

    new-array v13, v4, [C

    fill-array-data v13, :array_17

    const v5, 0xd701

    invoke-static {v7, v7}, Landroid/text/TextUtils;->indexOf(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)I

    move-result v6

    add-int/2addr v6, v5

    int-to-char v14, v6

    new-array v15, v4, [C

    fill-array-data v15, :array_18

    new-array v4, v8, [Ljava/lang/Object;

    move-object/from16 v16, v4

    invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V

    aget-object v4, v4, v10

    check-cast v4, Ljava/lang/String;

    invoke-virtual {v4}, Ljava/lang/String;->intern()Ljava/lang/String;

    move-result-object v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v2, v4, v1}, Lokhttp3/Request$Builder;->header(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v1

    sget-object v2, Lnet/pluservice/plusnetworking/PlusNetworking;->i:Lokhttp3/MediaType;

    invoke-virtual/range {p2 .. p2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lokhttp3/RequestBody;->create(Lokhttp3/MediaType;Ljava/lang/String;)Lokhttp3/RequestBody;

    move-result-object v2

    invoke-virtual {v1, v2}, Lokhttp3/Request$Builder;->post(Lokhttp3/RequestBody;)Lokhttp3/Request$Builder;

    move-result-object v1

    invoke-virtual {v1}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;

    move-result-object v1

    iget-object v2, v0, Lnet/pluservice/plusnetworking/PlusNetworking;->g:Lokhttp3/OkHttpClient;

    invoke-virtual {v2, v1}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object v1

    move-object/from16 v2, p3

    invoke-interface {v1, v2}, Lokhttp3/Call;->enqueue(Lokhttp3/Callback;)V

    sget v1, Lnet/pluservice/plusnetworking/PlusNetworking;->asBinder:I

    add-int/lit8 v1, v1, 0x77

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/plusnetworking/PlusNetworking;->onRelationshipValidationResult:I

    const/4 v2, 0x2

    rem-int/2addr v1, v2

    if-nez v1, :cond_3

    return-void

    :cond_3
    const/4 v1, 0x0

    invoke-virtual {v1}, Ljava/lang/Object;->hashCode()I

    const/4 v1, 0x0

    throw v1

    :array_0
    .array-data 2
        0xfs
        0xds
        0xfs
        0xas
        0x17s
        0x18s
        0x35c3s
        0x35c3s
        0x35fbs
        0x35fbs
        0x15s
        0x1s
        0xfs
        0x10s
        0xes
        0x5s
        0x0s
        0x11s
        0x17s
        0x16s
        0x0s
        0xds
        0x7s
        0x6s
        0xes
        0x6s
        0x5s
        0x3s
        0x17s
        0x1s
        0x13s
        0x7s
        0x13s
        0x7s
        0x7s
        0x6s
        0xes
        0x6s
        0x5s
        0x3s
        0x18s
        0x10s
        0x17s
        0x11s
        0x9s
        0x8s
        0x10s
        0xas
        0xes
        0xas
    .end array-data

    :array_1
    .array-data 2
        -0x4258s
        -0xb36s
        -0x65ds
        0x2b35s
        0x492cs
        0x1af6s
        0x2edcs
        0x5833s
        0x612cs
        0x1690s
        -0x7198s
        0x39b4s
        0x38a3s
        0x4b22s
        -0x1e10s
        -0x381cs
        0x18f1s
        -0x2d6as
        0x7395s
        0x353cs
        0x12cbs
        0x1d79s
        -0x7d8fs
        0x1120s
        0xef8s
        -0x30dfs
        -0x6852s
        -0xcebs
        -0x7df9s
        0x1c9es
        0x46d1s
        -0x6659s
        0x7202s
        0x1cc3s
        0x5705s
        0x9eas
        0x5823s
        -0x383es
        0x3255s
        -0x54b0s
        0x5b02s
        0x78b6s
        -0x15f7s
        -0x75bfs
        0x7437s
        0x6d9cs
        -0x703cs
        0x691fs
        0x1ae5s
        0x8as
        -0x12a6s
        -0x605as
        -0xd1es
    .end array-data

    nop

    :array_2
    .array-data 2
        -0x680s
        0x60c5s
        -0x322ds
        0x734cs
    .end array-data

    :array_3
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_4
    .array-data 2
        -0x3bc0s
        0x5638s
        0x5a70s
        -0xc33s
        -0x17c1s
        -0x73e0s
        0xd6s
        -0x33a1s
        -0x1c43s
        0x311ds
        0x4378s
        0x6ea4s
        -0x3a2bs
        0x6164s
        -0x401bs
        0x6cbas
        -0x274cs
        -0x131bs
        0x39a0s
        -0xa2s
        -0xd5as
        -0x355es
        0x2515s
        0x1b4cs
        -0x20a7s
        -0x4ff2s
        -0x5976s
        0x7ccbs
        0x6c3bs
        -0x6cd2s
        -0x233as
        0x6658s
        -0x5ba4s
        0x469s
        -0x73c1s
        -0x53bas
        -0x2936s
        -0x4ecfs
        -0x3ad8s
        0x2727s
        -0xe2fs
        0x3f4as
        0x27ads
        -0x5047s
        -0x1f24s
        -0x4243s
        0x2bd8s
        -0x68ads
        -0x5f09s
        0x1d8bs
        0x2b5s
        0x7bccs
        0x1d05s
        -0x42bes
        -0x45b1s
        -0x739s
        -0x40cds
    .end array-data

    nop

    :array_5
    .array-data 2
        -0x640fs
        0x1ebbs
        -0x4414s
        0x2593s
    .end array-data

    :array_6
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_7
    .array-data 2
        0x728cs
        -0x70b7s
        -0x6852s
        0x1e8bs
        -0x6556s
        -0x2433s
    .end array-data

    :array_8
    .array-data 2
        0x2ff9s
        0x4aa3s
        -0x5b82s
        -0x308es
    .end array-data

    :array_9
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_a
    .array-data 2
        -0x64efs
        0x376ds
        -0x753es
        -0x2d84s
        0x2eb7s
        0x39fs
        -0x18dcs
        -0x4f04s
        -0x54b1s
        -0x3253s
        -0x35ces
        0x6fc7s
    .end array-data

    :array_b
    .array-data 2
        0x5b46s
        0x4544s
        0x46cas
        0x4b3as
    .end array-data

    :array_c
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_d
    .array-data 2
        -0x5d9fs
        0x13f1s
        -0x3268s
        0x13ecs
        0x528cs
        0x1d3cs
        -0x4297s
        0x5e0ds
        0x6f06s
        0x2c80s
        -0x201es
        -0x15d2s
        -0x7930s
        -0x77ads
        -0x2fbfs
        -0x2fd1s
        -0x5846s
        -0x7686s
        -0x1f83s
        -0x2e2s
        0x6a31s
        0x78e5s
        -0x26d6s
        0x624es
        0x38dds
        0x274fs
        0x3f5fs
        -0x72e7s
        0x66as
        0x7b6bs
        -0x260as
    .end array-data

    nop

    :array_e
    .array-data 2
        -0x42d2s
        -0x445s
        -0x6687s
        0x2273s
    .end array-data

    :array_f
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_10
    .array-data 2
        -0x6c3s
        -0x35efs
        0x4ca1s
        0x2431s
    .end array-data

    :array_11
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_12
    .array-data 2
        -0x6c3s
        -0x35efs
        0x4ca1s
        0x2431s
    .end array-data

    :array_13
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_14
    .array-data 2
        -0x6c3s
        -0x35efs
        0x4ca1s
        0x2431s
    .end array-data

    :array_15
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data

    :array_16
    .array-data 2
        0x4c2s
        -0xed4s
        -0x7fdes
        0x519as
    .end array-data

    :array_17
    .array-data 2
        -0x4a1bs
        0x7573s
        0x12bs
        0x78d7s
    .end array-data

    :array_18
    .array-data 2
        -0x828s
        0x2613s
        0x12a5s
        -0x25fs
    .end array-data
.end method
