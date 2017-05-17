//
//  schoolActivityViewController.m
//  YSTParentClient
//
//  Created by apple on 15-1-13.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "schoolActivityViewController.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "MobClick.h"
#import "MBProgressHUD.h"

@interface schoolActivityViewController()<UIWebViewDelegate>
@property(nonatomic) UIWebView *webArea;
@end

@implementation schoolActivityViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    CustomURLCache *urlCache = [[CustomURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                                 diskCapacity:100 * 1024 * 1024
                                                                     diskPath:nil
                                                                    cacheTime:0];
    [CustomURLCache setSharedURLCache:urlCache];
    */
     
    CGRect clientRect = [UIScreen mainScreen].bounds;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"校园风采";
    
    self.navigationItem.titleView = titleLable;

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _webArea = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65)];
    
    [self.view addSubview:_webArea];
    _webArea.delegate = self;
    
    NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_schoolStyle.do?schoolid=%@", CLU_SERVER_IP, CLU_SERVER_PORT, [HttpService getInstance].userExtentInfo.schoolId];
    
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
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",[error description]);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    /*
    CustomURLCache *urlCache = (CustomURLCache *)[NSURLCache sharedURLCache];
    [urlCache removeAllCachedResponses];
    */
}

- (void)dealloc
{
    
    NSLog(@"schoolActivityViewController dealloc");
}


@end
