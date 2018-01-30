//
//  SDKEAGLView.cpp
//  SafeModuleIosLib
//
//  Created by liuyong on 16/1/6.
//  Copyright © 2016年 liuyong. All rights reserved.
//

#include "SDKEAGLView.h"
#import "platform/ios/CCEAGLView-ios.h"
#include "cocos2d.h"
#include "KeyboardContr.h"
#include "LogUtil.h"

#include "MyAppDelegate.h"
static MyAppDelegate s_cocosSharedApplication;
SDKEAGLView* s_pSDKEAGLView = nullptr;
CCEAGLView* s_pMyEAGLView = nullptr;

extern "C"
{
    extern void nativeSdkFuntion();
    
    void notifyApp(const char* pJson){
        //清理不用的缓存资源
        cocos2d::SpriteFrameCache::getInstance()->removeUnusedSpriteFrames();
        cocos2d::Director::getInstance()->getTextureCache()->removeUnusedTextures();
        
        //clear cache
        cocos2d::Director::getInstance()->purgeCachedData();
        
        //全部清理
        cocos2d::AnimationCache::getInstance()->destroyInstance();
        cocos2d::SpriteFrameCache::getInstance()->removeSpriteFrames();
        cocos2d::Director::getInstance()->getTextureCache()->removeAllTextures();
        
        //暂停[提高性能]
        [SDKEAGLView onPause];
        
        //通知app
        if(s_pSDKEAGLView != nullptr){
            [s_pSDKEAGLView.delegate notifyApp:pJson];
        }
    }
    
    void notifyKeyInput(const char*userInput){
        //通知app
        if(s_pSDKEAGLView != nullptr){
            [s_pSDKEAGLView.delegate notifyKeyInput:userInput];
        }
    }
    
    
}

@implementation SDKEAGLView

+(void) initGLContext
{
    //初始化glview参数
    cocos2d::Application * pApp = cocos2d::Application::getInstance();
    pApp->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();
}

+(id) createEAGLView:(CGRect)frame window:(UIView *) pRootwindow{
    if(s_pSDKEAGLView != nullptr){
        return s_pSDKEAGLView;
    }

    [SDKEAGLView initGLContext];
    
    s_pMyEAGLView =[SDKEAGLView createEAGLView:frame];
    //设置MyEAGLView 背景透明
    s_pMyEAGLView.opaque = NO;
    
    //MyEAGLView添加到当前窗口
    [pRootwindow addSubview:s_pMyEAGLView];
    
    [SDKEAGLView initAndShowCocos2dView];
    
    s_pSDKEAGLView =[[SDKEAGLView alloc] init];
    
    return s_pSDKEAGLView;
}

+ (id) createEAGLView:(CGRect)frame
{
    return [[[CCEAGLView alloc]initWithFrame:frame pixelFormat:(NSString*)cocos2d::GLViewImpl::_pixelFormat depthFormat: cocos2d::GLViewImpl::_depthFormat preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0] autorelease];
}

+(void) initAndShowCocos2dView
{
    if(cocos2d::Director::getInstance()->getOpenGLView() == nullptr)
    {
        //设置cocos2dxOpenGLView
        cocos2d::GLView * pGLview = cocos2d::GLViewImpl::createWithEAGLView(s_pMyEAGLView);
        cocos2d::Director::getInstance()->setOpenGLView(pGLview);
        
        //运行cocos2dx场景
        cocos2d::Application * pApp = cocos2d::Application::getInstance();
        pApp->run();
    }
}

+(void) setHidden:(bool)isHidden window:(UIView *) pRootwindow{
    [s_pMyEAGLView setHidden:isHidden];
    if(!isHidden){
        [pRootwindow bringSubviewToFront:s_pMyEAGLView];
    }
}

-(void) setSDKDelegate:(id <SDKHelper>) _Delegate{
    [self setDelegate:_Delegate];
}

+(void)launchKeyboard{
    //恢复[提高性能]
    [SDKEAGLView  onResume];

    auto pScen =cocos2d::Director::getInstance()->getRunningScene();
    if(pScen){
        nativeSdkFuntion();
    }else{
        [NSTimer scheduledTimerWithTimeInterval:0.12 target:self selector:@selector(onTimerUpdateBlock:) userInfo:nil repeats:YES];
    }
}
+ (void)onTimerUpdateBlock:(NSTimer *)timer {
    
    auto pScen =cocos2d::Director::getInstance()->getRunningScene();
    LogUtil::NSLog("***********SDKEAGLView-onTimerUpdateBlock-pScen***************::%p",pScen);
    if(pScen){
        [timer invalidate];
        nativeSdkFuntion();
    }
}

/**
 ** 程序切入后台
 **/
+(void) onPause{
     if(s_pSDKEAGLView == nullptr){
        return ;
     }
     //pause
     cocos2d::Director::getInstance()->pause();
     cocos2d::Application * pApp = cocos2d::Application::getInstance();
     pApp->applicationDidEnterBackground();
}

/**
 ** 程序切入前台
 **/
+(void) onResume{
    if(s_pSDKEAGLView == nullptr){
        return ;
    }
    //resume
    cocos2d::Director::getInstance()->resume();
    cocos2d::Application * pApp = cocos2d::Application::getInstance();
    pApp->applicationWillEnterForeground();
}

- (void)dealloc {
    [s_pSDKEAGLView release];
    s_pSDKEAGLView = nullptr;
    s_pMyEAGLView = nullptr;
    
    [super dealloc];
}

@end
