//
//  BKSRequestData.m
//  NetWorkDemo
//
//  Created by 收付宝－胜利 on 16/11/15.
//  Copyright © 2016年 Bankeys. All rights reserved.
//

#import "BKSRequestData.h"
#import "AFNetworking.h"

#define kReplacementUrl @"http://10.7.8.25:8080/bkeidsvrdemo/signRequestApp3.do"


@implementation BKSRequestData

- (void)requestWithParam:(NSDictionary *)param
                     tag:(NSInteger)tag
                    path:(NSString *)path
            success:(void (^)(id responseString, BOOL isOk , NSInteger index))success {
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.responseSerializer  = [AFHTTPResponseSerializer serializer];
    session.requestSerializer   = [AFJSONRequestSerializer serializer];
    
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [session POST:[NSString stringWithFormat:@"%@/%@",kReplacementUrl, path]
       parameters:param
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
              NSLog(@"requestWithParam-suc::%@",responseObject);
              
              NSString *jsonString = nil;
              
              jsonString = [[NSString alloc] initWithData:responseObject
                                                 encoding:NSUTF8StringEncoding];
              
              if (jsonString.length > 4) {
         
                  success(jsonString,YES,tag);
                 
              }else{
                  success(jsonString,NO,tag);
              }
              
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"requestWithParam::fail: %@ ----- %ld ",error,(long)response.statusCode);
        success(error ,NO,tag);
    }];
    
}


@end
