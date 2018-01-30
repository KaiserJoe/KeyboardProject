//
//  TDCodeReturn.h
//  TDCode
//
//  Created by User on 16/3/3.
//  Copyright © 2016年 sfb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TDCodeReturn : NSObject

//生成二维码
+ (UIImage *)returnTDCodeImageWithInfor:(NSString *)str;

//生成条形码
+ (UIImage *)returnBarCodeImageWithInfor:(NSString *)str;

@end
