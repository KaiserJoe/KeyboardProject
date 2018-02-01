package com.bankeys.view;

import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;

import com.bankeys.common.LogUtil;
import com.bankeys.data.SDKData;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import java.util.Timer;
import java.util.TimerTask;

public class SDKAppActivity extends Cocos2dxActivity {
    private static SDKAppActivity m_Instance = null;

    // sdk->sdkMainActivity
    private String m_szNotifyApp;
    private Handler mSDKHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            // 关闭SDKActivit，返回主APP
            Bundle B         = msg.getData();
            // 从Bundle数据中提取带"notifyApp"标志的数据,并转换成String
            m_szNotifyApp    = (String) B.get("notifyApp");
            onClose(m_szNotifyApp);
        }
    };

    // 引擎初始化完毕参数
    private boolean isResume   = false;
    // 引擎暂停
    private boolean isPause    = false;
    private Timer m_Timer      = null;

    Handler mTimerHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            int nEngineInitSuc = SDKHelper.nativeCheckEngineInitSuc();

            LogUtil.D(SDKData.TAG, "mTimerHandler::handleMessage-threadId::" + Thread.currentThread().getId());
            LogUtil.D(SDKData.TAG, "mTimerHandler::handleMessage-timer::" + m_Timer);
            LogUtil.D(SDKData.TAG, "mTimerHandler::handleMessage-isPause::" + isPause);
            LogUtil.D(SDKData.TAG, "mTimerHandler::handleMessage-isEngineInitSuc::" + isResume);
            LogUtil.D(SDKData.TAG, "mTimerHandler::handleMessage-nEngineInitSuc::" + nEngineInitSuc);

            if (!isResume || isPause || nEngineInitSuc != 1) {
                return;
            }
            if (m_Timer != null) {
                m_Timer.cancel();
                m_Timer = null;
            }

            // app调用sdk
            Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                @Override
                public void run() {
                    SDKHelper.nativeSdkFuntion();
                }
            });

        }
    };

    private TimerTask m_Task = null;
    private void createTask() {
        m_Task = new TimerTask() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                Message message = new Message();
                mTimerHandler.sendMessage(message);
            }
        };
    }

    private void cancleTask() {
        if (m_Task != null) {
            m_Task.cancel();
            m_Task = null;
        }
    }

    public void hideNavigationBar() {
        int uiFlags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
                ; // hide status bar


        // | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        // | View.SYSTEM_UI_FLAG_FULLSCREEN
        // | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR

        if (android.os.Build.VERSION.SDK_INT >= 19) {
            //uiFlags |= 0x00001000;    //SYSTEM_UI_FLAG_IMMERSIVE_STICKY: hide navigation bars - compatibility: building API level is lower thatn 19, use magic number directly for higher API target level
        } else {
            uiFlags |= View.SYSTEM_UI_FLAG_LOW_PROFILE;
        }

        getWindow().getDecorView().setSystemUiVisibility(uiFlags);

    }

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        // Log.d(TAG, "SDKAppActivity::onCreate");
        // 无title
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        // 全屏
        // getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
        // WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // 窗体透明
        getWindow().setFormat(PixelFormat.TRANSLUCENT);


        // 创建Cocos2dxActivity
        super.onCreate(savedInstanceState);


        // 设置和主线程通讯的handler
        SDKHelper.setSDKHandler(mSDKHandler);
        SDKHelper.setSDKActivity(this);

        m_Timer = new Timer();

        // 创建定时任务并执行
        createTask();

        m_Timer.schedule(m_Task, 1 * 1000, 500);

    }

    private void onClose(String notify) {
        LogUtil.D(SDKData.TAG, "SDKAppActivity::onClose");

        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
        intent.putExtra("notifyApp", notify);
        setResult(RESULT_OK, intent);
        cancleTask();
        finish();
        overridePendingTransition(0, 0);
    }

    @Override
    protected void onResume() {
        //隐藏导航栏
        //hideNavigationBar();

        super.onResume();
        LogUtil.D(SDKData.TAG, "SDKAppActivity::onResume");

        // 引擎初始化完毕参数
        isResume = true;
        // 引擎暂停
        isPause = false;
    }

    @Override
    protected void onPause() {
        // 引擎暂停
        isPause = true;

        super.onPause();
        LogUtil.D(SDKData.TAG, "SDKAppActivity::onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        LogUtil.D(SDKData.TAG, "SDKAppActivity::onStop");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LogUtil.D(SDKData.TAG, "SDKAppActivity::onDestroy");

        // 引擎初始化完毕参数
        isResume = false;
        // 引擎暂停
        isPause = true;

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);

        LogUtil.D(SDKData.TAG, "SDKAppActivity::onActivityResult");
        LogUtil.D(SDKData.TAG, "SDKAppActivity::onActivityResult-requestCode" + requestCode);
    }

}
