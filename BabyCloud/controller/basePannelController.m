//
//  basePannelController.m
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "basePannelController.h"
#import "infomationViewController.h"
#import "discoveryViewController.h"
#import "socialViewController.h"
#import "configureViewController.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "ProtoType.h"
#import "reportView.h"

@interface basePannelController ()
@end

@implementation basePannelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    infomationViewController *infoCtrl = [infomationViewController new];
    discoveryViewController *discoveryCtrl = [discoveryViewController new];
    socialViewController *socialCtrl = [socialViewController new];
    configureViewController *configureCtrl = [configureViewController new];
    
    UIImage *normalImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Button_xiaoxi_@2x" ofType:@"png"]];
    UIImage *selectedImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Button_xiaoxi_2@2x" ofType:@"png"]];
    
    normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImg = [selectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *infoCtrlItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:normalImg selectedImage:selectedImg];
    
    infoCtrl.tabBarItem = infoCtrlItem;
    infoCtrl.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    normalImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"parentGray@2x" ofType:@"png"]];
    selectedImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"parentLight@2x" ofType:@"png"]];
    
    normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImg = [selectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *socialCtrlItem = [[UITabBarItem alloc] initWithTitle:@"亲子" image:normalImg selectedImage:selectedImg];
    
    socialCtrl.tabBarItem = socialCtrlItem;
    socialCtrl.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    normalImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Button_weizhi_@2x" ofType:@"png"]];
    selectedImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Button_weizhi_2@2x" ofType:@"png"]];
    
    normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImg = [selectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *discoveryCtrlItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:normalImg selectedImage:selectedImg];
    
    discoveryCtrl.tabBarItem = discoveryCtrlItem;
    discoveryCtrl.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    normalImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Button_wo_@2x" ofType:@"png"]];
    selectedImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Button_wo_2@2x" ofType:@"png"]];
    
    normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImg = [selectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *configureCtrlItem = [[UITabBarItem alloc] initWithTitle:@"我" image:normalImg selectedImage:selectedImg];
    
    configureCtrl.tabBarItem = configureCtrlItem;
    configureCtrl.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    UINavigationController *infoCtrlNav = [[UINavigationController alloc]initWithRootViewController:infoCtrl];
    UINavigationController *socialCtrlNav = [[UINavigationController alloc]initWithRootViewController:socialCtrl];
    UINavigationController *discoveryCrltNav = [[UINavigationController alloc]initWithRootViewController:discoveryCtrl];
    UINavigationController *configureCtrlNav = [[UINavigationController alloc]initWithRootViewController:configureCtrl];
    
    NSArray *viewControllers = [NSArray arrayWithObjects:discoveryCrltNav, infoCtrlNav, socialCtrlNav, configureCtrlNav, nil];
    [self setViewControllers:viewControllers];
    
    [[HttpService getInstance] queryUserBaseInfo:^(UserBaseInfo *userBaseInfo) {
    }];
    
#if 0
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        [self checkAppUpdate];
    });
#endif
}


-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    int barState = [change[@"new"] intValue];

    if (barState == 0)
    {
        
    }
    else
    {
        
    }
}

-(void)checkAppUpdate
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableUpdate"]) {
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *lastVersion = [HttpService getInstance].appVersion;
        
        if (lastVersion.length == 5) {
            if ([currentVersion compare:[HttpService getInstance].appVersion] == NSOrderedAscending) {
                [reportView showReportView:self.view];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    [self removeObserver:self forKeyPath:@"tabBar.hidden"];
    NSLog(@"basePannelController dealloc");
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
