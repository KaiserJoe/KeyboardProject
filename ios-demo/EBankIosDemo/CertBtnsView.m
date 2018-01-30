//
//  CertBtnsView.m
//  NetWorkDemo
//
//  Created by 收付宝－胜利 on 16/11/16.
//  Copyright © 2016年 Bankeys. All rights reserved.
//

#import "CertBtnsView.h"

@implementation CertBtnsView

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger color = 0xffdfdfdf;
        UIColor* pcolor = [self colorWithHex:color alpha:1];
        self.backgroundColor = pcolor;
    }
    return self;
}

- (void)sectionTitle:(NSString *)title
            rowCount:(int)rowCount
           btnTitles:(NSArray *)btnTitles {
    
    float y = 40;
    float x = 1;
    float w = (self.frame.size.width / rowCount) - 10;
    int index = 0;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w*rowCount, y)];
    titleLab.text = [NSString stringWithFormat:@"   %@",title];
    titleLab.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:titleLab];
    
    for (int i = 0; i < btnTitles.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        if (i == 0) {
            if (i == 0) {
                x = 10;
            }
        } else {
            if (i % rowCount == 0) {
                x = 10;
                index = 0;
                y = y + 50;
            } else {
                index ++;
                x = ((self.frame.size.width / rowCount) - 5) * index + 10;
            }
        }
        
        btn.frame = CGRectMake(x  , y, w, 35);
        
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:btnTitles[i] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(btnClick:)
      forControlEvents:(UIControlEventTouchUpInside)];
        
        [self addSubview:btn];
    }
}

-(UIButton*)getBtnByTag:(int)tag{
    return [self viewWithTag:tag];
}

- (void)btnClick:(UIButton *)btn {
    
    if (self.viewBtnHandle) {
        self.viewBtnHandle(btn);
    }
}

@end
