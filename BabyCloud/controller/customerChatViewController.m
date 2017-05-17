//
//  customerChatViewController.m
//  YSTParentClient
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "customerChatViewController.h"

@interface customerChatViewController ()

@end

@implementation customerChatViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    UILabel *title = (UILabel*)self.navigationItem.titleView;
    title.textColor = [UIColor blackColor];
    
    UIBarButtonItem *currentBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = currentBackItem;
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"customerChatViewController dealloc");
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
