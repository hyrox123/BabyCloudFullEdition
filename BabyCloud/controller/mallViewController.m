//
//  mallViewController.m
//  YSTParentClient
//
//  Created by apple on 15/8/21.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "mallViewController.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "MobClick.h"
#import "CustomURLCache.h"
#import "MBProgressHUD.h"
#import "utilityFunction.h"
#import <AlipaySDK/AlipaySDK.h>

@interface mallViewController ()<UIWebViewDelegate>
@property(nonatomic) UIWebView *webArea;
@end

@implementation mallViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"钱包"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"钱包"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"钱包";
    
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
    
    NSString *uri = [NSString stringWithFormat:@"%@/app_shopIndex.do?userid=%@&lat=%@&lon=%@", [HttpService getInstance].shopUrl, [HttpService getInstance].userId, latitude, longitude];
    
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

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSArray *componentArray = [[[request URL] absoluteString] componentsSeparatedByString:@":"];
    
    if (componentArray != nil) {
        
        NSString *functionName = componentArray[0];
        
        if ([functionName isEqualToString:@"onpay"] && ([componentArray count] == 5)) {
            
            NSString *orderId = componentArray[1];
            NSString *orderNo = componentArray[2];
            NSString *price = componentArray[4];
            NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:componentArray[3] options:0];
            NSString* productionName = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
            
            NSString *notifyUrl = [NSString stringWithFormat:@"%@/app_buyOrderSuccess.do?orderid=%@",[HttpService getInstance].shopUrl, orderId];
            
            NSMutableDictionary *productionInfo = [NSMutableDictionary new];
            [productionInfo setValue:orderNo forKey:@"productionId"];
            [productionInfo setValue:productionName forKey:@"productionName"];
            [productionInfo setValue:productionName forKey:@"productionDesc"];
            [productionInfo setValue:price forKey:@"productionPrice"];
            [productionInfo setValue:notifyUrl forKey:@"notifyUrl"];
            
            [utilityFunction sellProduction:productionInfo andblock:^(NSDictionary *resutDict) {
               
                NSString *status = resutDict[@"resultStatus"];
                
                if ([status isEqualToString:@"9000"]) {
                    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:notifyUrl]];
                    [_webArea loadRequest:req];
                }
                else
                {
                    NSString *reason = [NSString stringWithFormat:@"付款失败,错误码[%@]", status];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                                   message:reason
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
            }];
        }
    }
    
    return YES;
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
    NSLog(@"mallViewController dealloc");
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
