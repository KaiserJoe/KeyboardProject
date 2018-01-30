//
//  CertBtnsView.h
//  NetWorkDemo
//
//  Created by 收付宝－胜利 on 16/11/16.
//  Copyright © 2016年 Bankeys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CertBtnsView : UIView

@property (nonatomic, copy) void(^viewBtnHandle)(UIButton *button);   //!< block

- (void)sectionTitle:(NSString *)title
            rowCount:(int)rowCount
           btnTitles:(NSArray *)btnTitles;

-(UIButton*)getBtnByTag:(int)tag;

@end
