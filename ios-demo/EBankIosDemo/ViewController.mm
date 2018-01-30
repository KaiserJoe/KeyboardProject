//
//  ViewController.m
//  SafeModuleIosDemo
//
//  Created by liuyong on 16/1/6.
//  Copyright © 2016年 liuyong. All rights reserved.
//

#import "ViewController.h"
#include <string>
#import "SBJson/SBJson.h"

#import <mach/mach.h>

#import "AFNetworking.h"


#import "TDCodeReturn.h"

#import "BKSRequestData.h"
#import "CertBtnsView.h"

//密码
NSString* g_szPwd;
NSString* g_szSignTargtParam;
int mBtnTag = -1;


UIScrollView* g_ServerEchoScrollView =nil;

//多dn
#define DN_1 @"CN=GDCA@test@412702199404162322@138,OU=Individual-1,OU=CFCA,O=CFCA ACS SM2 CA,C=CN"
#define DN_2 @"CN=GDCA@test@412702199404162322@137,OU=Individual-1,OU=CFCA,O=CFCA ACS SM2 CA,C=CN"
NSString* g_szDN;

//操作锁
bool sigleOperLock = false;

//版本号
#define version @"版本号:1.8.0"

#import <EBankIos/SDKEAGLView.h>
#import "SBJson/SBJson.h"

std::string g_szAlertText ="";
//全局实例
static SDKEAGLView * s_pSDKEaglView = nullptr;

#define init_key_flag_key @"init_key_flag_"

#define download_cert_metho_name @"downloadX509"
#define sign_metho_name @"signMsg"
#define change_pin_metho_name @"changePIN"
#define get_pubkey_metho_name @"getPubKey"
#define sign_bin_metho_name @"signBin"
#define export_key_metho_name @"exportKey"
#define import_key_metho_name @"importKey"
#define select_x509_metho_name @"selectX509"
#define gm_ssl_metho_name @"gmSSL"

@interface ViewController (){
     int _user_cert_tag;//0:未下载 1:已激活
}
@end

@implementation ViewController

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

