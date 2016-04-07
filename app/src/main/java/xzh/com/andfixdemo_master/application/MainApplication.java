package xzh.com.andfixdemo_master.application;

import android.app.Application;
import android.os.Environment;
import android.util.Log;

import com.alipay.euler.andfix.patch.PatchManager;

import java.io.IOException;

/**
 * Created by xiangzhihong on 2016/4/6 on 18:44.
 */
public class MainApplication extends Application {

    private static final String TAG = "euler";
    private static final String APATCH_PATH = "/out.apatch";
    private PatchManager mPatchManager;

    @Override
    public void onCreate() {
        super.onCreate();
        mPatchManager = new PatchManager(this);
        mPatchManager.init("1.0");
        Log.d(TAG, "inited.");

        mPatchManager.loadPatch();
        Log.d(TAG, "apatch loaded.");

        try {
            String patchFileString = Environment.getExternalStorageDirectory()
                    .getAbsolutePath() + APATCH_PATH;
            mPatchManager.addPatch(patchFileString);
            Log.d(TAG, "apatch:" + patchFileString + " added.");
        } catch (IOException e) {
            Log.e(TAG, "", e);
        }

    }
}
