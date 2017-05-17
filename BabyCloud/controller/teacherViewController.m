//
//  teacherViewController.m
//  YSTParentClient
//
//  Created by apple on 15/6/30.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "teacherViewController.h"
#import "HttpService.h"
#import "MobClick.h"
#import "MBProgressHUD.h"
#import "UMSocialControllerService.h"
#import "UMSocial.h"
#import "UMSocialScreenShoter.h"
#import "tutorialView.h"


@interface teacherViewController ()<UIWebViewDelegate, tutorialViewDelegate>
@property(nonatomic) UIWebView *webArea;
@property(nonatomic) tutorialView *tutorialV;
@end

@implementation teacherViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"班级管理"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"班级管理"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@-classManagementSectionNew", [HttpService getInstance].userId]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"班级管理";
    
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _webArea = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65)];
    
    [self.view addSubview:_webArea];
    _webArea.delegate = self;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstEnterTeacher"])
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        _tutorialV = [[tutorialView alloc] initWithFrame:self.view.bounds cover:@"class_tuto@2x" btnImg:@"tutorial_btn@2x"];
        _tutorialV.delegate = self;
        [self.view addSubview:_tutorialV];
    }
    else
    {
        NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
        NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_server.do?userid=%@&lat=%@&lon=%@", [HttpService getInstance].ystServerUrl, [HttpService getInstance].userId, latitude, longitude];
        
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
        [_webArea loadRequest:req];
    }
}

- (void)onConfirm
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstEnterTeacher"];
    [_tutorialV removeFromSuperview];
    _tutorialV = nil;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    
    NSString *uri = [NSString stringWithFormat:@"%@/app_server.do?userid=%@&lat=%@&lon=%@", [HttpService getInstance].ystServerUrl, [HttpService getInstance].userId, latitude, longitude];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
    [_webArea loadRequest:req];
}

- (void)onBack
{
    if ([_webArea canGoBack])
    {
        [_webArea goBack];
    }
    else
    {
        _webArea.delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中...";
    
#if 0
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
#endif
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (title && title.length > 0) {
        UILabel *titleView = (UILabel*)self.navigationItem.titleView;
        titleView.text = title;
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",[error description]);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSArray *componentArray = [[[request URL] absoluteString] componentsSeparatedByString:@":"];
    
    if (componentArray != nil) {
        
        NSString *functionName = componentArray[0];
        
        if ([functionName isEqualToString:@"oninvite"] && ([componentArray count] == 2)) {
            
            NSString *title = [NSString stringWithFormat:@"幼视通邀请码:%@", componentArray[1]];
            NSString *content = @"点击下载APP,注册登录后,点击'加入班级',输入邀请码后等待老师批准";
            
            [UMSocialData defaultData].extConfig.title = title;
            [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = content;
            [UMSocialData defaultData].extConfig.wechatSessionData.shareText = content;
            [UMSocialData defaultData].extConfig.qqData.shareText = content;
            
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://mp.weixin.qq.com/s?__biz=MzA5MDYwODk5OA==&mid=208094697&idx=1&sn=b551cc8b7eeb49d87fdb3f8ae891aa5d&scene=18#wechat_redirect";
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://mp.weixin.qq.com/s?__biz=MzA5MDYwODk5OA==&mid=208094697&idx=1&sn=b551cc8b7eeb49d87fdb3f8ae891aa5d&scene=18#wechat_redirect";
            
            [UMSocialData defaultData].extConfig.qqData.url = @"http://mp.weixin.qq.com/s?__biz=MzA5MDYwODk5OA==&mid=208094697&idx=1&sn=b551cc8b7eeb49d87fdb3f8ae891aa5d&scene=18#wechat_redirect";
            
            NSArray *mediaArray = [NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToTencent, nil];
            
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"55306795fd98c58930000c67"
                                              shareText:nil
                                             shareImage:[UIImage imageNamed:@"morentouxing1"]
                                        shareToSnsNames:mediaArray
                                               delegate:nil];
        }
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"teacherViewController dealloc");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
