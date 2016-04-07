# andfixDemo
对于网上提供的热补丁修复就不多说了，主要有这3种方式可以实现（至于其他的方式，暂不清楚）

1.dexposed     github https://github.com/alibaba/dexposed

2.andfix   github https://github.com/alibaba/AndFix

3.bsdiff  http://blog.csdn.net/lazyer_dog/article/details/47173013

dexposed和andfix是alibaba的开源项目，都是apk增量更新的实现框架，目前dexposed的兼容性较差，只有2.3，4.0~4.4兼容，其他Android版本不兼容或未测试，详细可以去dexposed的github项目主页查看，而andfix则兼容2.3~6.0，所以就拿这个项目来实现增量更新吧。至于bsdiff，只是阅览了一下，还没研究过。
首先 git clone github https://github.com/alibaba/AndFix，将andfix项目下载下来，Android studio可以在build.gradle里导入andfix，

compile 'com.alipay.euler:andfix:0.3.1'
但是我是使用module的方式添加andfix，这样可以直接查看编辑源码，而且直接gradle导入的话还有个问题，后面再说。

我看了下官网的demo主要是在android装载到内存的时候去加载我们新的dex的包，然后加载到内存，要研究原理的请到这个地址去查看：

http://blog.csdn.net/xiangzhihong8/article/details/50949691

下面主要说实现：



andfix里有些文件夹不用导入的，例如tools，doc等，记得新建jniLibs文件夹，libs里的so文件移到jniLibs里。

接下来我们参照官网的demo


public class MainApplication extends Application {
    private static final String TAG = "euler";

    private static final String APATCH_PATH = "/out.apatch";

    private static final String DIR = "apatch";//补丁文件夹
    /**
     * patch manager
     */
    private PatchManager mPatchManager;

    @Override
    public void onCreate() {
        super.onCreate();
        // initialize
        mPatchManager = new PatchManager(this);
        mPatchManager.init("1.0");
        Log.d(TAG, "inited.");

        // load patch
        mPatchManager.loadPatch();
//        Log.d(TAG, "apatch loaded.");

        // add patch at runtime
        try {
            // .apatch file path
            String patchFileString = Environment.getExternalStorageDirectory()
                    .getAbsolutePath() + APATCH_PATH;
            mPatchManager.addPatch(patchFileString);
            Log.d(TAG, "apatch:" + patchFileString + " added.");

            //这里我加了个方法，复制加载补丁成功后，删除sdcard的补丁，避免每次进入程序都重新加载一次
            File f = new File(this.getFilesDir(), DIR + APATCH_PATH);
            if (f.exists()) {
                boolean result = new File(patchFileString).delete();
                if (!result)
                    Log.e(TAG, patchFileString + " delete fail");
            }
        } catch (IOException e) {
            Log.e(TAG, "", e);
        }

    }
刚刚说的直接在gradle里导入andfix会有个问题，是在原来的项目中，加载一次补丁后，out.apatch文件会copy到getFilesDir目录下的/apatch文件夹中，在下次补丁更新时，会检测补丁是否已经添加在apatch文件夹下，已存在就不会复制加载sdcard的out.apatch。

原来的addpath方法

public void addPatch(String path) throws IOException {
    File src = new File(path);
    File dest = new File(mPatchDir, src.getName());
    if(!src.exists()){
        throw new FileNotFoundException(path);
    }
    if (dest.exists()) {
        Log.d(TAG, "patch [" + path + "] has be loaded.");
        return;
    }
    FileUtil.copyFile(src, dest);// copy to patch's directory
    Patch patch = addPatch(dest);
    if (patch != null) {
        loadPatch(patch);
    }
}
修改后，判断apatch下的out.apatch存在即删除掉，重新复制加载sdcard下的out.apatch

public void addPatch(String path) throws IOException {
    File src = new File(path);
    File dest = new File(mPatchDir, src.getName());
    if (!src.exists()) {
        throw new FileNotFoundException(path);
    }
    if (dest.exists()) {
        Log.d(TAG, "patch [" + src.getName() + "] has be loaded.");
        boolean deleteResult = dest.delete();
        if (deleteResult)
            Log.e(TAG, "patch [" + dest.getPath() + "] has be delete.");
        else {
            Log.e(TAG, "patch [" + dest.getPath() + "] delete error");
            return;
        }
    }
    FileUtil.copyFile(src, dest);// copy to patch's directory
    Patch patch = addPatch(dest);
    if (patch != null) {
        loadPatch(patch);
    }
}

还有源码混淆

-optimizationpasses 5                                                           # 指定代码的压缩级别
-dontusemixedcaseclassnames                                                     # 是否使用大小写混合
-dontskipnonpubliclibraryclasses                                                # 是否混淆第三方jar
-dontpreverify                                                                  # 混淆时是否做预校验
-verbose                                                                        # 混淆时是否记录日志
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*        # 混淆时所采用的算法

#重要，別忘了這些，不混淆andfix包，不混淆native方法
-dontwarn android.annotation
-dontwarn com.alipay.euler.**
-keep class com.alipay.euler.** {*;}
-keep class * extends java.lang.annotation.Annotation
-keepclasseswithmembernames class * {
    native <methods>;
}
下面我们打包：


cmd输入命令，具体参数看usage


apkpatch.bat -f new.apk -t old.apk -o output1 -k suning.keystore -p Suning1234 -a suning -e Suning1234 【完整命令】

上面这个命令有点问题，用下面的：

apkpatch -f new.apk -t old.apk -o output -k xzh.jks -p 19881205 -a keyalias -e 19881205
解释下这个意思，apkpatch -f <new apk> -t <old.apk> -o<输出位置> -k <keystore> -p<password> -a <key alias> -e <password>

这里的keystore就是你签名包

如无错误，编译后会生成一个apatch文件，改名成out.apatch



里面的smali列出了不同的文件，diff.dex就是android 虚拟机加载运行的不同的文件。

安装打开1.apk



关闭app，将out.apatch放sdcard根目录后，重新打开app，toast方法改变了





2）  几个开源热修复或插件化解决方案（排名不分先后）

https://github.com/lzyzsd/AndroidHotFixExamples

https://github.com/simpleton/dalvik_patch

https://github.com/dodola/HotFix

https://github.com/jasonross/Nuwa

https://github.com/alibaba/AndFix

https://github.com/rovo89/Xposed

https://github.com/alibaba/dexposed

https://github.com/bunnyblue/DroidFix

https://github.com/CtripMobile/DynamicAPK

3）  技术原理博客（排名不分先后）

http://bugly.qq.com/blog/?p=781（QQ空间的解决方案）

https://m.oschina.net/blog/308583（Android Dex分包方案）

http://lirenlong.github.io/hotfix/（浅析xposed、dexposed和AndFix的原理）

http://blog.csdn.net/lmj623565791/article/details/49883661（鸿洋）

http://blog.csdn.net/vipzjyno1/article/details/21039349/（android反编译）