-(void)changeBtnStatus:(UIButton*)btn isSelected:(bool)isSelected{
    if(isSelected){
        //[btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
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
        UIFont* _font =[UIFont systemFontOfSize:10];
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
        label.backgroundColor =[UIColor clearColor];
        
        g_ServerEchoScrollView.contentSize = label.frame.size;//这里赋值label的frame大小，以支持滚动浏览。
        [g_ServerEchoScrollView addSubview:label];
        [label release];
        
        [self.view addSubview:g_ServerEchoScrollView];
        [g_ServerEchoScrollView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //添加背景
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg.jpg"]]];
    //添加标题背景
    CGRect mainScreenBounds =[[UIScreen mainScreen] bounds];

    //创建图层
    CALayer *layer=[CALayer layer];
    //设置图层的属性
    NSInteger color = 0xffdfdfdf;
    UIColor* pcolor = [self colorWithHex:color alpha:1];
    layer.backgroundColor=pcolor.CGColor;
    layer.bounds=CGRectMake(0, 0, mainScreenBounds.size.width, 100);//130
    layer.position = CGPointMake(mainScreenBounds.size.width/2, 0);
    [self.view.layer addSublayer:layer];
    
    //添加标题
     UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, mainScreenBounds.size.width, 50.0)];
     label1.text = @"手机盾插件演示";
    //设置字体:粗体，正常的是 SystemFontOfSize
    label1.font = [UIFont boldSystemFontOfSize:20];
    //设置文字颜色
    label1.textColor = [UIColor whiteColor];
    //设置文字位置
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    //[label1 release];
    
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"CN=051@bkra201603261719@120161206190700@1,OU=Individual-1,OU=Local RA,O=CFCA TEST CA,C=CN" forKey:@"2101_dn"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString* key = [NSString stringWithFormat:@"%@%@",init_key_flag_key,g_szDN];
    bool isInitKey =[[NSUserDefaults standardUserDefaults] boolForKey:key];
    
    // btn的tag都从100开始，100 101 102 103···
    CertBtnsView *certBtnView1 = [[CertBtnsView alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width - 40, 190)];
    
    [certBtnView1 sectionTitle:@"插件功能类"
                      rowCount:3
                     btnTitles:@[@"下载证书",@"签名",@"修改密码",@"登录",@"导出证书",@"导入证书",@"查询证书",@"查询公钥",@"吊销"]];
    [self.view addSubview:certBtnView1];
    //吊销禁用
    UIButton* pBtn =(UIButton*)[certBtnView1 getBtnByTag:108];
    [pBtn setEnabled:FALSE];
    [pBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pBtn setBackgroundColor:[UIColor grayColor]];
    
    certBtnView1.viewBtnHandle = ^(UIButton *btn) {
        long nTag =btn.tag;
        NSLog(@"certBtnView1.viewBtnHandle::__1__ %ld",nTag);
        
        if(sigleOperLock){
            return;
        }
        sigleOperLock = true;
        
        mBtnTag = nTag;
        
        NSString* key = [NSString stringWithFormat:@"%@%@",init_key_flag_key,g_szDN];
        bool isInitKey =[[NSUserDefaults standardUserDefaults] boolForKey:key];
        
        if(mBtnTag == 100){
            //下载证书
            NSString* key = [NSString stringWithFormat:@"%@%@",init_key_flag_key,g_szDN];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self doCert:8];
        }else if(mBtnTag == 105){
            //导入私钥
            [self doCert:5];
        }else{
            if(isInitKey){
                if(mBtnTag == 101||
                   mBtnTag == 102||
                   mBtnTag == 103||
                   mBtnTag == 104){
                    //获取公钥
                    [self doCert:0];
                }else if(mBtnTag == 106){
                    //证书查询
                    [self doCert:9];
                }else if(mBtnTag == 107){
                    //查询公钥
                    [self doCert:0];
                }
            }else
            {
               [self alertView:[NSString stringWithFormat:@"请先下载证书!"]];
            }
        }
    };
    
    // btn的tag都从100开始，100 101 102 103···
    CertBtnsView *certBtnView2 = [[CertBtnsView alloc] initWithFrame:CGRectMake(20, 260, self.view.frame.size.width - 40, 90)];
    [certBtnView2 sectionTitle:@"辅助类"
                      rowCount:2
                     btnTitles:@[@"dn1",@"dn2"]];
    [self.view addSubview:certBtnView2];
    //默认选择
    pBtn =(UIButton*)[certBtnView2 getBtnByTag:100];
    [self changeBtnStatus:pBtn isSelected:YES];
    g_szDN =DN_1;
    
    certBtnView2.viewBtnHandle = ^(UIButton *btn) {
        long nTag =btn.tag;
        NSLog(@"certBtnView2.viewBtnHandle::__1__ %ld",nTag);
        
        UIButton* pBtn =(UIButton*)[certBtnView2 getBtnByTag:100];
        [self changeBtnStatus:pBtn isSelected:NO];
        
        pBtn =(UIButton*)[certBtnView2 getBtnByTag:101];
        [self changeBtnStatus:pBtn isSelected:NO];
        
        if(nTag == 100){
            pBtn =(UIButton*)[certBtnView2 getBtnByTag:100];
            [self changeBtnStatus:pBtn isSelected:YES];

            g_szDN =DN_1;
        }else{
            pBtn =(UIButton*)[certBtnView2 getBtnByTag:101];
            [self changeBtnStatus:pBtn isSelected:YES];
            
            g_szDN =DN_2;
        }
        NSLog(@"g_szDN::%@",g_szDN);
    };
    
    //服务器数据回显
    CGFloat posY =340;//mainScreenBounds.size.height-80.0f;
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
    //[g_ServerEchoLabel setText:@"你好,你好 你好,你好 你好,你好 你好,你好 你好,你好 你好,你好 你好,你好"];
       
    //添加版本号
    posY =mainScreenBounds.size.height-30.0f;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(20.0, posY, mainScreenBounds.size.width, 50.0)];
    title.text = version;
    //设置字体:粗体，正常的是 SystemFontOfSize
    title.font = [UIFont boldSystemFontOfSize:10];
    //设置文字颜色
    title.textColor = [UIColor whiteColor];
    //设置文字位置
    title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:title];
    //[label1 release];
    
    
    //注册消息监听 for证书
    //[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(hiddensdkview) name:@"back" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(alertViewCert:) name:@"alert"
                                               object:nil];
}

