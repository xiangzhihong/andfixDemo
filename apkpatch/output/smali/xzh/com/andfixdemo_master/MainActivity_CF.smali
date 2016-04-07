.class public Lxzh/com/andfixdemo_master/MainActivity_CF;
.super Landroid/support/v7/app/AppCompatActivity;
.source "MainActivity.java"


# static fields
.field private static final TAG:Ljava/lang/String; = "euler"


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 7
    invoke-direct {p0}, Landroid/support/v7/app/AppCompatActivity;-><init>()V

    return-void
.end method

.method private toast()V
    .locals 2
    .annotation runtime Lcom/alipay/euler/andfix/annotation/MethodReplace;
        method = "toast"
        clazz = "xzh.com.andfixdemo_master.MainActivity"
    .end annotation

    .prologue
    .line 25
    const-string v0, "this is new!"

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 26
    return-void
.end method


# virtual methods
.method public onCreate(Landroid/os/Bundle;)V
    .locals 1
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .prologue
    .line 12
    invoke-super {p0, p1}, Landroid/support/v7/app/AppCompatActivity;->onCreate(Landroid/os/Bundle;)V

    .line 13
    const v0, 0x7f040019

    invoke-virtual {p0, v0}, Lxzh/com/andfixdemo_master/MainActivity_CF;->setContentView(I)V

    .line 14
    invoke-direct {p0}, Lxzh/com/andfixdemo_master/MainActivity_CF;->toast()V

    .line 15
    return-void
.end method

.method protected onDestroy()V
    .locals 1

    .prologue
    .line 19
    invoke-super {p0}, Landroid/support/v7/app/AppCompatActivity;->onDestroy()V

    .line 20
    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v0

    invoke-static {v0}, Landroid/os/Process;->killProcess(I)V

    .line 21
    return-void
.end method
