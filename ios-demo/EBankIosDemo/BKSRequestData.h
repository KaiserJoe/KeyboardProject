//
//  BKSRequestData.h
//  NetWorkDemo
//
//  Created by 收付宝－胜利 on 16/11/15.
//  Copyright © 2016年 Bankeys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKSRequestData : NSObject




- (void)requestWithParam:(NSDictionary *)param
                     tag:(NSInteger)tag
                    path:(NSString *)path
                 success:(void (^)(id responseString, BOOL isOk , NSInteger index))success;

@end
