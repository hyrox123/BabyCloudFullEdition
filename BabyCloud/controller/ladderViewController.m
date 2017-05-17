//
//  ladderViewController.m
//  YSTParentClient
//
//  Created by apple on 15/9/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "ladderViewController.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "MobClick.h"
#import "CustomURLCache.h"
#import "MBProgressHUD.h"

@interface ladderViewController ()<UIWebViewDelegate>
@property(nonatomic) UIWebView *webArea;
@end

@implementation ladderViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"积分榜"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"积分榜"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"积分榜";
    
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _webArea = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65)];
    
    [self.view addSubview:_webArea];
    _webArea.delegate = self;
    
    NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    
    NSString *uri = [NSString stringWithFormat:@"%@/app_server/integral/top.do?userid=%@&lat=%@&lon=%@", [HttpService getInstance].ystServerUrl, [HttpService getInstance].userId, latitude, longitude];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"ladderViewController dealloc");
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
