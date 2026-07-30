.class public Lnet/pluservice/tua/MainActivity;
.super Lorg/apache/cordova/CordovaActivity;
.source ""


# static fields
.field private static final $$a:[B

.field private static final $$b:I

.field private static final $$c:[B

.field private static final $$f:I

.field private static final $$g:[B

.field private static final $$h:I

.field private static $10:I

.field private static $11:I

.field private static ICustomTabsCallback:C

.field private static ICustomTabsCallbackStub:I

.field private static extraCallback:C

.field private static extraCallbackWithResult:I

.field private static onMessageChannelReady:C

.field private static onNavigationEvent:C


# direct methods
.method private static $$i(ISB)Ljava/lang/String;
    .locals 6

    mul-int/lit8 p1, p1, 0x2

    rsub-int/lit8 v0, p1, 0x1

    mul-int/lit8 p2, p2, 0x2

    add-int/lit8 p2, p2, 0x7a

    mul-int/lit8 p0, p0, 0x3

    rsub-int/lit8 p0, p0, 0x3

    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$c:[B

    new-array v0, v0, [B

    const/4 v2, 0x0

    rsub-int/lit8 p1, p1, 0x0

    if-nez v1, :cond_0

    move v4, p2

    move v3, v2

    move p2, p0

    goto :goto_1

    :cond_0
    move v3, v2

    :goto_0
    add-int/lit8 p0, p0, 0x1

    int-to-byte v4, p2

    aput-byte v4, v0, v3

    if-ne v3, p1, :cond_1

    new-instance p0, Ljava/lang/String;

    invoke-direct {p0, v0, v2}, Ljava/lang/String;-><init>([BI)V

    return-object p0

    :cond_1
    add-int/lit8 v3, v3, 0x1

    aget-byte v4, v1, p0

    move v5, p2

    move p2, p0

    move p0, v5

    :goto_1
    add-int/2addr p0, v4

    move v5, p2

    move p2, p0

    move p0, v5

    goto :goto_0
.end method

.method static constructor <clinit>()V
    .locals 3

    const/4 v0, 0x4

    new-array v0, v0, [B

    fill-array-data v0, :array_0

    sput-object v0, Lnet/pluservice/tua/MainActivity;->$$c:[B

    const/16 v0, 0x20

    sput v0, Lnet/pluservice/tua/MainActivity;->$$f:I

    const/4 v0, 0x0

    sput v0, Lnet/pluservice/tua/MainActivity;->$10:I

    const/4 v1, 0x1

    sput v1, Lnet/pluservice/tua/MainActivity;->$11:I

    const/16 v2, 0x67

    new-array v2, v2, [B

    fill-array-data v2, :array_1

    sput-object v2, Lnet/pluservice/tua/MainActivity;->$$g:[B

    const/4 v2, 0x7

    sput v2, Lnet/pluservice/tua/MainActivity;->$$h:I

    const/16 v2, 0x50

    new-array v2, v2, [B

    fill-array-data v2, :array_2

    sput-object v2, Lnet/pluservice/tua/MainActivity;->$$a:[B

    const/16 v2, 0x7f

    sput v2, Lnet/pluservice/tua/MainActivity;->$$b:I

    .line 65351
    sput v0, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    sput v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    const/16 v0, 0x6f4e

    sput-char v0, Lnet/pluservice/tua/MainActivity;->onNavigationEvent:C

    const/16 v0, 0x1f89

    sput-char v0, Lnet/pluservice/tua/MainActivity;->extraCallback:C

    const v0, 0xc7cc

    sput-char v0, Lnet/pluservice/tua/MainActivity;->onMessageChannelReady:C

    const v0, 0xecea

    sput-char v0, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallback:C

    return-void

    :array_0
    .array-data 1
        0xbt
        0x54t
        -0x60t
        0x2ft
    .end array-data

    :array_1
    .array-data 1
        0x67t
        0x5t
        0x4at
        0x16t
        -0x7t
        0x11t
        -0x44t
        0x44t
        -0x2t
        0xbt
        0x0t
        -0xct
        0xft
        0x6t
        -0xbt
        -0x4t
        0x4t
        -0x35t
        0x44t
        -0x2t
        0xbt
        0x0t
        -0x3t
        -0x7t
        0x11t
        0x5t
        -0x6t
        0x5t
        -0x5t
        0x0t
        0x7t
        -0x5t
        -0x37t
        0x26t
        -0x2ct
        0x3ft
        0xft
        -0x3t
        0x6t
        0x1t
        -0x1et
        0x15t
        0x17t
        -0xbt
        0x0t
        -0x4t
        0x15t
        -0x9t
        0x8t
        0x1t
        -0x27t
        0x33t
        -0xft
        0xbt
        0x8t
        0xet
        0x0t
        -0x3dt
        0x3bt
        0xat
        0x2t
        -0x6t
        0x7t
        -0x5t
        -0x35t
        0x35t
        0xft
        -0x8t
        0x10t
        -0x1t
        -0x4t
        -0x3t
        -0x34t
        0x3bt
        0x8t
        0x8t
        -0x43t
        0x37t
        0xet
        0x0t
        0x2t
        0x4t
        0x1t
        -0x3et
        0x35t
        0x11t
        -0x5t
        -0x39t
        0x3dt
        0x7t
        0x8t
        -0xdt
        0xft
        -0x2t
        -0xbt
        0xdt
        -0x3ct
        0x15t
        0x31t
        -0x5t
        -0x1ct
        0x1ct
        0x16t
    .end array-data

    :array_2
    .array-data 1
        0x20t
        -0x2dt
        -0x6at
        0x6at
        -0x2t
        -0x22t
        0x17t
        0xdt
        -0x1t
        -0x13t
        0x5t
        -0x3t
        -0x23t
        0x24t
        -0x8t
        0xct
        -0x1t
        -0xat
        0x6t
        -0x1bt
        0x12t
        -0x5t
        0x2t
        0x14t
        -0x2t
        -0x21t
        0x12t
        0x14t
        -0xet
        -0x3t
        -0x7t
        0x12t
        -0xct
        0x5t
        -0x2t
        -0x2at
        0x30t
        -0x12t
        0x8t
        0x5t
        0x12t
        -0x5t
        -0x3t
        -0x12t
        -0x1ft
        0x1dt
        0xat
        -0x1t
        -0xbt
        -0x2t
        0x1t
        0x7t
        -0x15t
        0x11t
        0xat
        -0xdt
        -0x17t
        0x12t
        0xdt
        0x1t
        -0xat
        0x7t
        -0x7t
        0x31t
        -0x3t
        0x0t
        -0x6t
        -0x3t
        -0x1at
        0xct
        0x0t
        0x10t
        -0x31t
        0x1dt
        0xat
        -0x1t
        -0xbt
        -0x2t
        0x1t
        0x7t
    .end array-data
.end method

.method public constructor <init>()V
    .locals 0

    .line 26
    invoke-direct {p0}, Lorg/apache/cordova/CordovaActivity;-><init>()V

    return-void
.end method

.method private static a(BBI[Ljava/lang/Object;)V
    .locals 6

    mul-int/lit8 p2, p2, 0x2

    rsub-int/lit8 p2, p2, 0x3d

    mul-int/lit8 p0, p0, 0x2

    add-int/lit8 p0, p0, 0x49

    .line 0
    sget-object v0, Lnet/pluservice/tua/MainActivity;->$$a:[B

    mul-int/lit8 p1, p1, 0x2

    rsub-int/lit8 v1, p1, 0x17

    new-array v1, v1, [B

    rsub-int/lit8 p1, p1, 0x16

    const/4 v2, 0x0

    if-nez v0, :cond_0

    move v3, p2

    move v4, v2

    goto :goto_1

    :cond_0
    move v3, v2

    :goto_0
    int-to-byte v4, p0

    aput-byte v4, v1, v3

    add-int/lit8 p2, p2, 0x1

    add-int/lit8 v4, v3, 0x1

    if-ne v3, p1, :cond_1

    new-instance p0, Ljava/lang/String;

    invoke-direct {p0, v1, v2}, Ljava/lang/String;-><init>([BI)V

    aput-object p0, p3, v2

    return-void

    :cond_1
    aget-byte v3, v0, p2

    move v5, v3

    move v3, p2

    move p2, v5

    :goto_1
    add-int/2addr p0, p2

    add-int/lit8 p0, p0, 0x1

    move p2, v3

    move v3, v4

    goto :goto_0
.end method

.method private static b(I[C[Ljava/lang/Object;)V
    .locals 28

    move-object/from16 v0, p1

    const/4 v1, 0x2

    .line 111
    rem-int v2, v1, v1

    .line 82
    new-instance v2, Lo/addOnTrimMemoryListener;

    invoke-direct {v2}, Lo/addOnTrimMemoryListener;-><init>()V

    .line 84
    array-length v3, v0

    new-array v3, v3, [C

    const/4 v4, 0x0

    .line 86
    iput v4, v2, Lo/addOnTrimMemoryListener;->extraCallback:I

    .line 87
    new-array v5, v1, [C

    .line 88
    :goto_0
    iget v6, v2, Lo/addOnTrimMemoryListener;->extraCallback:I

    array-length v7, v0

    if-ge v6, v7, :cond_5

    .line 111
    sget v6, Lnet/pluservice/tua/MainActivity;->$10:I

    add-int/lit8 v6, v6, 0x19

    rem-int/lit16 v7, v6, 0x80

    sput v7, Lnet/pluservice/tua/MainActivity;->$11:I

    rem-int/2addr v6, v1

    .line 89
    iget v6, v2, Lo/addOnTrimMemoryListener;->extraCallback:I

    aget-char v6, v0, v6

    aput-char v6, v5, v4

    .line 90
    iget v6, v2, Lo/addOnTrimMemoryListener;->extraCallback:I

    const/4 v7, 0x1

    add-int/2addr v6, v7

    aget-char v6, v0, v6

    aput-char v6, v5, v7

    .line 111
    sget v6, Lnet/pluservice/tua/MainActivity;->$11:I

    add-int/lit8 v6, v6, 0x13

    rem-int/lit16 v8, v6, 0x80

    sput v8, Lnet/pluservice/tua/MainActivity;->$10:I

    rem-int/2addr v6, v1

    const v6, 0xe370

    move v8, v4

    .line 93
    :goto_1
    const-string v10, ""

    const/16 v12, 0x10

    if-ge v8, v12, :cond_2

    .line 94
    aget-char v13, v5, v7

    aget-char v14, v5, v4

    add-int v15, v14, v6

    shl-int/lit8 v16, v14, 0x4

    sget-char v11, Lnet/pluservice/tua/MainActivity;->onMessageChannelReady:C

    move-object/from16 v17, v10

    int-to-long v9, v11

    const-wide v18, -0x40186129eeadba6eL    # -0.7381391847904288

    xor-long v9, v9, v18

    long-to-int v9, v9

    int-to-char v9, v9

    add-int v16, v16, v9

    xor-int v9, v15, v16

    ushr-int/lit8 v10, v14, 0x5

    sget-char v11, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallback:C

    const/4 v14, 0x4

    :try_start_0
    new-array v15, v14, [Ljava/lang/Object;

    invoke-static {v11}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v11

    const/16 v16, 0x3

    aput-object v11, v15, v16

    invoke-static {v10}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v10

    aput-object v10, v15, v1

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v15, v7

    invoke-static {v13}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v15, v4

    const v9, 0x55d7ee10

    invoke-static {v9}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v10

    if-nez v10, :cond_0

    move-object/from16 v13, v17

    const/16 v11, 0x30

    invoke-static {v13, v11}, Landroid/text/TextUtils;->lastIndexOf(Ljava/lang/CharSequence;C)I

    move-result v10

    add-int/lit16 v10, v10, 0xa9c

    int-to-char v10, v10

    invoke-static {v4}, Landroid/graphics/Color;->alpha(I)I

    move-result v11

    rsub-int v11, v11, 0x581

    invoke-static {}, Landroid/view/ViewConfiguration;->getFadingEdgeLength()I

    move-result v13

    shr-int/2addr v13, v12

    rsub-int/lit8 v22, v13, 0xe

    const v23, -0x40fe0804

    const/16 v24, 0x0

    int-to-byte v13, v4

    int-to-byte v12, v13

    int-to-byte v9, v12

    invoke-static {v13, v12, v9}, Lnet/pluservice/tua/MainActivity;->$$i(ISB)Ljava/lang/String;

    move-result-object v25

    new-array v9, v14, [Ljava/lang/Class;

    sget-object v12, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v12, v9, v4

    sget-object v12, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v12, v9, v7

    sget-object v12, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v12, v9, v1

    sget-object v12, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v12, v9, v16

    move/from16 v20, v10

    move/from16 v21, v11

    move-object/from16 v26, v9

    invoke-static/range {v20 .. v26}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v10

    :cond_0
    check-cast v10, Ljava/lang/reflect/Method;

    const/4 v9, 0x0

    invoke-virtual {v10, v9, v15}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/lang/Character;

    invoke-virtual {v10}, Ljava/lang/Character;->charValue()C

    move-result v9
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    aput-char v9, v5, v7

    .line 98
    aget-char v10, v5, v4

    add-int v11, v9, v6

    shl-int/lit8 v12, v9, 0x4

    sget-char v13, Lnet/pluservice/tua/MainActivity;->onNavigationEvent:C

    move-object/from16 v20, v5

    int-to-long v4, v13

    xor-long v4, v4, v18

    long-to-int v4, v4

    int-to-char v4, v4

    add-int/2addr v12, v4

    xor-int v4, v11, v12

    ushr-int/lit8 v5, v9, 0x5

    sget-char v9, Lnet/pluservice/tua/MainActivity;->extraCallback:C

    :try_start_1
    new-array v11, v14, [Ljava/lang/Object;

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v11, v16

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    aput-object v5, v11, v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    aput-object v4, v11, v7

    invoke-static {v10}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    const/4 v5, 0x0

    aput-object v4, v11, v5

    const v4, 0x55d7ee10

    invoke-static {v4}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v4

    if-nez v4, :cond_1

    const-wide/16 v4, 0x0

    invoke-static {v4, v5}, Landroid/widget/ExpandableListView;->getPackedPositionType(J)I

    move-result v4

    add-int/lit16 v4, v4, 0xa9b

    int-to-char v4, v4

    invoke-static {}, Landroid/view/ViewConfiguration;->getJumpTapTimeout()I

    move-result v5

    const/16 v9, 0x10

    shr-int/2addr v5, v9

    rsub-int v5, v5, 0x581

    const/4 v9, 0x0

    invoke-static {v9}, Landroid/graphics/Color;->alpha(I)I

    move-result v10

    add-int/lit8 v23, v10, 0xe

    const v24, -0x40fe0804

    const/16 v25, 0x0

    int-to-byte v10, v9

    int-to-byte v12, v10

    int-to-byte v13, v12

    invoke-static {v10, v12, v13}, Lnet/pluservice/tua/MainActivity;->$$i(ISB)Ljava/lang/String;

    move-result-object v26

    new-array v10, v14, [Ljava/lang/Class;

    sget-object v12, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v12, v10, v9

    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v9, v10, v7

    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v9, v10, v1

    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v9, v10, v16

    move/from16 v21, v4

    move/from16 v22, v5

    move-object/from16 v27, v10

    invoke-static/range {v21 .. v27}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v4

    :cond_1
    check-cast v4, Ljava/lang/reflect/Method;

    const/4 v5, 0x0

    invoke-virtual {v4, v5, v11}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Character;

    invoke-virtual {v4}, Ljava/lang/Character;->charValue()C

    move-result v4
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    const/4 v5, 0x0

    aput-char v4, v20, v5

    const v4, 0x9e37

    sub-int/2addr v6, v4

    add-int/lit8 v8, v8, 0x1

    .line 111
    sget v4, Lnet/pluservice/tua/MainActivity;->$11:I

    add-int/lit8 v4, v4, 0x21

    rem-int/lit16 v5, v4, 0x80

    sput v5, Lnet/pluservice/tua/MainActivity;->$10:I

    rem-int/2addr v4, v1

    move-object/from16 v5, v20

    const/4 v4, 0x0

    goto/16 :goto_1

    :catchall_0
    move-exception v0

    goto :goto_2

    :cond_2
    move-object/from16 v20, v5

    move-object v13, v10

    .line 105
    iget v4, v2, Lo/addOnTrimMemoryListener;->extraCallback:I

    const/4 v5, 0x0

    aget-char v6, v20, v5

    aput-char v6, v3, v4

    .line 106
    iget v4, v2, Lo/addOnTrimMemoryListener;->extraCallback:I

    add-int/2addr v4, v7

    aget-char v5, v20, v7

    aput-char v5, v3, v4

    .line 107
    :try_start_2
    filled-new-array {v2, v2}, [Ljava/lang/Object;

    move-result-object v4

    const v5, -0x34449ecb    # -2.4560234E7f

    invoke-static {v5}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v5

    if-nez v5, :cond_3

    const/4 v6, 0x0

    invoke-static {v6}, Landroid/graphics/Color;->red(I)I

    move-result v5

    const v6, 0x89a1

    add-int/2addr v5, v6

    int-to-char v5, v5

    invoke-static {}, Landroid/view/ViewConfiguration;->getScrollBarSize()I

    move-result v6

    shr-int/lit8 v6, v6, 0x8

    rsub-int v6, v6, 0x176

    const/16 v8, 0x30

    invoke-static {v13, v8}, Landroid/text/TextUtils;->lastIndexOf(Ljava/lang/CharSequence;C)I

    move-result v8

    add-int/lit8 v23, v8, 0x1d

    const v24, 0x216d78d9

    const/16 v25, 0x0

    const-string v26, "C"

    new-array v8, v1, [Ljava/lang/Class;

    const-class v9, Ljava/lang/Object;

    const/4 v10, 0x0

    aput-object v9, v8, v10

    const-class v9, Ljava/lang/Object;

    aput-object v9, v8, v7

    move/from16 v21, v5

    move/from16 v22, v6

    move-object/from16 v27, v8

    invoke-static/range {v21 .. v27}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v5

    :cond_3
    check-cast v5, Ljava/lang/reflect/Method;

    const/4 v6, 0x0

    invoke-virtual {v5, v6, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-object/from16 v5, v20

    const/4 v4, 0x0

    goto/16 :goto_0

    .line 94
    :goto_2
    invoke-virtual {v0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_4

    throw v1

    :cond_4
    throw v0

    .line 111
    :cond_5
    new-instance v0, Ljava/lang/String;

    const/4 v4, 0x0

    move/from16 v2, p0

    invoke-direct {v0, v3, v4, v2}, Ljava/lang/String;-><init>([CII)V

    sget v2, Lnet/pluservice/tua/MainActivity;->$11:I

    add-int/lit8 v2, v2, 0x3b

    rem-int/lit16 v3, v2, 0x80

    sput v3, Lnet/pluservice/tua/MainActivity;->$10:I

    rem-int/2addr v2, v1

    aput-object v0, p2, v4

    return-void
.end method

.method private static c(SSS[Ljava/lang/Object;)V
    .locals 5

    rsub-int/lit8 p1, p1, 0x36

    add-int/lit8 p2, p2, 0x63

    rsub-int/lit8 v0, p0, 0x31

    .line 0
    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$g:[B

    new-array v0, v0, [B

    rsub-int/lit8 p0, p0, 0x30

    const/4 v2, -0x1

    if-nez v1, :cond_0

    move v3, v2

    move v2, p2

    move p2, p1

    goto :goto_1

    :cond_0
    :goto_0
    add-int/lit8 p1, p1, 0x1

    add-int/lit8 v2, v2, 0x1

    int-to-byte v3, p2

    aput-byte v3, v0, v2

    if-ne v2, p0, :cond_1

    new-instance p0, Ljava/lang/String;

    const/4 p1, 0x0

    invoke-direct {p0, v0, p1}, Ljava/lang/String;-><init>([BI)V

    aput-object p0, p3, p1

    return-void

    :cond_1
    aget-byte v3, v1, p1

    move v4, p2

    move p2, p1

    move p1, v3

    move v3, v2

    move v2, v4

    :goto_1
    add-int/2addr v2, p1

    add-int/lit8 p1, v2, -0x2

    move v2, v3

    move v4, p2

    move p2, p1

    move p1, v4

    goto :goto_0
.end method


# virtual methods
.method public attachBaseContext(Landroid/content/Context;)V
    .locals 26

    const/4 v0, 0x2

    .line 361
    rem-int v1, v0, v0

    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v1, v1, 0x23

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    rem-int/2addr v1, v0

    const v2, 0xb7c8

    const-string v3, ""

    const/16 v4, 0x9

    const/16 v5, 0x10

    const/4 v6, 0x0

    const/4 v7, 0x1

    const/4 v8, 0x0

    if-nez v1, :cond_1

    .line 46
    invoke-super/range {p0 .. p1}, Lorg/apache/cordova/CordovaActivity;->attachBaseContext(Landroid/content/Context;)V

    const v0, 0x2f51eb39

    .line 50
    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_0

    invoke-static {}, Landroid/view/ViewConfiguration;->getMaximumFlingVelocity()I

    move-result v0

    shr-int/2addr v0, v5

    add-int/2addr v0, v2

    int-to-char v9, v0

    invoke-static {v3, v8}, Landroid/text/TextUtils;->getOffsetAfter(Ljava/lang/CharSequence;I)I

    move-result v0

    rsub-int v10, v0, 0x338

    invoke-static {v8}, Landroid/graphics/ImageFormat;->getBitsPerPixel(I)I

    move-result v0

    add-int/lit8 v11, v0, 0x2e

    const v12, -0x3a780d2b

    const/4 v13, 0x0

    sget-object v0, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v1, v0, v4

    neg-int v1, v1

    int-to-byte v1, v1

    const/16 v2, 0x32

    aget-byte v2, v0, v2

    int-to-byte v2, v2

    const/16 v3, 0x2d

    aget-byte v0, v0, v3

    int-to-byte v0, v0

    new-array v3, v7, [Ljava/lang/Object;

    invoke-static {v1, v2, v0, v3}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v0, v3, v8

    move-object v14, v0

    check-cast v14, Ljava/lang/String;

    const/4 v15, 0x0

    invoke-static/range {v9 .. v15}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    :cond_0
    check-cast v0, Ljava/lang/reflect/Field;

    invoke-virtual {v0, v6}, Ljava/lang/reflect/Field;->getLong(Ljava/lang/Object;)J

    .line 60
    invoke-virtual {v6}, Ljava/lang/Object;->hashCode()I

    throw v6

    .line 46
    :cond_1
    invoke-super/range {p0 .. p1}, Lorg/apache/cordova/CordovaActivity;->attachBaseContext(Landroid/content/Context;)V

    const v1, 0x2f51eb39

    .line 50
    invoke-static {v1}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_2

    invoke-static {v8}, Landroid/graphics/Color;->red(I)I

    move-result v1

    sub-int v1, v2, v1

    int-to-char v9, v1

    invoke-static {}, Landroid/view/ViewConfiguration;->getScrollBarSize()I

    move-result v1

    shr-int/lit8 v1, v1, 0x8

    add-int/lit16 v10, v1, 0x338

    invoke-static {}, Landroid/os/SystemClock;->currentThreadTimeMillis()J

    move-result-wide v11

    const-wide/16 v13, -0x1

    cmp-long v1, v11, v13

    rsub-int/lit8 v11, v1, 0x2e

    const v12, -0x3a780d2b

    const/4 v13, 0x0

    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v14, v1, v4

    neg-int v14, v14

    int-to-byte v14, v14

    const/16 v15, 0x32

    aget-byte v15, v1, v15

    int-to-byte v15, v15

    const/16 v16, 0x2d

    aget-byte v1, v1, v16

    int-to-byte v1, v1

    new-array v0, v7, [Ljava/lang/Object;

    invoke-static {v14, v15, v1, v0}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v0, v0, v8

    move-object v14, v0

    check-cast v14, Ljava/lang/String;

    const/4 v15, 0x0

    invoke-static/range {v9 .. v15}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    :cond_2
    check-cast v1, Ljava/lang/reflect/Field;

    invoke-virtual {v1, v6}, Ljava/lang/reflect/Field;->getLong(Ljava/lang/Object;)J

    move-result-wide v0

    const-wide/16 v9, -0x1

    cmp-long v9, v0, v9

    const/16 v12, 0x16

    const/4 v13, 0x6

    .line 60
    const-string v14, "currentApplication"

    const-string v15, "android.app.ActivityThread"

    if-eqz v9, :cond_4

    const-wide/16 v17, 0x7ba

    add-long v0, v0, v17

    .line 61
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v9

    new-array v11, v8, [Ljava/lang/Class;

    invoke-virtual {v9, v14, v11}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v9

    move-object v11, v6

    check-cast v11, [Ljava/lang/Object;

    invoke-virtual {v9, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v9

    check-cast v9, Landroid/content/Context;

    invoke-virtual {v9}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v9

    invoke-virtual {v9}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v9

    const v11, 0x7f10007b

    invoke-virtual {v9, v11}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v9, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v9, v8}, Ljava/lang/String;->codePointAt(I)I

    move-result v9

    add-int/lit8 v9, v9, -0x31

    new-array v11, v12, [C

    fill-array-data v11, :array_0

    new-array v12, v7, [Ljava/lang/Object;

    invoke-static {v9, v11, v12}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v9, v12, v8

    check-cast v9, Ljava/lang/String;

    invoke-static {v9}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v9

    invoke-static {v8, v8}, Landroid/view/View;->getDefaultSize(II)I

    move-result v11

    add-int/lit8 v11, v11, 0xf

    new-array v12, v5, [C

    fill-array-data v12, :array_1

    new-array v10, v7, [Ljava/lang/Object;

    invoke-static {v11, v12, v10}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v10, v10, v8

    check-cast v10, Ljava/lang/String;

    .line 66
    new-array v11, v8, [Ljava/lang/Class;

    invoke-virtual {v9, v10, v11}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v9

    .line 73
    new-array v10, v8, [Ljava/lang/Object;

    invoke-virtual {v9, v6, v10}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v9

    check-cast v9, Ljava/lang/Long;

    invoke-virtual {v9}, Ljava/lang/Long;->longValue()J

    move-result-wide v9

    cmp-long v0, v0, v9

    if-ltz v0, :cond_4

    const v0, 0xd70be18

    .line 79
    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_3

    invoke-static {}, Landroid/media/AudioTrack;->getMinVolume()F

    move-result v0

    const/4 v1, 0x0

    cmpl-float v0, v0, v1

    add-int/2addr v0, v2

    int-to-char v0, v0

    invoke-static {}, Landroid/view/KeyEvent;->getMaxKeyCode()I

    move-result v1

    shr-int/2addr v1, v5

    rsub-int v1, v1, 0x338

    invoke-static {v8}, Landroid/os/Process;->getThreadPriority(I)I

    move-result v2

    add-int/lit8 v2, v2, 0x14

    shr-int/2addr v2, v13

    rsub-int/lit8 v21, v2, 0x2d

    const v22, -0x1859580c

    const/16 v23, 0x0

    sget-object v2, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v9, v2, v4

    neg-int v10, v9

    int-to-byte v10, v10

    const/16 v11, 0xb

    aget-byte v2, v2, v11

    neg-int v2, v2

    int-to-byte v2, v2

    neg-int v9, v9

    int-to-byte v9, v9

    new-array v11, v7, [Ljava/lang/Object;

    invoke-static {v10, v2, v9, v11}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v2, v11, v8

    move-object/from16 v24, v2

    check-cast v24, Ljava/lang/String;

    const/16 v25, 0x0

    move/from16 v19, v0

    move/from16 v20, v1

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    :cond_3
    check-cast v0, Ljava/lang/reflect/Field;

    invoke-virtual {v0, v6}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Ljava/lang/Object;

    const/4 v1, 0x4

    new-array v2, v1, [Ljava/lang/Object;

    new-array v1, v7, [I

    aput-object v1, v2, v8

    new-array v9, v7, [I

    aput-object v9, v2, v7

    new-array v9, v7, [I

    const/4 v10, 0x3

    aput-object v9, v2, v10

    .line 91
    aget-object v11, v0, v10

    check-cast v11, [I

    aget v10, v11, v8

    aget-object v11, v0, v8

    check-cast v11, [I

    aget v11, v11, v8

    const/4 v12, 0x2

    aget-object v0, v0, v12

    check-cast v0, [Ljava/lang/String;

    check-cast v9, [I

    aput v10, v9, v8

    check-cast v1, [I

    aput v11, v1, v8

    aput-object v0, v2, v12

    invoke-static/range {p0 .. p0}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v0

    const v1, -0x237483c4

    or-int/2addr v1, v0

    not-int v1, v1

    const v9, 0x207480c3

    or-int/2addr v1, v9

    not-int v9, v0

    const v10, 0x3f76a7fb

    or-int/2addr v9, v10

    not-int v9, v9

    or-int/2addr v1, v9

    mul-int/lit16 v1, v1, -0x1d6

    const v10, -0xa307140

    add-int/2addr v10, v1

    const v1, -0x3000301

    or-int/2addr v0, v1

    not-int v0, v0

    or-int/2addr v0, v9

    mul-int/lit16 v0, v0, 0x1d6

    add-int/2addr v10, v0

    const v0, -0x23a52826

    add-int/2addr v10, v0

    shl-int/lit8 v0, v10, 0xd

    xor-int/2addr v0, v10

    ushr-int/lit8 v1, v0, 0x11

    xor-int/2addr v0, v1

    shl-int/lit8 v1, v0, 0x5

    xor-int/2addr v0, v1

    aget-object v1, v2, v7

    check-cast v1, [I

    aput v0, v1, v8

    goto/16 :goto_0

    .line 94
    :cond_4
    invoke-static {}, Landroid/view/KeyEvent;->getModifierMetaStateMask()I

    move-result v0

    int-to-byte v0, v0

    add-int/lit8 v0, v0, 0x11

    new-array v1, v5, [C

    fill-array-data v1, :array_2

    new-array v9, v7, [Ljava/lang/Object;

    invoke-static {v0, v1, v9}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v0, v9, v8

    check-cast v0, Ljava/lang/String;

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    new-array v9, v8, [Ljava/lang/Class;

    invoke-virtual {v1, v14, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    move-object v9, v6

    check-cast v9, [Ljava/lang/Object;

    invoke-virtual {v1, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    const v9, 0x7f10007b

    invoke-virtual {v1, v9}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    const/4 v9, 0x3

    invoke-virtual {v1, v9}, Ljava/lang/String;->codePointAt(I)I

    move-result v1

    add-int/lit8 v1, v1, -0x57

    new-array v9, v5, [C

    fill-array-data v9, :array_3

    new-array v10, v7, [Ljava/lang/Object;

    invoke-static {v1, v9, v10}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v1, v10, v8

    check-cast v1, Ljava/lang/String;

    .line 99
    const-class v9, Ljava/lang/Object;

    filled-new-array {v9}, [Ljava/lang/Class;

    move-result-object v9

    invoke-virtual {v0, v1, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    .line 113
    filled-new-array/range {p0 .. p0}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v0, v6, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/4 v1, 0x3

    .line 115
    :try_start_0
    new-array v9, v1, [Ljava/lang/Object;

    const v1, -0x23a52826

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v10, 0x2

    aput-object v1, v9, v10

    invoke-static {v8}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    aput-object v1, v9, v7

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    aput-object v0, v9, v8

    const v0, -0x7a09abb3

    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_5

    invoke-static {v8, v8}, Landroid/view/View;->resolveSize(II)I

    move-result v0

    add-int/2addr v0, v2

    int-to-char v0, v0

    invoke-static {}, Landroid/view/ViewConfiguration;->getFadingEdgeLength()I

    move-result v1

    shr-int/2addr v1, v5

    rsub-int v1, v1, 0x338

    invoke-static {}, Landroid/view/ViewConfiguration;->getGlobalActionKeyTimeout()J

    move-result-wide v10

    const-wide/16 v19, 0x0

    cmp-long v10, v10, v19

    rsub-int/lit8 v21, v10, 0x2e

    const v22, 0x6f204da1

    const/16 v23, 0x0

    sget-object v10, Lnet/pluservice/tua/MainActivity;->$$a:[B

    const/16 v11, 0x1c

    aget-byte v11, v10, v11

    neg-int v11, v11

    int-to-byte v11, v11

    const/16 v12, 0x41

    aget-byte v12, v10, v12

    int-to-byte v12, v12

    const/16 v19, 0x30

    aget-byte v10, v10, v19

    neg-int v10, v10

    int-to-byte v10, v10

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v11, v12, v10, v5}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v5, v5, v8

    move-object/from16 v24, v5

    check-cast v24, Ljava/lang/String;

    const/4 v5, 0x3

    new-array v10, v5, [Ljava/lang/Class;

    sget-object v5, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v5, v10, v8

    sget-object v5, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v5, v10, v7

    sget-object v5, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v11, 0x2

    aput-object v5, v10, v11

    move/from16 v19, v0

    move/from16 v20, v1

    move-object/from16 v25, v10

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    :cond_5
    check-cast v0, Ljava/lang/reflect/Method;

    invoke-virtual {v0, v6, v9}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Ljava/lang/Object;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    const v1, 0xd70be18

    invoke-static {v1}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_6

    invoke-static {v8, v8, v8, v8}, Landroid/graphics/Color;->argb(IIII)I

    move-result v1

    add-int/2addr v1, v2

    int-to-char v1, v1

    invoke-static {v8}, Landroid/os/Process;->getThreadPriority(I)I

    move-result v5

    add-int/lit8 v5, v5, 0x14

    shr-int/2addr v5, v13

    rsub-int v5, v5, 0x338

    const/16 v9, 0x30

    invoke-static {v3, v9, v8}, Landroid/text/TextUtils;->lastIndexOf(Ljava/lang/CharSequence;CI)I

    move-result v9

    rsub-int/lit8 v21, v9, 0x2c

    const v22, -0x1859580c

    const/16 v23, 0x0

    sget-object v9, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v10, v9, v4

    neg-int v11, v10

    int-to-byte v11, v11

    const/16 v12, 0xb

    aget-byte v9, v9, v12

    neg-int v9, v9

    int-to-byte v9, v9

    neg-int v10, v10

    int-to-byte v10, v10

    new-array v12, v7, [Ljava/lang/Object;

    invoke-static {v11, v9, v10, v12}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v9, v12, v8

    move-object/from16 v24, v9

    check-cast v24, Ljava/lang/String;

    const/16 v25, 0x0

    move/from16 v19, v1

    move/from16 v20, v5

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    :cond_6
    check-cast v1, Ljava/lang/reflect/Field;

    invoke-virtual {v1, v6, v0}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    :try_start_1
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    new-array v5, v8, [Ljava/lang/Class;

    invoke-virtual {v1, v14, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    move-object v5, v6

    check-cast v5, [Ljava/lang/Object;

    invoke-virtual {v1, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    const v5, 0x7f100096

    invoke-virtual {v1, v5}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, v8}, Ljava/lang/String;->codePointAt(I)I

    move-result v1

    add-int/lit8 v1, v1, -0x3a

    const/16 v5, 0x16

    new-array v9, v5, [C

    fill-array-data v9, :array_4

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v1, v9, v5}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v1, v5, v8

    check-cast v1, Ljava/lang/String;

    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    .line 124
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v5

    new-array v9, v8, [Ljava/lang/Class;

    invoke-virtual {v5, v14, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v5

    move-object v9, v6

    check-cast v9, [Ljava/lang/Object;

    invoke-virtual {v5, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Landroid/content/Context;

    invoke-virtual {v5}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v5

    iget v5, v5, Landroid/content/pm/ApplicationInfo;->targetSdkVersion:I

    add-int/lit8 v5, v5, -0x14

    const/16 v9, 0x10

    new-array v10, v9, [C

    fill-array-data v10, :array_5

    new-array v9, v7, [Ljava/lang/Object;

    invoke-static {v5, v10, v9}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v5, v9, v8

    check-cast v5, Ljava/lang/String;

    new-array v9, v8, [Ljava/lang/Class;

    invoke-virtual {v1, v5, v9}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    .line 128
    new-array v5, v8, [Ljava/lang/Object;

    .line 137
    invoke-virtual {v1, v6, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Long;

    invoke-virtual {v1}, Ljava/lang/Long;->longValue()J

    move-result-wide v9
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    invoke-static {v9, v10}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const v5, 0x2f51eb39

    invoke-static {v5}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v5

    if-nez v5, :cond_7

    invoke-static {}, Landroid/view/ViewConfiguration;->getPressedStateDuration()I

    move-result v5

    const/16 v9, 0x10

    shr-int/2addr v5, v9

    add-int/2addr v5, v2

    int-to-char v2, v5

    const-wide/16 v9, 0x0

    invoke-static {v9, v10}, Landroid/widget/ExpandableListView;->getPackedPositionChild(J)I

    move-result v5

    add-int/lit16 v5, v5, 0x339

    invoke-static {v8, v8}, Landroid/view/Gravity;->getAbsoluteGravity(II)I

    move-result v9

    rsub-int/lit8 v21, v9, 0x2d

    const v22, -0x3a780d2b

    const/16 v23, 0x0

    sget-object v9, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v10, v9, v4

    neg-int v10, v10

    int-to-byte v10, v10

    const/16 v11, 0x32

    aget-byte v11, v9, v11

    int-to-byte v11, v11

    const/16 v12, 0x2d

    aget-byte v9, v9, v12

    int-to-byte v9, v9

    new-array v12, v7, [Ljava/lang/Object;

    invoke-static {v10, v11, v9, v12}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v9, v12, v8

    move-object/from16 v24, v9

    check-cast v24, Ljava/lang/String;

    const/16 v25, 0x0

    move/from16 v19, v2

    move/from16 v20, v5

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v5

    :cond_7
    check-cast v5, Ljava/lang/reflect/Field;

    invoke-virtual {v5, v6, v1}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    move-object v2, v0

    .line 146
    :goto_0
    aget-object v0, v2, v8

    check-cast v0, [I

    aget v0, v0, v8

    const/4 v1, 0x3

    .line 153
    aget-object v5, v2, v1

    check-cast v5, [I

    aget v1, v5, v8

    if-ne v1, v0, :cond_8

    .line 361
    sget v0, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v0, v0, 0x55

    rem-int/lit16 v1, v0, 0x80

    sput v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    const/4 v1, 0x2

    rem-int/2addr v0, v1

    const/4 v0, 0x4

    .line 153
    new-array v1, v0, [Ljava/lang/Object;

    new-array v0, v7, [I

    aput-object v0, v1, v8

    new-array v5, v7, [I

    aput-object v5, v1, v7

    new-array v5, v7, [I

    const/4 v9, 0x3

    aput-object v5, v1, v9

    .line 157
    aget-object v10, v2, v7

    check-cast v10, [I

    aget v10, v10, v8

    aget-object v11, v2, v9

    check-cast v11, [I

    aget v9, v11, v8

    aget-object v11, v2, v8

    check-cast v11, [I

    aget v11, v11, v8

    const/4 v12, 0x2

    aget-object v2, v2, v12

    check-cast v2, [Ljava/lang/String;

    check-cast v5, [I

    aput v9, v5, v8

    check-cast v0, [I

    aput v11, v0, v8

    aput-object v2, v1, v12

    invoke-static/range {p0 .. p0}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v0

    const v2, -0x3cacc957

    or-int v5, v2, v0

    not-int v5, v5

    const v9, 0x1c808016

    or-int/2addr v5, v9

    const v9, 0x233e5f68

    or-int/2addr v9, v0

    not-int v9, v9

    or-int/2addr v5, v9

    mul-int/lit16 v5, v5, -0x2f2

    const v9, 0x471f27ba

    add-int/2addr v9, v5

    const v5, -0x1c808017

    or-int/2addr v5, v0

    not-int v5, v5

    not-int v0, v0

    const v11, 0x3fbedf7e

    or-int/2addr v11, v0

    not-int v11, v11

    or-int/2addr v5, v11

    mul-int/lit16 v5, v5, -0x2f2

    add-int/2addr v9, v5

    or-int/2addr v0, v2

    mul-int/lit16 v0, v0, 0x2f2

    add-int/2addr v9, v0

    add-int/2addr v10, v9

    shl-int/lit8 v0, v10, 0xd

    xor-int/2addr v0, v10

    ushr-int/lit8 v2, v0, 0x11

    xor-int/2addr v0, v2

    shl-int/lit8 v2, v0, 0x5

    xor-int/2addr v0, v2

    aget-object v1, v1, v7

    check-cast v1, [I

    aput v0, v1, v8

    goto/16 :goto_2

    .line 159
    :cond_8
    new-instance v5, Ljava/util/ArrayList;

    invoke-direct {v5}, Ljava/util/ArrayList;-><init>()V

    const/4 v9, 0x2

    .line 162
    aget-object v10, v2, v9

    check-cast v10, [Ljava/lang/String;

    if-eqz v10, :cond_9

    move v9, v8

    .line 166
    :goto_1
    array-length v11, v10

    if-ge v9, v11, :cond_9

    .line 172
    aget-object v11, v10, v9

    invoke-interface {v5, v11}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    add-int/lit8 v9, v9, 0x1

    goto :goto_1

    :cond_9
    const v5, -0x3632e4d1

    int-to-long v9, v5

    const/16 v5, 0x20

    shl-long/2addr v9, v5

    xor-int/2addr v0, v1

    int-to-long v0, v0

    xor-long/2addr v0, v9

    const v5, -0x3632e4d2

    int-to-long v9, v5

    .line 361
    sget v5, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    add-int/lit8 v5, v5, 0x25

    rem-int/lit16 v11, v5, 0x80

    sput v11, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    const/4 v11, 0x2

    rem-int/2addr v5, v11

    .line 205
    :try_start_2
    new-array v5, v11, [Ljava/lang/Object;

    invoke-static {v9, v10}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v9

    aput-object v9, v5, v7

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    aput-object v0, v5, v8

    sget-object v0, Lnet/pluservice/tua/MainActivity;->$$g:[B

    const/16 v1, 0x5f

    aget-byte v1, v0, v1

    int-to-byte v1, v1

    const/16 v9, 0x33

    aget-byte v9, v0, v9

    int-to-byte v9, v9

    aget-byte v10, v0, v4

    int-to-byte v10, v10

    new-array v11, v7, [Ljava/lang/Object;

    invoke-static {v1, v9, v10, v11}, Lnet/pluservice/tua/MainActivity;->c(SSS[Ljava/lang/Object;)V

    aget-object v1, v11, v8

    check-cast v1, Ljava/lang/String;

    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const/16 v9, 0x20

    int-to-byte v9, v9

    const/16 v10, 0x44

    aget-byte v10, v0, v10

    int-to-byte v10, v10

    const/16 v11, 0xb

    aget-byte v0, v0, v11

    neg-int v0, v0

    int-to-byte v0, v0

    new-array v11, v7, [Ljava/lang/Object;

    invoke-static {v9, v10, v0, v11}, Lnet/pluservice/tua/MainActivity;->c(SSS[Ljava/lang/Object;)V

    aget-object v0, v11, v8

    check-cast v0, Ljava/lang/String;

    const/4 v9, 0x2

    new-array v10, v9, [Ljava/lang/Class;

    sget-object v9, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    aput-object v9, v10, v8

    sget-object v9, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    aput-object v9, v10, v7

    invoke-virtual {v1, v0, v10}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    invoke-virtual {v0, v6, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    const/4 v0, 0x4

    new-array v1, v0, [Ljava/lang/Object;

    new-array v0, v7, [I

    aput-object v0, v1, v8

    new-array v5, v7, [I

    aput-object v5, v1, v7

    new-array v5, v7, [I

    const/4 v9, 0x3

    aput-object v5, v1, v9

    aget-object v10, v2, v7

    check-cast v10, [I

    aget v10, v10, v8

    aget-object v11, v2, v9

    check-cast v11, [I

    aget v9, v11, v8

    aget-object v11, v2, v8

    check-cast v11, [I

    aget v11, v11, v8

    const/16 v12, 0x2

    aget-object v2, v2, v12

    check-cast v2, [Ljava/lang/String;

    check-cast v5, [I

    aput v9, v5, v8

    check-cast v0, [I

    aput v11, v0, v8

    aput-object v2, v1, v8

    invoke-static/range {p0 .. p0}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v0

    const v2, -0x5128c0d6

    or-int/2addr v2, v0

    not-int v2, v2

    not-int v5, v0

    const v9, 0x5feae7fd

    or-int/2addr v9, v5

    not-int v9, v9

    or-int/2addr v2, v9

    mul-int/lit16 v2, v2, -0x196

    const v9, -0x51c3d0fa

    add-int/2addr v9, v2

    const v2, -0x51288015

    or-int/2addr v2, v5

    not-int v2, v2

    mul-int/lit16 v2, v2, -0x196

    add-int/2addr v9, v2

    const v2, -0xec267ea

    or-int/2addr v0, v2

    not-int v0, v0

    const v2, 0x5128c0d5

    or-int/2addr v2, v5

    not-int v2, v2

    or-int/2addr v0, v2

    mul-int/lit16 v0, v0, 0x196

    add-int/2addr v9, v0

    add-int/2addr v10, v9

    shl-int/lit8 v0, v10, 0xd

    xor-int/2addr v0, v10

    ushr-int/lit8 v2, v0, 0x11

    xor-int/2addr v0, v2

    shl-int/lit8 v2, v0, 0x5

    xor-int/2addr v0, v2

    aget-object v1, v1, v7

    check-cast v1, [I

    aput v0, v1, v8

    :goto_2
    const v0, -0x5773b6ff

    .line 211
    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_a

    invoke-static {}, Landroid/view/ViewConfiguration;->getKeyRepeatDelay()I

    move-result v0

    const/16 v1, 0x10

    shr-int/2addr v0, v1

    rsub-int v0, v0, 0x5d15

    int-to-char v0, v0

    invoke-static {v3}, Landroid/os/Process;->getGidForName(Ljava/lang/String;)I

    move-result v2

    rsub-int v2, v2, 0x435

    invoke-static {}, Landroid/view/ViewConfiguration;->getFadingEdgeLength()I

    move-result v5

    shr-int/2addr v5, v1

    add-int/lit8 v21, v5, 0x14

    const v22, 0x425a50ed

    const/16 v23, 0x0

    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v5, v1, v4

    neg-int v9, v5

    int-to-byte v9, v9

    const/16 v10, 0xb

    aget-byte v1, v1, v10

    neg-int v1, v1

    int-to-byte v1, v1

    neg-int v5, v5

    int-to-byte v5, v5

    new-array v10, v7, [Ljava/lang/Object;

    invoke-static {v9, v1, v5, v10}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v1, v10, v8

    move-object/from16 v24, v1

    check-cast v24, Ljava/lang/String;

    const/16 v25, 0x0

    move/from16 v19, v0

    move/from16 v20, v2

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    :cond_a
    check-cast v0, Ljava/lang/reflect/Field;

    invoke-virtual {v0, v6}, Ljava/lang/reflect/Field;->getLong(Ljava/lang/Object;)J

    move-result-wide v0

    const-wide/16 v9, -0x1

    cmp-long v2, v0, v9

    if-eqz v2, :cond_c

    const-wide/16 v9, 0x79c

    add-long/2addr v0, v9

    .line 212
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    new-array v5, v8, [Ljava/lang/Class;

    invoke-virtual {v2, v14, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    move-object v5, v6

    check-cast v5, [Ljava/lang/Object;

    invoke-virtual {v2, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    const v5, 0x7f10007a

    invoke-virtual {v2, v5}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    const/4 v5, 0x4

    invoke-virtual {v2, v5}, Ljava/lang/String;->codePointAt(I)I

    move-result v2

    add-int/lit8 v2, v2, -0x56

    const/16 v5, 0x16

    new-array v9, v5, [C

    fill-array-data v9, :array_6

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v2, v9, v5}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v2, v5, v8

    check-cast v2, Ljava/lang/String;

    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v5

    new-array v9, v8, [Ljava/lang/Class;

    invoke-virtual {v5, v14, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v5

    invoke-virtual {v5, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Landroid/content/Context;

    invoke-virtual {v5}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    const v9, 0x7f10007b

    invoke-virtual {v5, v9}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v5

    add-int/2addr v5, v4

    const/16 v9, 0x10

    new-array v10, v9, [C

    fill-array-data v10, :array_7

    new-array v9, v7, [Ljava/lang/Object;

    invoke-static {v5, v10, v9}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v5, v9, v8

    check-cast v5, Ljava/lang/String;

    new-array v9, v8, [Ljava/lang/Class;

    .line 216
    invoke-virtual {v2, v5, v9}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    .line 218
    new-array v5, v8, [Ljava/lang/Object;

    invoke-virtual {v2, v6, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Long;

    invoke-virtual {v2}, Ljava/lang/Long;->longValue()J

    move-result-wide v9

    cmp-long v0, v0, v9

    if-ltz v0, :cond_c

    .line 60
    sget v0, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v0, v0, 0x3f

    rem-int/lit16 v1, v0, 0x80

    sput v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    const/4 v1, 0x2

    rem-int/2addr v0, v1

    const v0, 0x430d5c57

    .line 227
    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_b

    invoke-static {}, Landroid/view/ViewConfiguration;->getWindowTouchSlop()I

    move-result v0

    shr-int/lit8 v0, v0, 0x8

    add-int/lit16 v0, v0, 0x5d15

    int-to-char v0, v0

    invoke-static {}, Landroid/view/ViewConfiguration;->getScrollBarSize()I

    move-result v1

    shr-int/lit8 v1, v1, 0x8

    add-int/lit16 v1, v1, 0x436

    invoke-static {v8}, Landroid/os/Process;->getThreadPriority(I)I

    move-result v2

    add-int/lit8 v2, v2, 0x14

    shr-int/2addr v2, v13

    rsub-int/lit8 v21, v2, 0x14

    const v22, -0x5624ba45    # -9.73765E-14f

    const/16 v23, 0x0

    sget-object v2, Lnet/pluservice/tua/MainActivity;->$$a:[B

    const/16 v3, 0x41

    aget-byte v3, v2, v3

    int-to-byte v4, v3

    const/16 v5, 0x16

    aget-byte v2, v2, v5

    int-to-byte v2, v2

    int-to-byte v3, v3

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v4, v2, v3, v5}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v2, v5, v8

    move-object/from16 v24, v2

    check-cast v24, Ljava/lang/String;

    const/16 v25, 0x0

    move/from16 v19, v0

    move/from16 v20, v1

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    :cond_b
    check-cast v0, Ljava/lang/reflect/Field;

    invoke-virtual {v0, v6}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Ljava/lang/Object;

    const/4 v1, 0x4

    new-array v2, v1, [Ljava/lang/Object;

    new-array v1, v7, [I

    aput-object v1, v2, v7

    new-array v3, v7, [I

    const/4 v4, 0x2

    aput-object v3, v2, v4

    new-array v3, v7, [I

    const/4 v4, 0x3

    aput-object v3, v2, v4

    .line 233
    aget-object v5, v0, v4

    check-cast v5, [I

    aget v4, v5, v8

    aget-object v5, v0, v7

    check-cast v5, [I

    aget v5, v5, v8

    aget-object v0, v0, v8

    check-cast v0, [Ljava/lang/String;

    check-cast v3, [I

    aput v4, v3, v8

    check-cast v1, [I

    aput v5, v1, v8

    aput-object v0, v2, v8

    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    new-array v1, v8, [Ljava/lang/Class;

    invoke-virtual {v0, v14, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    invoke-virtual {v0, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    const v1, 0x7f10007b

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, v7}, Ljava/lang/String;->codePointAt(I)I

    move-result v0

    const v1, -0x6efbbf02

    add-int/2addr v0, v1

    const v1, -0x6ad1862

    or-int/2addr v1, v0

    not-int v1, v1

    not-int v3, v0

    or-int/lit16 v3, v3, -0x83

    not-int v3, v3

    or-int/2addr v1, v3

    mul-int/lit16 v1, v1, -0x13e

    const v3, 0xe8f16f6

    add-int/2addr v3, v1

    const v1, 0x26bf3f75

    or-int/2addr v1, v0

    not-int v1, v1

    const v4, -0x26bf3ff8

    or-int/2addr v1, v4

    mul-int/lit16 v1, v1, -0x13e

    add-int/2addr v3, v1

    const v1, -0x26bf3f76

    or-int/2addr v0, v1

    not-int v0, v0

    const v1, 0x20122796

    or-int/2addr v0, v1

    mul-int/lit16 v0, v0, 0x13e

    add-int/2addr v3, v0

    const v0, 0x1dc45384

    add-int/2addr v3, v0

    shl-int/lit8 v0, v3, 0xd

    xor-int/2addr v0, v3

    ushr-int/lit8 v1, v0, 0x11

    xor-int/2addr v0, v1

    shl-int/lit8 v1, v0, 0x5

    xor-int/2addr v0, v1

    const/4 v1, 0x2

    aget-object v3, v2, v1

    check-cast v3, [I

    aput v0, v3, v8

    goto/16 :goto_3

    .line 242
    :cond_c
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    new-array v1, v8, [Ljava/lang/Class;

    invoke-virtual {v0, v14, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    move-object v1, v6

    check-cast v1, [Ljava/lang/Object;

    invoke-virtual {v0, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    const v1, 0x7f100096

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x3

    invoke-virtual {v0, v1}, Ljava/lang/String;->codePointAt(I)I

    move-result v0

    add-int/lit8 v0, v0, -0x24

    const/16 v1, 0x10

    new-array v2, v1, [C

    fill-array-data v2, :array_8

    new-array v1, v7, [Ljava/lang/Object;

    invoke-static {v0, v2, v1}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v0, v1, v8

    check-cast v0, Ljava/lang/String;

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    new-array v2, v8, [Ljava/lang/Class;

    invoke-virtual {v1, v14, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    invoke-virtual {v1, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    add-int/lit8 v1, v1, -0x2

    const/16 v2, 0x10

    new-array v5, v2, [C

    fill-array-data v5, :array_9

    new-array v2, v7, [Ljava/lang/Object;

    invoke-static {v1, v5, v2}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v1, v2, v8

    check-cast v1, Ljava/lang/String;

    .line 252
    const-class v2, Ljava/lang/Object;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    .line 262
    filled-new-array/range {p0 .. p0}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v0, v6, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 271
    :try_start_3
    new-array v1, v7, [Ljava/lang/Object;

    const v2, 0x1cb38052

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    aput-object v2, v1, v8

    const v2, 0x74900b7f

    invoke-static {v2}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v2

    if-nez v2, :cond_d

    const/16 v2, 0x30

    invoke-static {v3, v2}, Landroid/text/TextUtils;->indexOf(Ljava/lang/CharSequence;C)I

    move-result v2

    const v5, 0x812a

    add-int/2addr v2, v5

    int-to-char v2, v2

    invoke-static {v3}, Landroid/text/TextUtils;->getTrimmedLength(Ljava/lang/CharSequence;)I

    move-result v5

    rsub-int v5, v5, 0x3fc

    invoke-static {}, Landroid/media/AudioTrack;->getMinVolume()F

    move-result v9

    const/4 v10, 0x0

    cmpl-float v9, v9, v10

    add-int/lit8 v21, v9, 0x3a

    const v22, -0x61b9ed6d

    const/16 v23, 0x0

    const/16 v24, 0x0

    new-array v9, v7, [Ljava/lang/Class;

    sget-object v10, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v10, v9, v8

    move/from16 v19, v2

    move/from16 v20, v5

    move-object/from16 v25, v9

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v2

    :cond_d
    check-cast v2, Ljava/lang/reflect/Constructor;

    invoke-virtual {v2, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    const v2, 0x1dc45384

    .line 281
    invoke-static {v0, v8, v1, v2, v8}, Landroid/support/v4/media/session/MediaControllerCompatApi21$PlaybackInfo;->ICustomTabsCallback$7c28d4e2(IILjava/lang/Object;IZ)[Ljava/lang/Object;

    move-result-object v2

    const v0, 0x430d5c57

    .line 282
    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_e

    const-wide/16 v0, 0x0

    invoke-static {v0, v1}, Landroid/widget/ExpandableListView;->getPackedPositionChild(J)I

    move-result v0

    rsub-int v0, v0, 0x5d14

    int-to-char v0, v0

    invoke-static {}, Landroid/os/Process;->myTid()I

    move-result v1

    const/16 v5, 0x16

    shr-int/2addr v1, v5

    add-int/lit16 v1, v1, 0x436

    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v9

    shr-int/2addr v9, v5

    add-int/lit8 v21, v9, 0x14

    const v22, -0x5624ba45    # -9.73765E-14f

    const/16 v23, 0x0

    sget-object v9, Lnet/pluservice/tua/MainActivity;->$$a:[B

    const/16 v10, 0x41

    aget-byte v10, v9, v10

    int-to-byte v11, v10

    aget-byte v9, v9, v5

    int-to-byte v5, v9

    int-to-byte v9, v10

    new-array v10, v7, [Ljava/lang/Object;

    invoke-static {v11, v5, v9, v10}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v5, v10, v8

    move-object/from16 v24, v5

    check-cast v24, Ljava/lang/String;

    const/16 v25, 0x0

    move/from16 v19, v0

    move/from16 v20, v1

    invoke-static/range {v19 .. v25}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    :cond_e
    check-cast v0, Ljava/lang/reflect/Field;

    invoke-virtual {v0, v6, v2}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    :try_start_4
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    new-array v1, v8, [Ljava/lang/Class;

    invoke-virtual {v0, v14, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    move-object v1, v6

    check-cast v1, [Ljava/lang/Object;

    invoke-virtual {v0, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    const v1, 0x7f10007a

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, v8, v13}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x3

    invoke-virtual {v0, v1}, Ljava/lang/String;->codePointAt(I)I

    move-result v0

    add-int/lit8 v0, v0, -0x51

    const/16 v1, 0x16

    new-array v1, v1, [C

    fill-array-data v1, :array_a

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v0, v1, v5}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v0, v5, v8

    check-cast v0, Ljava/lang/String;

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 283
    invoke-static {v15}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    new-array v5, v8, [Ljava/lang/Class;

    invoke-virtual {v1, v14, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    move-object v5, v6

    check-cast v5, [Ljava/lang/Object;

    invoke-virtual {v1, v6, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v1

    iget v1, v1, Landroid/content/pm/ApplicationInfo;->targetSdkVersion:I

    add-int/lit8 v1, v1, -0x14

    const/16 v5, 0x10

    new-array v5, v5, [C

    fill-array-data v5, :array_b

    new-array v9, v7, [Ljava/lang/Object;

    invoke-static {v1, v5, v9}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V

    aget-object v1, v9, v8

    check-cast v1, Ljava/lang/String;

    new-array v5, v8, [Ljava/lang/Class;

    invoke-virtual {v0, v1, v5}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    .line 285
    new-array v1, v8, [Ljava/lang/Object;

    invoke-virtual {v0, v6, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_0

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    const v1, -0x5773b6ff

    invoke-static {v1}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_f

    invoke-static {}, Landroid/view/ViewConfiguration;->getZoomControlsTimeout()J

    move-result-wide v9

    const-wide/16 v11, 0x0

    cmp-long v1, v9, v11

    rsub-int v1, v1, 0x5d16

    int-to-char v9, v1

    invoke-static {v3, v3, v8}, Landroid/text/TextUtils;->indexOf(Ljava/lang/CharSequence;Ljava/lang/CharSequence;I)I

    move-result v1

    add-int/lit16 v10, v1, 0x436

    const/4 v1, 0x0

    const/4 v3, 0x0

    invoke-static {v1, v3}, Landroid/graphics/PointF;->length(FF)F

    move-result v1

    cmpl-float v1, v1, v3

    add-int/lit8 v11, v1, 0x14

    const v12, 0x425a50ed

    const/4 v13, 0x0

    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$a:[B

    aget-byte v3, v1, v4

    neg-int v4, v3

    int-to-byte v4, v4

    const/16 v5, 0xb

    aget-byte v1, v1, v5

    neg-int v1, v1

    int-to-byte v1, v1

    neg-int v3, v3

    int-to-byte v3, v3

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v4, v1, v3, v5}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V

    aget-object v1, v5, v8

    move-object v14, v1

    check-cast v14, Ljava/lang/String;

    const/4 v15, 0x0

    invoke-static/range {v9 .. v15}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    :cond_f
    check-cast v1, Ljava/lang/reflect/Field;

    invoke-virtual {v1, v6, v0}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 60
    sget v0, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v0, v0, 0x49

    rem-int/lit16 v1, v0, 0x80

    sput v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    const/4 v3, 0x2

    rem-int/2addr v0, v3

    add-int/lit8 v1, v1, 0x53

    rem-int/lit16 v0, v1, 0x80

    sput v0, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    rem-int/2addr v1, v3

    .line 289
    :goto_3
    aget-object v0, v2, v7

    check-cast v0, [I

    aget v0, v0, v8

    const/4 v1, 0x3

    aget-object v3, v2, v1

    check-cast v3, [I

    aget v3, v3, v8

    if-ne v3, v0, :cond_10

    const/4 v4, 0x4

    .line 296
    new-array v0, v4, [Ljava/lang/Object;

    new-array v3, v7, [I

    aput-object v3, v0, v7

    new-array v4, v7, [I

    const/4 v5, 0x2

    aput-object v4, v0, v5

    new-array v4, v7, [I

    aput-object v4, v0, v1

    aget-object v6, v2, v5

    check-cast v6, [I

    aget v5, v6, v8

    aget-object v1, v2, v1

    check-cast v1, [I

    aget v1, v1, v8

    aget-object v6, v2, v7

    check-cast v6, [I

    aget v6, v6, v8

    aget-object v2, v2, v8

    check-cast v2, [Ljava/lang/String;

    check-cast v4, [I

    aput v1, v4, v8

    check-cast v3, [I

    aput v6, v3, v8

    aput-object v2, v0, v8

    invoke-static/range {p0 .. p0}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v1

    const v2, -0x381cca05

    or-int/2addr v2, v1

    not-int v2, v2

    const v3, 0x316fb225

    or-int/2addr v2, v3

    mul-int/lit16 v2, v2, -0x13e

    const v4, 0x232f540a

    add-int/2addr v4, v2

    or-int v2, v3, v1

    not-int v2, v2

    not-int v3, v1

    const v6, -0x1633022

    or-int/2addr v6, v3

    not-int v6, v6

    or-int/2addr v2, v6

    mul-int/lit16 v2, v2, 0x13e

    add-int/2addr v4, v2

    const v2, 0x397ffa25

    or-int/2addr v2, v3

    not-int v2, v2

    const v3, -0x1633022

    or-int/2addr v1, v3

    not-int v1, v1

    or-int/2addr v1, v2

    mul-int/lit16 v1, v1, 0x13e

    add-int/2addr v4, v1

    add-int/2addr v5, v4

    shl-int/lit8 v1, v5, 0xd

    xor-int/2addr v1, v5

    ushr-int/lit8 v2, v1, 0x11

    xor-int/2addr v1, v2

    shl-int/lit8 v2, v1, 0x5

    xor-int/2addr v1, v2

    const/4 v2, 0x2

    aget-object v0, v0, v2

    check-cast v0, [I

    aput v1, v0, v8

    goto/16 :goto_5

    .line 301
    :cond_10
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    aget-object v4, v2, v8

    check-cast v4, [Ljava/lang/String;

    if-eqz v4, :cond_11

    move v5, v8

    .line 318
    :goto_4
    array-length v9, v4

    if-ge v5, v9, :cond_11

    .line 326
    aget-object v9, v4, v5

    invoke-interface {v1, v9}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    add-int/lit8 v5, v5, 0x1

    goto :goto_4

    :cond_11
    const v1, 0xd53182c

    int-to-long v4, v1

    const/16 v1, 0x20

    shl-long/2addr v4, v1

    xor-int/2addr v0, v3

    int-to-long v0, v0

    xor-long/2addr v0, v4

    const v3, 0xd53182e

    int-to-long v3, v3

    const/4 v5, 0x2

    .line 344
    :try_start_5
    new-array v9, v5, [Ljava/lang/Object;

    .line 354
    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    .line 361
    aput-object v3, v9, v7

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    aput-object v0, v9, v8

    sget-object v0, Lnet/pluservice/tua/MainActivity;->$$g:[B

    const/16 v1, 0xa

    aget-byte v1, v0, v1

    int-to-byte v1, v1

    int-to-byte v3, v1

    int-to-byte v4, v3

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v1, v3, v4, v5}, Lnet/pluservice/tua/MainActivity;->c(SSS[Ljava/lang/Object;)V

    aget-object v1, v5, v8

    check-cast v1, Ljava/lang/String;

    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const/16 v3, 0x20

    int-to-byte v3, v3

    const/16 v4, 0x44

    aget-byte v4, v0, v4

    int-to-byte v4, v4

    const/16 v5, 0xb

    aget-byte v0, v0, v5

    neg-int v0, v0

    int-to-byte v0, v0

    new-array v5, v7, [Ljava/lang/Object;

    invoke-static {v3, v4, v0, v5}, Lnet/pluservice/tua/MainActivity;->c(SSS[Ljava/lang/Object;)V

    aget-object v0, v5, v8

    check-cast v0, Ljava/lang/String;

    const/4 v3, 0x2

    new-array v4, v3, [Ljava/lang/Class;

    sget-object v3, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    aput-object v3, v4, v8

    sget-object v3, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    aput-object v3, v4, v7

    invoke-virtual {v1, v0, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    invoke-virtual {v0, v6, v9}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    const/4 v0, 0x4

    new-array v0, v0, [Ljava/lang/Object;

    new-array v1, v7, [I

    aput-object v1, v0, v7

    new-array v3, v7, [I

    const/4 v4, 0x2

    aput-object v3, v0, v4

    new-array v3, v7, [I

    const/4 v5, 0x3

    aput-object v3, v0, v5

    aget-object v6, v2, v4

    check-cast v6, [I

    aget v4, v6, v8

    aget-object v5, v2, v5

    check-cast v5, [I

    aget v5, v5, v8

    aget-object v6, v2, v7

    check-cast v6, [I

    aget v6, v6, v8

    aget-object v2, v2, v8

    check-cast v2, [Ljava/lang/String;

    check-cast v3, [I

    aput v5, v3, v8

    check-cast v1, [I

    aput v6, v1, v8

    aput-object v2, v0, v8

    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Runtime;->freeMemory()J

    move-result-wide v1

    long-to-int v1, v1

    not-int v1, v1

    const v2, -0xe7c1c52

    or-int/2addr v2, v1

    not-int v2, v2

    const v3, 0x8301801

    or-int/2addr v2, v3

    mul-int/lit16 v2, v2, -0xf1

    const v3, -0x34e285fd    # -1.0320387E7f

    add-int/2addr v2, v3

    const v3, -0x64c0451

    or-int/2addr v1, v3

    not-int v1, v1

    const v3, -0xfff1c74

    or-int/2addr v1, v3

    mul-int/lit16 v1, v1, 0xf1

    add-int/2addr v2, v1

    add-int/2addr v4, v2

    shl-int/lit8 v1, v4, 0xd

    xor-int/2addr v1, v4

    ushr-int/lit8 v2, v1, 0x11

    xor-int/2addr v1, v2

    shl-int/lit8 v2, v1, 0x5

    xor-int/2addr v1, v2

    const/4 v2, 0x2

    aget-object v0, v0, v2

    check-cast v0, [I

    aput v1, v0, v8

    :goto_5
    return-void

    .line 286
    :catch_0
    new-instance v0, Ljava/lang/RuntimeException;

    invoke-direct {v0}, Ljava/lang/RuntimeException;-><init>()V

    .line 289
    throw v0

    :catchall_0
    move-exception v0

    .line 188
    invoke-virtual {v0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_12

    .line 198
    throw v1

    .line 205
    :cond_12
    throw v0

    .line 137
    :catch_1
    new-instance v0, Ljava/lang/RuntimeException;

    .line 146
    invoke-direct {v0}, Ljava/lang/RuntimeException;-><init>()V

    throw v0

    :catchall_1
    move-exception v0

    .line 115
    invoke-virtual {v0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_13

    throw v1

    :cond_13
    throw v0

    nop

    :array_0
    .array-data 2
        -0x1367s
        0x376es
        -0x11des
        -0xe69s
        0x4125s
        0x22c6s
        -0x6febs
        0xae2s
        0x62ads
        0x7bcfs
        0x3fa4s
        -0x3f06s
        -0x140bs
        -0x1553s
        0x4838s
        0x2052s
        -0x15f2s
        0x5d8bs
        -0x6ea0s
        -0x65dcs
        -0xdf1s
        0x292bs
    .end array-data

    :array_1
    .array-data 2
        -0x6f19s
        -0x441as
        0x7615s
        0x374as
        -0x33s
        0x7d8ds
        0x3939s
        0x1146s
        0x59s
        -0x6672s
        0x5540s
        -0x2160s
        0x485fs
        0x11d7s
        -0x1abfs
        -0x5216s
    .end array-data

    :array_2
    .array-data 2
        0x6d6ds
        -0x5ecs
        0x4e1fs
        -0x26cfs
        0x6ae1s
        0xe2s
        -0x1367s
        0x376es
        -0x6194s
        0x605es
        -0x12aes
        0x9a2s
        -0xc2bs
        -0x5a82s
        0x3ca7s
        0x854s
    .end array-data

    :array_3
    .array-data 2
        0x39d6s
        -0x17cfs
        -0x5553s
        -0x2499s
        -0x23c0s
        -0x6fbcs
        0x7d14s
        0x2214s
        0x7e04s
        0x7713s
        0x1d9es
        -0x730bs
        -0x28b3s
        0x7699s
        0x58a3s
        0x20fbs
    .end array-data

    :array_4
    .array-data 2
        -0x1367s
        0x376es
        -0x11des
        -0xe69s
        0x4125s
        0x22c6s
        -0x6febs
        0xae2s
        0x62ads
        0x7bcfs
        0x3fa4s
        -0x3f06s
        -0x140bs
        -0x1553s
        0x4838s
        0x2052s
        -0x15f2s
        0x5d8bs
        -0x6ea0s
        -0x65dcs
        -0xdf1s
        0x292bs
    .end array-data

    :array_5
    .array-data 2
        -0x6f19s
        -0x441as
        0x7615s
        0x374as
        -0x33s
        0x7d8ds
        0x3939s
        0x1146s
        0x59s
        -0x6672s
        0x5540s
        -0x2160s
        0x485fs
        0x11d7s
        -0x1abfs
        -0x5216s
    .end array-data

    :array_6
    .array-data 2
        -0x1367s
        0x376es
        -0x11des
        -0xe69s
        0x4125s
        0x22c6s
        -0x6febs
        0xae2s
        0x62ads
        0x7bcfs
        0x3fa4s
        -0x3f06s
        -0x140bs
        -0x1553s
        0x4838s
        0x2052s
        -0x15f2s
        0x5d8bs
        -0x6ea0s
        -0x65dcs
        -0xdf1s
        0x292bs
    .end array-data

    :array_7
    .array-data 2
        -0x6f19s
        -0x441as
        0x7615s
        0x374as
        -0x33s
        0x7d8ds
        0x3939s
        0x1146s
        0x59s
        -0x6672s
        0x5540s
        -0x2160s
        0x485fs
        0x11d7s
        -0x1abfs
        -0x5216s
    .end array-data

    :array_8
    .array-data 2
        0x6d6ds
        -0x5ecs
        0x4e1fs
        -0x26cfs
        0x6ae1s
        0xe2s
        -0x1367s
        0x376es
        -0x6194s
        0x605es
        -0x12aes
        0x9a2s
        -0xc2bs
        -0x5a82s
        0x3ca7s
        0x854s
    .end array-data

    :array_9
    .array-data 2
        0x39d6s
        -0x17cfs
        -0x5553s
        -0x2499s
        -0x23c0s
        -0x6fbcs
        0x7d14s
        0x2214s
        0x7e04s
        0x7713s
        0x1d9es
        -0x730bs
        -0x28b3s
        0x7699s
        0x58a3s
        0x20fbs
    .end array-data

    :array_a
    .array-data 2
        -0x1367s
        0x376es
        -0x11des
        -0xe69s
        0x4125s
        0x22c6s
        -0x6febs
        0xae2s
        0x62ads
        0x7bcfs
        0x3fa4s
        -0x3f06s
        -0x140bs
        -0x1553s
        0x4838s
        0x2052s
        -0x15f2s
        0x5d8bs
        -0x6ea0s
        -0x65dcs
        -0xdf1s
        0x292bs
    .end array-data

    :array_b
    .array-data 2
        -0x6f19s
        -0x441as
        0x7615s
        0x374as
        -0x33s
        0x7d8ds
        0x3939s
        0x1146s
        0x59s
        -0x6672s
        0x5540s
        -0x2160s
        0x485fs
        0x11d7s
        -0x1abfs
        -0x5216s
    .end array-data
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 3

    const/4 v0, 0x2

    .line 40
    rem-int v1, v0, v0

    .line 31
    invoke-super {p0, p1}, Lorg/apache/cordova/CordovaActivity;->onCreate(Landroid/os/Bundle;)V

    .line 34
    invoke-virtual {p0}, Lnet/pluservice/tua/MainActivity;->getIntent()Landroid/content/Intent;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object p1

    if-eqz p1, :cond_1

    .line 40
    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v1, v1, 0x69

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    rem-int/2addr v1, v0

    .line 35
    const-string v1, "cdvStartInBackground"

    const/4 v2, 0x0

    invoke-virtual {p1, v1, v2}, Landroid/os/Bundle;->getBoolean(Ljava/lang/String;Z)Z

    move-result p1

    const/4 v1, 0x1

    if-eq p1, v1, :cond_0

    goto :goto_0

    .line 40
    :cond_0
    sget p1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 p1, p1, 0x2b

    rem-int/lit16 v2, p1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    rem-int/2addr p1, v0

    .line 36
    invoke-virtual {p0, v1}, Lnet/pluservice/tua/MainActivity;->moveTaskToBack(Z)Z

    .line 40
    :cond_1
    :goto_0
    iget-object p1, p0, Lnet/pluservice/tua/MainActivity;->launchUrl:Ljava/lang/String;

    invoke-virtual {p0, p1}, Lnet/pluservice/tua/MainActivity;->loadUrl(Ljava/lang/String;)V

    sget p1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 p1, p1, 0x55

    rem-int/lit16 v1, p1, 0x80

    sput v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    rem-int/2addr p1, v0

    return-void
.end method

.method public onPause()V
    .locals 3

    const/4 v0, 0x2

    .line 65352
    rem-int v1, v0, v0

    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    add-int/lit8 v1, v1, 0x4f

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    rem-int/2addr v1, v0

    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onPause()V

    if-eqz v1, :cond_0

    const/16 v1, 0x21

    div-int/lit8 v1, v1, 0x0

    :cond_0
    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    add-int/lit8 v1, v1, 0x1f

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    rem-int/2addr v1, v0

    return-void
.end method

.method public onResume()V
    .locals 3

    const/4 v0, 0x2

    .line 65353
    rem-int v1, v0, v0

    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v1, v1, 0x65

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    rem-int/2addr v1, v0

    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onResume()V

    if-eqz v1, :cond_0

    return-void

    :cond_0
    const/4 v0, 0x0

    throw v0
.end method

.method public onStart()V
    .locals 3

    const/4 v0, 0x2

    .line 65354
    rem-int v1, v0, v0

    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    add-int/lit8 v1, v1, 0xb

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    rem-int/2addr v1, v0

    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onStart()V

    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I

    add-int/lit8 v1, v1, 0x19

    rem-int/lit16 v2, v1, 0x80

    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I

    rem-int/2addr v1, v0

    if-nez v1, :cond_0

    return-void

    :cond_0
    const/4 v0, 0x0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    throw v0
.end method
