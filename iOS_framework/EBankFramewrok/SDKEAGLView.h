//
//  SDKEAGLView.h
//  SafeModuleIosLib
//
//  Created by liuyong on 16/1/6.
//  Copyright © 2016年 liuyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDKHelper <NSObject>

@required
-(void) notifyKeyInput:(const char*)userInput;
@optional
-(void) notifyApp:(const char*)pJson;
@end

@interface SDKEAGLView:NSObject

@property (nonatomic, assign) id <SDKHelper> delegate;
/**
 ** 创建有感插件视图
 **/
+ (id) createEAGLView:(CGRect)frame window:(UIView *) pRootwindow;

/**
 ** 隐藏视图
 */
+(void) setHidden:(bool)isHidden window:(UIView *) pRootwindow;

/**
 ** 设置SDKDelegate
 */
-(void) setSDKDelegate:(id <SDKHelper>) _Delegate;

/**
 ** 功能:有感插件方法
 ** 参数:
 ** pJson:[输入参数]
 ** mode:1:非加密,2:SM3（报文+签名）3:信封
 **/
+(void)launchKeyboard;

/**
 ** 程序切入后台
 **/
+(void) onPause;

/**
 ** 程序切入前台
 **/
+(void) onResume;

@end