- (void)request:(long)nTag {
    //2101:申请,12002:密码保存,2501:冻结,2601:解冻,2701:更新,2702:补发,2901:吊销,6666:dn查询
    //NSArray *pahtArr = @[@"2101",@"12002",@"2501",@"2601",@"2701",@"2702",@"2901",@"6666"];
    
    [self showLoading];
    [self showScrowText:@"开始联网"];
    
    NSDictionary *dic = [NSDictionary dictionary];
    switch (nTag) {
        case 101:{
            
            NSDateFormatter * dateF = [[ NSDateFormatter alloc]init];
            dateF.dateFormat        = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:nil];
            NSString * day          = [dateF stringFromDate:[NSDate date]];
            dateF.dateFormat        = [NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:nil];
            NSString * time         = [dateF stringFromDate:[NSDate date]];

            NSString* message=[NSString stringWithFormat:@"[{\"name\":\"操作\",\"value\":\"签名验签\"}, {\"name\":\"日期\", \"value\":\"%@\"}, {\"name\":\"时间\", \"value\":\"%@\"}, {\"name\":\"流水号\", \"value\":\"282911\"}]",day,time];
            
            dic = @{@"methodName":sign_metho_name,
                    @"P":g_szPwd,
                    @"message":message,
                    @"dn":g_szDN};
            
        }
            break;
        case 102: {
            
            dic = @{@"methodName":change_pin_metho_name,
                    @"P":g_szPwd,
                    @"dn":g_szDN};
            
        }
            break;
        /*case 103:{
            NSData *jsonData = [g_szSignTargtParam dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                    error:&err];
        }
            break;*/
        case 103:{
            //sign_bin_metho_name
            dic = @{@"methodName":@"login",
                    @"P":g_szPwd,
                    @"dn":g_szDN};
            
        }
            break;
        case 104:{
            
            dic = @{@"methodName":export_key_metho_name,
                    @"P":g_szPwd,
                    @"dn":g_szDN};
            
        }
            break;
        default:
            break;
    }

    BKSRequestData *req = [[BKSRequestData alloc] init];
    [req requestWithParam:dic
                      tag:nTag
                     path:@""
                  success:^(id responseString, BOOL isOk,NSInteger index) {
                      
                     NSLog(@"ViewController-request-res:: %@ index::%d  %d",responseString,index,isOk);
                     NSArray *nameArr = @[@"签名",@"修改密码",@"登录",@"导出证书"];
                      
                     [self removeLoading];
                      
                      if(isOk){
                          //获取签名
                          g_szAlertText =[responseString UTF8String];
                          //修改服务器回显
                          [self showScrowText:responseString];
                          
                          //报文回传sdk
                          if(mBtnTag == 101||
                             mBtnTag == 102||
                             mBtnTag == 103||
                             mBtnTag == 104){
                            [self doCert:index-100];
                          }
                      }else{
                         
                          [self alertView:[NSString stringWithFormat:@"%@通信失败,请重新尝试!/%@",nameArr[index % 100],responseString]];
                      }
                  }];
    
}

-(void)doCert:(long)_Tag
{
    //UIButton *button = sender;
    NSInteger nTag = _Tag;
    
    [self addGLView:nTag];
}


