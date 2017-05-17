//
//  loginViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-8.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "loginViewController.h"
#import "basePannelController.h"
#import "utilityFunction.h"
#import "loginView.h"
#import "registerViewController.h"
#import "resetPswViewController.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import <SMS_SDK/SMS_SDK.h>
#import "UITextField+Shake.h"
#import "RCIM.h"
#import "MobClick.h"

@interface loginViewController ()<loginViewDelegate>
@property(nonatomic) loginView *officialLoginView;
@property(nonatomic)  NSTimer *checkErrorTime;
@property(nonatomic)  BOOL skipIM;

- (void)onPressLoginBtn:(NSString*)userName passWd:(NSString*)userPsw;
@end

@implementation loginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    _officialLoginView.userNameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    _officialLoginView.pswField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPsw"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"登 录";

    self.navigationItem.titleView = titleLable;

    _officialLoginView = [[loginView alloc] initWithFrame:clientRect];
    [self.view addSubview:_officialLoginView];
    
    _officialLoginView.delegate = self;    
    [_officialLoginView.userNameField setBorderStyle:UITextBorderStyleNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onPressLoginBtn:(NSString*)userName passWd:(NSString*)userPsw
{
    if (userName.length == 0) {
        
        [_officialLoginView.userNameField shake:10
                                      withDelta:5.0f
                                          speed:0.04f
                                 shakeDirection:ShakeDirectionHorizontal];
        return;
    }
    
    if (userPsw.length == 0) {
        
        [_officialLoginView.pswField shake:10
                                 withDelta:5.0f
                                     speed:0.04f
                            shakeDirection:ShakeDirectionHorizontal];
        return;
    }
    
    
    _officialLoginView.userNameField.enabled = NO;
    _officialLoginView.pswField.enabled = NO;
    _officialLoginView.confirmBtn.enabled = NO;
    _officialLoginView.delegate = nil;
    _skipIM = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"登录中...";
    
    [[HttpService getInstance] userLogin:userName psw:userPsw andBlock:^(int retValue)
     {
         if (retValue != 200) {
             
             _officialLoginView.userNameField.enabled = YES;
             _officialLoginView.pswField.enabled = YES;
             _officialLoginView.confirmBtn.enabled = YES;
             _officialLoginView.delegate = self;
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message: [utilityFunction getErrorString:retValue] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             [alertV show];
         }
         else
         {
             [[HttpService getInstance] queryUserExtentInfo:^(int retValue, UserExtentInfo *userExtInfo) {
                 
                 _officialLoginView.userNameField.enabled = YES;
                 _officialLoginView.pswField.enabled = YES;
                 _officialLoginView.confirmBtn.enabled = YES;
                 _officialLoginView.delegate = self;
                 
                 if (userExtInfo != nil)
                 {
                     _checkErrorTime = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(rcLoginError) userInfo:nil repeats:NO];
                     
                     [RCIM connectWithToken:[HttpService getInstance].rcToken completion:^(NSString *userId) {
                         
                         if (_skipIM) {
                             return;
                         }
                         
                         [_checkErrorTime invalidate];
                         _checkErrorTime = nil;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         });
                         
                         [HttpService getInstance].isConnectedIM = YES;
                         
                         basePannelController *baseCtrl = [basePannelController new];
                         baseCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                         baseCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
                         [self presentViewController:baseCtrl animated:YES completion:nil];
                         
                     }error:^(RCConnectErrorCode status){
                         
                         if (_skipIM) {
                             return;
                         }
                         
                         [_checkErrorTime invalidate];
                         _checkErrorTime = nil;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         });
                         
                         [HttpService getInstance].isConnectedIM  = NO;
                         
                         basePannelController *baseCtrl = [basePannelController new];
                         baseCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                         baseCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
                         [self presentViewController:baseCtrl animated:YES completion:nil];
                     }];
                 }
                 else
                 {
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                     
                     UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message: [utilityFunction getErrorString:retValue] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                     [alertV show];
                 }
             }];
         }
     }];
}

- (void)onPressRegisterLable
{
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"自注册暂未开放" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertV show];

#if 0
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:[registerViewController new] animated:YES];
#endif
}

- (void)onPressLostPswLable
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:[resetPswViewController new] animated:YES];
}


- (void)rcLoginError
{
    _skipIM = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    [HttpService getInstance].isConnectedIM = NO;
    
    basePannelController *baseCtrl = [basePannelController new];
    baseCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    baseCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:baseCtrl animated:YES completion:nil];
}

- (void)dealloc
{
    _officialLoginView.delegate = nil;
    
    NSLog(@"loginViewController dealloc");
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
