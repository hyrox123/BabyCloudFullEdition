//
//  campaignViewController.m
//  YSTParentClient
//
//  Created by apple on 15/6/10.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "campaignViewController.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "ProtoType.h"
#import "MBProgressHUD.h"
#import "UMSocialControllerService.h"
#import "UMSocial.h"
#import "UMSocialScreenShoter.h"
#import "KxMenu.h"

@interface campaignViewController ()<UIWebViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic) UIWebView *webArea;
@property(nonatomic) NSString *imgUploadPath, *imgCallbackFunc, *mp3CallbackFunc;
@end

@implementation campaignViewController


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
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"当前活动";
    
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"caidan"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _webArea = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65)];
    
    [self.view addSubview:_webArea];
    _webArea.delegate = self;
    
    NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];

    NSString *uri = [NSString stringWithFormat:@"%@/app_voteActivityList.do?userid=%@&?state=1&lat=%@&lon=%@&imei=%@", [HttpService getInstance].vasUrl, [HttpService getInstance].userId, latitude, longitude, [utilityFunction getUUID]];
    
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
        
        if ([functionName isEqualToString:@"onshare"] && ([componentArray count] == 3)) {
            
            NSString *url = [NSString stringWithFormat:@"%@/app_voteActivity.do?id=%@", [HttpService getInstance].vasUrl, componentArray[1]];
            
            NSData *nsdataFromBase64String = [[NSData alloc]
                                              initWithBase64EncodedString:componentArray[2] options:0];
            
            NSString *title = @"幼视通'文化城堡'活动";
            NSString *content = [[NSString alloc]
                                 initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
            
            
            [UMSocialData defaultData].extConfig.title = title;
            [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = content;
            [UMSocialData defaultData].extConfig.wechatSessionData.shareText = content;
            [UMSocialData defaultData].extConfig.qqData.shareText = content;
            
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            [UMSocialData defaultData].extConfig.qqData.url = url;
            
            NSArray *mediaArray = [NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToTencent, nil];
            
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"55306795fd98c58930000c67"
                                              shareText:nil
                                             shareImage:[UIImage imageNamed:@"morentouxing1"]
                                        shareToSnsNames:mediaArray
                                               delegate:nil];
        }
        else if([functionName isEqualToString:@"onupload"] && ([componentArray count] == 3))
        {
            _imgUploadPath = componentArray[1];
            _imgCallbackFunc = componentArray[2];
            
            UIActionSheet* mySheet = [[UIActionSheet alloc]
                                      initWithTitle:@"上传图片"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:@"拍照"
                                      otherButtonTitles:@"本地相册", nil];
            [mySheet showInView:self.view];
        }
    }
    
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex != [actionSheet cancelButtonIndex])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        
        if(buttonIndex == 0)
        {
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        }
        else
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        }
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)imagePickerController: (UIImagePickerController *)picker
didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage *srcImage = [info objectForKey: @"UIImagePickerControllerOriginalImage"];
    
    CGFloat rawW = srcImage.size.width;
    CGFloat rawH = srcImage.size.height;
    CGFloat dstW, dstH;
    
    if (rawW > rawH)
    {
        if (rawW > 1024)
        {
            dstW = 1024;
            dstH = (rawH/rawW)*1024;
        }
        else
        {
            dstW = rawW;
            dstH = rawH;
        }
    }
    else
    {
        if (rawH > 1024)
        {
            dstH = 1024;
            dstW = (rawW/rawH)*1024;
        }
        else
        {
            dstW = rawW;
            dstH = rawH;
        }
    }
    
    CGSize dstSize = {dstW, dstH};
    UIGraphicsBeginImageContext(dstSize);
    [srcImage drawInRect:CGRectMake(0, 0, dstSize.width, dstSize.height)];
    UIImage *dstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *picData = UIImageJPEGRepresentation(dstImage, 0.8);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"上传中...";
    
    [[HttpService getInstance] uploadImage:picData destUrl:_imgUploadPath block:^(NSString* url) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *funcN = [NSString stringWithFormat:@"%@(\'%@\');", _imgCallbackFunc, url];
        [_webArea stringByEvaluatingJavaScriptFromString:funcN];
    }];
}

- (void)showMenu:(UIButton *)sender
{
    NSMutableArray *menuItems = [NSMutableArray new];
    
    KxMenuItem *item1 = [KxMenuItem menuItem:@"当前活动"
                                      image:nil
                                     target:self
                                     action:@selector(onMenuItem:)];
    
    [menuItems addObject:item1];
    item1.index = 0;
   
    KxMenuItem *item2 = [KxMenuItem menuItem:@"往期活动"
                                      image:nil
                                     target:self
                                     action:@selector(onMenuItem:)];
    
    [menuItems addObject:item2];
    item2.index = 1;

    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake([UIScreen mainScreen].bounds.size.width-50, -20, 50, 20)
                 menuItems:menuItems];
}

-(void)onMenuItem:(id)sender
{
    UILabel *titleView = (UILabel*)self.navigationItem.titleView;
    NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    NSString *uri = @"";
    
    if (((KxMenuItem*)sender).index == 1)
    {
        uri = [NSString stringWithFormat:@"%@/app_voteActivityList.do?userid=%@&state=0&lat=%@&lon=%@", [HttpService getInstance].vasUrl, [HttpService getInstance].userId, latitude, longitude];
        
        titleView.text = @"往期活动";
        
    }
    else
    {
        uri = [NSString stringWithFormat:@"%@/app_voteActivityList.do?userid=%@&state=1&lat=%@&lon=%@", [HttpService getInstance].vasUrl, [HttpService getInstance].userId, latitude, longitude];
        
        titleView.text = @"当前活动";
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
    [_webArea loadRequest:req];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"campaignViewController dealloc");
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
