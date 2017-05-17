//
//  configureViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "configureViewController.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "UIImageView+WebCache.h"
#import "userInfoViewController.h"
#import "babyInfoViewController.h"
#import "SDTransparentPieProgressView.h"
#import "ProtoType.h"
#import <QuartzCore/QuartzCore.h>
#import "changePswViewController.h"

@interface configureViewController ()<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate>
@property(nonatomic) UITableView *functionList;
@property(nonatomic) NSString *nickName;
@end

@implementation configureViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.functionList reloadData];
    
    UIImageView *portraitV = (UIImageView*)[self.view viewWithTag:0x1000];
    UILabel *nickLable = (UILabel*)[self.view viewWithTag:0x1001];
    UILabel *userType = (UILabel*)[self.view viewWithTag:0x1002];
    UILabel *scoreLable = (UILabel*)[self.view viewWithTag:0x1003];
    
    nickLable.text = [HttpService getInstance].userBaseInfo.nickName;
    scoreLable.text = [NSString stringWithFormat:@"%d", [HttpService getInstance].userBaseInfo.score];
    
    CGSize nicklabelW = [nickLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18],NSFontAttributeName, nil]];
    
    [userType setFrame:CGRectMake(140+nicklabelW.width, 12, 80, 15)];
    
    if ([HttpService getInstance].userBaseInfo.portrait != nil && [[HttpService getInstance].userBaseInfo.portrait length] > 0 ) {
        
        NSString *portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, [HttpService getInstance].userBaseInfo.portrait];
        
        __block SDTransparentPieProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = portraitV;
        [portraitV sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
                     placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]]
                              options:SDWebImageProgressiveDownload
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 if (!activityIndicator) {
                                     activityIndicator = [SDTransparentPieProgressView progressView];
                                     activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-40)/2, (weakImageView.frame.size.height-40)/2, 40, 40);
                                     [weakImageView addSubview:activityIndicator];
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     activityIndicator.progress = (float)receivedSize/(float)expectedSize;
                                 });
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                [activityIndicator dismiss];
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
        
    }
    else
    {
        portraitV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    titleLable.text = @"我";
    
    self.navigationItem.titleView = titleLable;
    
    UIView *pannelView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, clientRect.size.width-20, 70)];
    [self.view addSubview:pannelView];
    
    pannelView.backgroundColor = [UIColor whiteColor];
    pannelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pannelView.layer.borderWidth = 0.5;
    
    UIImageView *portraitV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
    [pannelView addSubview:portraitV];
    
    portraitV.tag = 0x1000;
    portraitV.layer.masksToBounds = YES;
    portraitV.layer.cornerRadius = 8;
    
    if ([HttpService getInstance].userBaseInfo.portrait != nil && [[HttpService getInstance].userBaseInfo.portrait length] > 0 ) {
        
        NSString *portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, [HttpService getInstance].userBaseInfo.portrait];
        
        __block SDTransparentPieProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = portraitV;
        [portraitV sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
                     placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]]
                              options:SDWebImageProgressiveDownload
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 if (!activityIndicator) {
                                     activityIndicator = [SDTransparentPieProgressView progressView];
                                     activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-40)/2, (weakImageView.frame.size.height-40)/2, 40, 40);
                                     [weakImageView addSubview:activityIndicator];
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     activityIndicator.progress = (float)receivedSize/(float)expectedSize;
                                 });
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                [activityIndicator dismiss];
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
        
    }
    else
    {
        portraitV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]];
    }
    
    UILabel *desclabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 12, 80, 15)];
    [pannelView addSubview:desclabel];
    
    desclabel.font = [UIFont systemFontOfSize:12];
    desclabel.textColor = [UIColor lightGrayColor];
    desclabel.text = @"我的昵称";
    
    UILabel *nicklabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 150, 18)];
    [pannelView addSubview:nicklabel];
    
    nicklabel.font = [UIFont boldSystemFontOfSize:18];
    nicklabel.textColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    nicklabel.text = [HttpService getInstance].userBaseInfo.nickName;
    nicklabel.tag = 0x1001;
    
    CGSize nicklabelW = [nicklabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18],NSFontAttributeName, nil]];
    
    UILabel *userTypelabel = [[UILabel alloc] initWithFrame:CGRectMake(140+nicklabelW.width, 12, 80, 15)];
    [pannelView addSubview:userTypelabel];
    
    userTypelabel.tag = 0x1002;
    userTypelabel.font = [UIFont systemFontOfSize:12];
    userTypelabel.textColor = [UIColor orangeColor];
    
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"])
    {
        if ([HttpService getInstance].userBaseInfo.position != nil
            && [HttpService getInstance].userBaseInfo.position.length > 0)
        {
            userTypelabel.text = [NSString stringWithFormat:@"(%@)", [HttpService getInstance].userBaseInfo.position];
        }
        else
        {
            userTypelabel.text = @"(园长)";
        }
    }
    else if([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"])
    {
        
        if ([HttpService getInstance].userBaseInfo.position != nil
            && [HttpService getInstance].userBaseInfo.position.length > 0)
        {
            userTypelabel.text = [NSString stringWithFormat:@"(%@)", [HttpService getInstance].userBaseInfo.position];
        }
        else
        {
            userTypelabel.text = @"(教师)";
        }
    }
    else
    {
        userTypelabel.text = @"";
    }
    
    UIImageView *scoreV = [[UIImageView alloc] initWithFrame:CGRectMake(85, 38, 20, 20)];
    [pannelView addSubview:scoreV];
    scoreV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zan_down@2x" ofType:@"png"]];
    
    UILabel *scorelabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 42, 100, 15)];
    [pannelView addSubview:scorelabel];
    
    scorelabel.tag = 0x1003;
    scorelabel.font = [UIFont systemFontOfSize:12];
    scorelabel.textColor = [UIColor lightGrayColor];
    scorelabel.text = [NSString stringWithFormat:@"%d", [HttpService getInstance].userBaseInfo.score];
    
    _functionList = [[UITableView alloc] initWithFrame:CGRectMake(10, 100, clientRect.size.width-20, 100) style:UITableViewStylePlain];
    [self.view addSubview:_functionList];
    
    _functionList.backgroundColor = [UIColor whiteColor];
    _functionList.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _functionList.layer.borderWidth = 0.5;
    
    _functionList.delegate = self;
    _functionList.dataSource = self;
    [utilityFunction setExtraCellLineHidden:_functionList];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9647f green:0.9647f blue:0.9647f alpha:1.0f];
    _functionList.backgroundColor = [UIColor colorWithRed:0.9647f green:0.9647f blue:0.9647f alpha:1.0f];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:logoutBtn];
    
    logoutBtn.frame = CGRectMake(8, 220, clientRect.size.width-16, 35);
    logoutBtn.layer.cornerRadius = 17.5;
    logoutBtn.showsTouchWhenHighlighted = YES;
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    logoutBtn.titleLabel.textColor = [UIColor whiteColor];
    logoutBtn.backgroundColor = [UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f];
    [logoutBtn setTitle: @"注  销" forState: UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(onLogout) forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * identifier = [NSString stringWithFormat:@"cell%ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:identifier];
    }
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 13, 24, 24)];
    UILabel *descLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 16, 200, 20)];
    descLable.font = [UIFont boldSystemFontOfSize:16];
    
    [cell.contentView addSubview:imageV];
    [cell.contentView addSubview:descLable];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch ([indexPath row])
    {
        case 0:
        {
            descLable.text = @"个人信息";
            imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"personal-information@2x" ofType:@"png"]];
        }
            break;
            
        case 1:
        {
            descLable.text = @"修改密码";
            imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Change_the_password@2x" ofType:@"png"]];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch ([indexPath row]) {
            
        case 0:
        {
            userInfoViewController *userInfoCtrl = [userInfoViewController new];
            userInfoCtrl.hidesBottomBarWhenPushed = YES;
            userInfoCtrl.solidStyle = YES;
            
            [self.navigationController pushViewController:userInfoCtrl animated:YES];
            
        }
            break;
            
            
        case 1:
        {
            changePswViewController *changePswCtrl = [changePswViewController new];
            changePswCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:changePswCtrl animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onLogout
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"configureViewController dealloc");
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
