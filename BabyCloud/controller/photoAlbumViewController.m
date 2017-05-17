//
//  photoAlbumViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-15.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "photoAlbumViewController.h"
#import "messageTipView.h"

@interface photoAlbumViewController ()

@end

@implementation photoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"宝宝相册";
    
    self.navigationItem.titleView = titleLable;

    self.photoSrc = [[PhotoDataSource alloc] init];
    [self setDataSource:self.photoSrc];
    
    int picNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"snapshotPicNum"];
    
    if (picNum == 0) {
        messageTipView *tipV = [[messageTipView alloc] initWithFrame:CGRectMake((clientRect.size.width-100)/2.0,(clientRect.size.height-120)/2.0-60, 100, 120)];
        [self.view addSubview:tipV];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"photoAlbumViewController dealloc");
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
