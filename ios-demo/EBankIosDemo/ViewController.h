//
//  ViewController.h
//  SafeModuleIosDemo
//
//  Created by liuyong on 16/1/6.
//  Copyright © 2016年 liuyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EBankIos/SDKEAGLView.h>

@interface ViewController : UIViewController <SDKHelper,UIAlertViewDelegate>

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

@end

