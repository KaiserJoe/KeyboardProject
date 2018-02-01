#include "AppDelegate.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "LogUtil.h"

#define  LOG_TAG    "main"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;

void cocos_android_app_init (JNIEnv* env) {
    LOGD("cocos_android_app_init");
    AppDelegate *pAppDelegate = new AppDelegate();
}
//add by jamesliu
extern "C" {
    /**
     ** 功能:通知APP
     ** 参数:
     **/
    void notifyApp(const char* pSignedMsg){
        JniMethodInfo t;
        if (JniHelper::getStaticMethodInfo(t, "com/bankeys/view/SDKHelper", "notifyApp",
                                           "()V")) {
            jstring jValue = t.env->NewStringUTF(pSignedMsg);
            t.env->CallStaticVoidMethod(t.classID, t.methodID,jValue);
            t.env->DeleteLocalRef(jValue);
            t.env->DeleteLocalRef(t.classID);
        }
        
        delete pSignedMsg;
    }
    
    
    void notifyKeyInput(const char* pSignedMsg){
        JniMethodInfo t;
        if (JniHelper::getStaticMethodInfo(t, "com/bankeys/view/SDKHelper", "notifyKeyInput",
                                           "(Ljava/lang/String;)V")) {
            jstring jValue = t.env->NewStringUTF(pSignedMsg);
            t.env->CallStaticVoidMethod(t.classID, t.methodID,jValue);
            t.env->DeleteLocalRef(jValue);
            t.env->DeleteLocalRef(t.classID);
        }
    }
    
    
    extern void nativeSdkFuntion();
    
    int checkEngineInitSuc(){
        auto pScen =cocos2d::Director::getInstance()->getRunningScene();
        if(pScen){
            return 1;
        }
        return 0;
    }
    
    void nativeFixWindowSize(){
        auto director = cocos2d::Director::getInstance();
        auto glview = director->getOpenGLView();
        if (!glview)
        {
            LogUtil::NSLog("getOpenGLView");
            auto frameSize = glview->getFrameSize();
            glview->setFrameSize(frameSize.height,frameSize.width);
            glview->setDesignResolutionSize(640, 854, ResolutionPolicy::FIXED_WIDTH);
        }
        LogUtil::NSLog("没有 getOpenGLView");
        
    }
    
    /*
     * Class:     com.bankeys.view.SDKHelper
     * Method:    nativeSdkFuntion
     * Signature: (Ljava/lang/String;I)V
     */
    
    JNIEXPORT jint JNICALL Java_com_bankeys_view_SDKHelper_nativeSdkFuntion(
                                                                            JNIEnv *env, jobject thiz,jstring) {
        nativeSdkFuntion();
    }
    
    /*
     * Class:     com.bankeys.view.SDKHelper
     * Method:    nativeCheckEngineInitSuc
     * Signature: ()I
     */
    
    JNIEXPORT jint JNICALL Java_com_bankeys_view_SDKHelper_nativeCheckEngineInitSuc(
                                                                                    JNIEnv *env, jobject thiz) {
        int nRet =checkEngineInitSuc();
        
        return nRet;
        
    }
    
    /*
     * Class:     com.bankeys.view.SDKHelper
     * Method:    nativeFixWindowSize
     * Signature: ()V
     */
    
    JNIEXPORT jint JNICALL Java_com_bankeys_view_SDKHelper_nativeFixWindowSize(
                                                                               JNIEnv *env, jobject thiz) {
        nativeFixWindowSize();
    }
    
}
//end
