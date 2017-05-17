//
//  videoViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "videoViewController.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "utilityFunction.h"
#import "MBProgressHUD.h"
#import "KrVideoPlayerController.h"

@interface videoViewController()
@property(nonatomic) KrVideoPlayerController  *videoController;
@end


@implementation videoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_videoController dismiss];
}

- (XDeviceNode*)selectedNode
{
    if (_selectedNode == nil) {
        _selectedNode = [XDeviceNode new];
    }
    
    return _selectedNode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = self.selectedNode.deviceName;
    self.navigationItem.titleView = titleLable;

    CGFloat picWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat picHeight = picWidth*288/352;
    CGFloat pos = ([UIScreen mainScreen].bounds.size.height-picHeight)/2-40;
    
    _videoController = [[KrVideoPlayerController alloc] initWithFrame:CGRectMake(0, pos, picWidth, picHeight)];
    [self.view addSubview:_videoController.view];
    
    __weak typeof(self)weakSelf = self;
    
    [self.videoController setWillBackOrientationPortrait:^{
        [weakSelf toolbarHidden:NO];
    }];
    [self.videoController setWillChangeToFullscreenMode:^{
        [weakSelf toolbarHidden:YES];
    }];
    
    _videoController.contentURL =  [NSURL URLWithString:self.selectedNode.streamURL];
}

- (void)toolbarHidden:(BOOL)Bool{
    [self.navigationController setNavigationBarHidden:Bool animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:Bool withAnimation:UIStatusBarAnimationFade];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"videoViewController dealloc");
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