-(void)alertView:(NSString*) pMsg
{
    NSString *title =@"系统提示";
    //NSString *message = [NSString stringWithUTF8String:g_szAlertText.c_str()];
    NSString *cancelTitle =@"确定";
    
    UIAlertView *av =[[UIAlertView alloc] initWithTitle:title message:pMsg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    av.tag =100;
    [av show];
    //[av release];
}


-(void)showInputInfoView:(NSInteger )tag{
    NSString *title =@"用户信息录入";
    //NSString *message = [NSString stringWithUTF8String:g_szAlertText.c_str()];
    NSString *btnTitle =@"确定";
    
    UIAlertView *av =[[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:btnTitle, nil];
    av.tag =tag;
    
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    UITextField *applientIdField = [av textFieldAtIndex:0];
    applientIdField.placeholder = @"请输入用户姓名";
    
    UITextField *dnField = [av textFieldAtIndex:1];
    [dnField setSecureTextEntry:NO];
    dnField.placeholder = @"请输入用户ID";
    
    [av show];
    //[av release];
}

-(void)showInputPwdView{
    NSString *title =@"证书密码录入";
    //NSString *message = [NSString stringWithUTF8String:g_szAlertText.c_str()];
    NSString *btnTitle =@"确定";
    
    UIAlertView *av =[[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:btnTitle, nil];
    av.tag =102;
    
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    UITextField *pwdField = [av textFieldAtIndex:0];
    
    [pwdField setSecureTextEntry:YES];
    pwdField.placeholder = @"请输入证书密码";
    
    UITextField *pwdField2 = [av textFieldAtIndex:1];
    [pwdField2 setSecureTextEntry:YES];
    pwdField2.placeholder = @"请再次输入证书密码";

    
    [av show];
    //[av release];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSInteger nTag = alertView.tag;
    sigleOperLock =false;
    NSLog(@"*****************alertViewCert-sigleOperLock***********::%d",sigleOperLock);
}

-(void)report_memory{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS )
    {
        //printf("Memory vm : %u\n",info.virtual_size);
        //printf("Memory in use (in bytes): %u b\n", info.resident_size);
        //printf("Memory in use (in k-bytes): %f k\n", info.resident_size / 1024.0);
        printf("Memory in use (in m-bytes): %f m\n", info.resident_size / (1024.0 * 1024.0));
    }
    else
    {
        printf("Error with task_info(): %s\n", mach_error_string(kerr));
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)dealloc {
    [super dealloc];
}*/

//证书相关操作
-(void) notifyApp:(const char*)pJson{
    NSLog(@"json = %s", pJson);
    
    SBJsonParser* parse =[[SBJsonParser alloc]init];
    NSDictionary *dicRoot = [ parse objectWithString:[NSString stringWithUTF8String:pJson]];
    
    NSString *methodName = [dicRoot objectForKey:@"methodName"];
    NSString *code = [dicRoot objectForKey:@"code"];
    NSString *message = [dicRoot objectForKey:@"message"];
    NSLog(@"methodName = %@", methodName);
    NSLog(@"code = %@", code);
    NSLog(@"message = %@", message);
    const char* pMethodName = [methodName UTF8String];

    //是否显示调用插件的提示
    bool showTip =true;
    if(pMethodName == NULL){
        g_szAlertText = "参数解析失败";
    }else if(strcmp([gm_ssl_metho_name UTF8String], pMethodName) == 0 &&strcmp("0000", [code UTF8String]) == 0){
        //透传数据
    
        
    }else if(strcmp([get_pubkey_metho_name UTF8String], pMethodName) == 0 &&strcmp("0000", [code UTF8String]) == 0){
        if(mBtnTag ==107){
            //公钥查询
            g_szAlertText = [message UTF8String];
        }else{
            //获取公钥
            showTip = false;
            
            g_szPwd = [NSString stringWithString:message];
            [self request:mBtnTag];
        }
        
    }else if(strcmp([download_cert_metho_name UTF8String], pMethodName) == 0){
        //下载证书
        if(strcmp("0000", [code UTF8String]) == 0){
            NSString* key = [NSString stringWithFormat:@"%@%@",init_key_flag_key,g_szDN];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        g_szAlertText = [message UTF8String];
    }else if(strcmp([sign_metho_name UTF8String], pMethodName) == 0){
        //签名
        g_szAlertText = [message UTF8String];
    }else if (strcmp([change_pin_metho_name UTF8String], pMethodName) == 0){
        //修改密码
        g_szAlertText = [message UTF8String];
    }else if(strcmp([sign_bin_metho_name UTF8String], pMethodName) == 0){
        //登录
        g_szAlertText = [message UTF8String];
    }else if(strcmp([export_key_metho_name UTF8String], pMethodName) == 0){
        //导出私钥
        g_szAlertText = [message UTF8String];
    }else if(strcmp([import_key_metho_name UTF8String], pMethodName) == 0&&strcmp("0000", [code UTF8String]) == 0){
        
        NSString* key = [NSString stringWithFormat:@"%@%@",init_key_flag_key,g_szDN];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//         g_szAlertText = [message UTF8String];
                 g_szAlertText = "导入成功，请勿再使用原终端操作!";
        
    }else if(strcmp([select_x509_metho_name UTF8String], pMethodName) == 0){
        //证书查询
        g_szAlertText = [message UTF8String];
    }else{
        NSLog(@"功能按钮 = %@", @"methodName error!!!!");
        g_szAlertText = [message UTF8String];
    }
    
    //隐藏当前SDKEAGLView,弹提示
    UIWindow * pRootwindow = [[[UIApplication sharedApplication] delegate] window];
    [SDKEAGLView setHidden:true window:pRootwindow];
    
    if(showTip){
        NSDictionary* dic =[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:1] , @"tag",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"alert" object:nil userInfo:dic];
    }
    
    //[parse release];
    
    //此处很重哟！！！
    delete pJson;
}

-(void)hiddensdkview
{
    [self removeObserver];
}

-(void)buttonPressed:(id)sender
{
    [self hiddensdkview];
}

-(void)addGLView:(long)nTag
{
    //CGFloat scale = [[UIScreen mainScreen] scale];
    //scale = scale>=2?2:1;
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
        //[pRootwindow bringSubviewToFront:s_pSDKEaglView];
    }
    
    [s_pSDKEaglView setSDKDelegate:self];
    
    //dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12/*延迟执行时间*/ * NSEC_PER_SEC));
    //dispatch_after(delayTime, dispatch_get_main_queue(), ^{
    
    if ((nTag > 0 && nTag<8) && (nTag != 4 && nTag != 5) && g_szAlertText.length() != 0)
    {
        NSError *erro;
        NSDictionary * dic =  [NSJSONSerialization JSONObjectWithData:[[NSString stringWithCString:g_szAlertText.c_str()
                                                                                          encoding:NSUTF8StringEncoding]
                                                                       dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingMutableContainers error:&erro];
        
        [dic setValue:@"0" forKey:@"mode"];
        
        
        g_szAlertText = [[[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                                       options:NSJSONWritingPrettyPrinted error:&erro]
                                              encoding:NSUTF8StringEncoding] UTF8String];
    }
    
    //根据不同标签，访问不同api
    switch (nTag) {
        case 0:
        {
            //获取公钥
             //NSString* pJson =@"{\"methodName\":\"getPubKey\",\"dn\":\"getPubKey\"}";
             NSString* szParam=[NSString stringWithFormat:@"{\"methodName\":\"getPubKey\",\"dn\":\"%@\"}",g_szDN];
            [SDKEAGLView nativeSdkFuntion:[szParam UTF8String] mode:0];
            
        }
            break;
        case 1:
        {
            [SDKEAGLView nativeSdkFuntion:g_szAlertText.c_str() mode:0];
        }
            break;
        case 2:
        {
             //g_szAlertText ="{ \"methodName\": \"changePIN\", \"orgSig\": \"cc68a1d02f128cd0829c771b7fabf40cc6cbd718e79c07ec46ba82a7ac074775c7793d3d2d06df27bed844eca8a53d4619d33a360e568af08236a75733d779cf\", \"message\":\"[ {\\\"name\\\":\\\"操作\\\", \\\"value\\\":\\\"修改密码\\\"}, {\\\"name\\\":\\\"日期\\\", \\\"value\\\":\\\"2017-02-24\\\"}, {\\\"name\\\":\\\"时间\\\", \\\"value\\\":\\\"20:24\\\"}, {\\\"name\\\":\\\"流水号\\\", \\\"value\\\":\\\"594501\\\"} ]\\n\",\"userID\": \"userID\" }";
            [SDKEAGLView nativeSdkFuntion:g_szAlertText.c_str() mode:0];
        }
            break;
        case 3:
        {
             //g_szAlertText ="{ \"methodName\": \"signMsg\", \"orgSig\": \"cc68a1d02f128cd0829c771b7fabf40cc6cbd718e79c07ec46ba82a7ac074775c7793d3d2d06df27bed844eca8a53d4619d33a360e568af08236a75733d779cf\", \"message\":\"[ {\\\"name\\\":\\\"操作\\\", \\\"value\\\":\\\"签名\\\"}, {\\\"name\\\":\\\"日期\\\", \\\"value\\\":\\\"2017-02-24\\\"}, {\\\"name\\\":\\\"时间\\\", \\\"value\\\":\\\"20:24\\\"}, {\\\"name\\\":\\\"流水号\\\", \\\"value\\\":\\\"594501\\\"} ]\\n\",\"userID\": \"userID\" }";
            [SDKEAGLView nativeSdkFuntion:g_szAlertText.c_str() mode:0];
        }
            break;
        case 4:{
            //生成二维码
            //NSString* pJson =@"{\"methodName\":\"qrCreate\",\"type\":\"pubKey\"}";
            //[SDKEAGLView nativeSdkFuntion:[pJson UTF8String] mode:0];
            //导出私钥
            [SDKEAGLView nativeSdkFuntion:g_szAlertText.c_str() mode:0];
        }
            break;
        case 5:{
            //扫码
           // NSString* pJson =@"{\"methodName\":\"qrRead\"}";
            //[SDKEAGLView nativeSdkFuntion:[pJson UTF8String] mode:0];
            //导入私钥
             NSString* szParam=[NSString stringWithFormat:@"{\"methodName\":\"importKey\"}"];
            [SDKEAGLView nativeSdkFuntion:[szParam UTF8String] mode:0];
        }
            break;
        case 6:{
            [SDKEAGLView nativeSdkFuntion:g_szAlertText.c_str() mode:0];
        }
            break;
        case 7:{
            [SDKEAGLView nativeSdkFuntion:g_szAlertText.c_str() mode:0];
        }
            break;
        case 8:{
            NSString* szParam=[NSString stringWithFormat:@"{\"methodName\":\"downloadX509\",\"dn\":\"%@\"}",g_szDN];

            [SDKEAGLView nativeSdkFuntion:[szParam UTF8String] mode:0];
        }
            break;
        case 9:{
            NSString* szParam=[NSString stringWithFormat:@"{\"methodName\":\"selectX509\",\"dn\":\"%@\"}",g_szDN];
            
            [SDKEAGLView nativeSdkFuntion:[szParam UTF8String] mode:0];
        }
            break;
        case 10:{
            //查询密码试错剩余次数
             NSString* szParam=[NSString stringWithFormat:@"{\"methodName\":\"getLeftNum\",\"dn\":\"%@\"}",g_szDN];
            [SDKEAGLView nativeSdkFuntion:[szParam UTF8String] mode:0];
        }
            break;
        case 11:
        {
            //模拟app访问uap
            //明文演示
            //本地验签app私钥
            /*const char* _pAppD ="efe75f7c31c21f1948584de336e52ba0d03cd5b395e9cf9ea5a9b308d367c641";
            NSString* _pMsg =@"{\"data\":[{\"name\":\"付款账号\",\"value\":\"1000 2024 2800 0117\"},{\"name\":\"收款人\",\"value\":\"林海思\"},{\"name\":\"收款账号\",\"value\":\"1001 2100 9300 0110\"},{\"name\":\"手机号\",\"value\":\"\"},{\"name\":\"转账金额\",\"value\":\"1.00 CNY\",\"unit\":\"CNY\"},{\"name\":\"金额大写\",\"value\":\"壹圆整 \"},{\"name\":\"附言\",\"value\":\"\"},{\"name\":\"附言2\",\"value\":\"\"},{\"name\":\"附言3\",\"value\":\"\"}]}";
            //const char* _pMsg ="123";
            
            NSString * m_pMethodName =@"simulateApp";
            NSString * m_pDN = [[NSUserDefaults standardUserDefaults] objectForKey:@"2101_dn"];
            
            //NSString* pJson =[self getJson2:m_pMethodName pMsg:[NSString stringWithFormat:@"{\"appD\":\"%s\",\"content\":%@,\"sep7\":\"%s\"}",_pAppD,_pMsg,g_szAlertText.c_str()] pUrl:@"http://www.bankeys.com:7430/uap" dn:m_pDN];//27404
            //[SDKEAGLView nativeSdkFuntion:[pJson UTF8String] mode:0];*/
        }
            break;
        default:
            break;
    }
    
    // });
    
}

-(void)alertViewCert:(NSNotification*)notify
{
    NSDictionary* dic =[notify userInfo];
    NSNumber* tag=[dic objectForKey:@"tag"];
    int nTag = [tag intValue];
    
    
    NSString *title =@"系统提示";
    NSString *message = [NSString stringWithUTF8String:g_szAlertText.c_str()];
    NSString *cancelTitle =@"确定";
    
    UIAlertView *av =[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    [av setTag:nTag];
    [av show];
    //[av release];
}

-(void)removeObserver{
    [[NSNotificationCenter
      defaultCenter] removeObserver:self name:@"back" object:nil];
    
    [[NSNotificationCenter
      defaultCenter] removeObserver:self name:@"alert" object:nil];
}


UIActivityIndicatorView* activityIndicator = nil;
-(void)showLoading{
    if(activityIndicator != nil){
        return;
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:self.view.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

-(void)removeLoading{
    if(activityIndicator == nil){
        return;
    }
    [activityIndicator stopAnimating];
    activityIndicator=nil;
}

@end
