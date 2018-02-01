package com.bankeys.view;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.Signature;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.bankeys.common.LogUtil;
import com.bankeys.data.JniData;
import com.bankeys.data.SDKData;
import com.chukong.cocosplay.client.CocosPlayClient;

import org.cocos2dx.lib.Cocos2dxHelper;

import java.util.UUID;

;

public class SDKHelper {
    private static SDKHelper mInstance             = null;
    private static OnSDKListener mOnSDKListener    = null;
    private static Handler mSDKHandler             = null;
    private SDKAppActivity mSDKActivity            = null;

    public SDKHelper(final Context context) {
        mInstance = this;
    }

    public static SDKHelper getInstance() {
        return mInstance;
    }

    /**
     * 开启debug日志
     */
    public static void enableLog() {
        LogUtil.enableLog();
    }

    /**
     * app杀掉进程时通知sdk 解决部分小米机型释放actiivty在加载SDKAppActivity出现残留
     */
    public static void notifyDestroy() {
        // 杀死当前进程
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    /**
     * sdk内部调用
     *
     * @param _appHandler
     */
    public static void setSDKHandler(Handler _appHandler) {
        mSDKHandler = _appHandler;
    }

    /**
     * sdk内部调用
     *
     * @param _activity
     */
    public static void setSDKActivity(SDKAppActivity _activity) {
        LogUtil.D(SDKData.TAG, "setSDKActivity-_activity::" + _activity);
        mInstance.mSDKActivity = _activity;
    }


    /**
     * * SDK/c++调用APP方法
     **/
    private static void notifyApp(String szJson) {

        // 结束SDKAppActivity
        Message msg = new Message();
        msg.what = 0;
        Bundle data = new Bundle();
        data.putString("notifyApp", szJson);
        msg.setData(data);
        mSDKHandler.sendMessage(msg);
    }


    private static final String TAG = "SDKHelper";
    private static void notifyKeyInput(String result) {
        Log.e(TAG, "notifyKeyInput: " + result);
    }


    /**
     * APP调用SDK方法 SDK/java调用方法
     */
    public static native void nativeSdkFuntion();

    /**
     * SDK/JAVA调用此方法
     */
    public static native int nativeCheckEngineInitSuc();

    /**
     * SDK/JAVA调用此方法
     */
    public static native void nativeFixWindowSize();
}
