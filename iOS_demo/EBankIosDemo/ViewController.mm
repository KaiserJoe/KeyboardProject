//
//  ViewController.m
//  SafeModuleIosDemo
//
//  Created by liuyong on 16/1/6.
//  Copyright © 2016年 liuyong. All rights reserved.
//

#import "ViewController.h"
#include <string>
#import <mach/mach.h>
#import "SBJson/SBJson.h"
#import "AFNetworking.h"
#import "TDCodeReturn.h"
#import "BKSRequestData.h"
#import "CertBtnsView.h"

#define version @"版本号:1.0.0"

@interface ViewController (){

    UIScrollView* g_ServerEchoScrollView ;

}
@end

@implementation ViewController

static SDKEAGLView * s_pSDKEaglView ;

-(void)dealloc{
    [super dealloc];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    CGRect mainScreenBounds =[[UIScreen mainScreen] bounds];
    //创建图层
    CALayer *layer= [CALayer layer];
    layer.backgroundColor= [UIColor whiteColor].CGColor;
    layer.bounds= CGRectMake(0, 0, mainScreenBounds.size.width, 64);
    layer.position = CGPointMake(mainScreenBounds.size.width/2, 32);
    [self.view.layer addSublayer:layer];
    
    //添加标题
     UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 30, mainScreenBounds.size.width, 20.0)];
     label1.text = @"键盘插件演示";
    label1.font = [UIFont boldSystemFontOfSize:18];
    label1.textColor = [UIColor blackColor];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];

    CertBtnsView *certBtnView1 = [[CertBtnsView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 220)];
    [certBtnView1 sectionTitle:@"插件功能类"
                      rowCount:3
                     btnTitles:@[@"启动键盘",@"签名",@"修改密码",@"登录",@"导出证书",@"导入证书",@"查询证书",@"查询公钥",@"吊销"]];
    certBtnView1.viewBtnHandle = ^(UIButton *btn) {
        [self doCert:0];
    };
    [self.view addSubview:certBtnView1];
    
    
    //服务器数据回显
    CGFloat posY = 20;//mainScreenBounds.size.height-80.0f;
    UILabel* echoLabel = [[UILabel alloc]initWithFrame:CGRectMake(20.0, posY, mainScreenBounds.size.width, 50.0)];
    echoLabel.text = @"服务器数据回显";
    //设置字体:粗体，正常的是 SystemFontOfSize
    echoLabel.font = [UIFont boldSystemFontOfSize:10];
    //设置文字颜色
    echoLabel.textColor = [UIColor redColor];
    //设置文字位置
    echoLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:echoLabel];
    [self showScrowText:@"..."];
       
    //添加版本号
    posY =mainScreenBounds.size.height-30.0f;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15.0, posY, mainScreenBounds.size.width, 20.0)];
    title.text = version;
    //设置字体:粗体，正常的是 SystemFontOfSize
    title.font = [UIFont boldSystemFontOfSize:15];
    //设置文字颜色
    title.textColor = [UIColor whiteColor];
    //设置文字位置
    title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:title];
    
}

-(void)doCert:(long)_Tag
{
    //UIButton *button = sender;
    NSInteger nTag = _Tag;
    
    [self addGLView:nTag];
}

-(void)addGLView:(long)nTag
{
    //APP访问SDK示例
    UIWindow * pRootwindow = [[[UIApplication sharedApplication] delegate] window];
    CGRect mainScreenBounds =[[UIScreen mainScreen] bounds];
    
    //创建并显示SDKEaglView
    if(s_pSDKEaglView == nullptr)
    {
        s_pSDKEaglView = [SDKEAGLView createEAGLView:mainScreenBounds window:pRootwindow];
    }
    else
    {
        //如果已创建则可直接显示
        [SDKEAGLView setHidden:false window:pRootwindow];
    }
    
    [s_pSDKEaglView setSDKDelegate:self];
    
    [SDKEAGLView launchKeyboard];
}


-(void)notifyKeyInput:(const char *)userInput
{
    [self showScrowText:[NSString stringWithUTF8String:userInput]];
}

//证书相关操作
-(void) notifyApp:(const char*)pJson{
    NSLog(@"json = %s", pJson);
    
}

-(void)alertView:(NSString*) pMsg
{
    NSString *title =@"系统提示";
    
    NSString *cancelTitle =@"确定";
    
    UIAlertView *av =[[UIAlertView alloc] initWithTitle:title message:pMsg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    av.tag =100;
    [av show];
    
}


-(void)changeBtnStatus:(UIButton*)btn isSelected:(bool)isSelected{
    if(isSelected){
        [btn setBackgroundColor:[UIColor blueColor]];
    }else{
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor whiteColor]];
    }
}

-(CGSize)sizeForNoticeTitle:(NSString*)text font:(UIFont*)font maxSize:(CGSize)maxSize{
    /*CGRect screen = [UIScreen mainScreen].bounds;
     CGFloat maxWidth = screen.size.width;
     CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);*/
    
    CGSize textSize = CGSizeZero;
    // iOS7以后使用boundingRectWithSize，之前使用sizeWithFont
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        // 多行必需使用NSStringDrawingUsesLineFragmentOrigin，网上有人说不是用NSStringDrawingUsesFontLeading计算结果不对
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
        NSStringDrawingUsesFontLeading;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByCharWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
        
        CGRect rect = [text boundingRectWithSize:maxSize
                                         options:opts
                                      attributes:attributes
                                         context:nil];
        textSize = rect.size;
    }
    else{
        textSize = [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    }
    
    return textSize;
}

-(void)showScrowText:(NSString*)content{
    CGRect mainScreenBounds =[[UIScreen mainScreen] bounds];
    
    if(g_ServerEchoScrollView){
        [g_ServerEchoScrollView removeFromSuperview];
        g_ServerEchoScrollView = nil;
    }
    
    CGFloat posY =380;
    CGFloat sroW = mainScreenBounds.size.width-40;
    CGFloat sroH =mainScreenBounds.size.height -400;
    
    g_ServerEchoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, posY, sroW, sroH)];
    [g_ServerEchoScrollView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *label = [[UILabel alloc] init];
    //CGSize s = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(310, 1000)  lineBreakMode:UILineBreakModeWordWrap];//求文本的大小
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:content];
    label.attributedText = attrStr;
    NSRange range = NSMakeRange(0, attrStr.length);
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];   // 获取该段attributedString的属性字典
    // 计算文本的大小
    UIFont* _font =[UIFont systemFontOfSize:20];
    CGSize maxSize = CGSizeMake(sroW-8, CGFLOAT_MAX);
    /*CGSize s = [content boundingRectWithSize:maxSize // 用于计算文本绘制时占据的矩形块
     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
     attributes:dic        // 文字的属性
     context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil*/
    
    CGSize s = [self sizeForNoticeTitle:content font:_font maxSize:maxSize];
    
    NSLog(@"w = %f", s.width);
    NSLog(@"h = %f", s.height);
    
    label.font =_font;//不能少这句话，与上边的字大小一致
    //int cnt= s.height;
    label.frame =CGRectMake(4, 4, s.width, s.height);//这里要计算出label的frame大小，能够完全显示所有字符。
    label.text =content;
    label.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    
    g_ServerEchoScrollView.contentSize = label.frame.size;//这里赋值label的frame大小，以支持滚动浏览。
    [g_ServerEchoScrollView addSubview:label];
    [label release];
    
    [self.view addSubview:g_ServerEchoScrollView];
    [g_ServerEchoScrollView release];
}


@end
