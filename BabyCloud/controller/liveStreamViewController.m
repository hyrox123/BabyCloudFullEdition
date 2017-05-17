//
//  liveStreamViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "liveStreamViewController.h"
#import "deviceListController.h"
#import "InfoTableViewCell.h"
#import "vodViewController.h"
#import "storyViewController.h"
#import "utilityFunction.h"
#import "MobClick.h"
#import "HttpService.h"
#import "ProtoType.h"

@interface liveStreamViewController()
@property(nonatomic) UITableView *functionList;
@end

@implementation liveStreamViewController

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

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"视 频";
    
    self.navigationItem.titleView = titleLable;
    
    _functionList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-112) style:UITableViewStylePlain];
    
    _functionList.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_functionList];
    
    _functionList.delegate = self;
    _functionList.dataSource = self;
    _functionList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [utilityFunction setExtraCellLineHidden:_functionList];
    [self.view addSubview:_functionList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"9"])
    {
        return 3;
    }
    else
    {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    
    InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[InfoTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CustomCellIdentifier];
    }
    
    
    NSUInteger row = [indexPath row];
    cell.backgroundColor = [UIColor clearColor];
    
    if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"9"])
    {
        switch (row) {
                
            case 0:
            {
                cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tubiao_shipinliulan@2x" ofType:@"png"]];
                cell.nameLabel.text = @"视频浏览";
                cell.decLabel.text  = @"宝宝现在正在干嘛呢";
                cell.updateTimeLabel.text = @"";
            }
                break;
                
            case 1:
            {
                cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tubiao_shipindianbo@2x" ofType:@"png"]];
                cell.nameLabel.text = @"视频点播";
                cell.decLabel.text  = @"海量的教育资源等你来看";
                cell.updateTimeLabel.text = @"";
            }
                break;
                
            case 2:
            {
                cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_sqgs@2x" ofType:@"png"]];
                cell.nameLabel.text = @"睡前故事";
                cell.decLabel.text  = @"经典的童话故事";
                cell.updateTimeLabel.text = @"";
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (row) {
                
            case 0:
            {
                cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tubiao_shipindianbo@2x" ofType:@"png"]];
                cell.nameLabel.text = @"视频点播";
                cell.decLabel.text  = @"海量的教育资源等你来看";
                cell.updateTimeLabel.text = @"";
            }
                break;
                
            case 1:
            {
                cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_sqgs@2x" ofType:@"png"]];
                cell.nameLabel.text = @"睡前故事";
                cell.decLabel.text  = @"经典的童话故事";
                cell.updateTimeLabel.text = @"";
            }
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 3.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int index = indexPath.row;
    
    if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"9"])
    {
        switch (index) {
                
            case 0:
            {
                deviceListController *devicelstCtrl = [deviceListController new];
                devicelstCtrl.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:devicelstCtrl animated:YES];
            }
                break;
                
            case 1:
            {
                vodViewController *vodCtrl = [vodViewController new];
                vodCtrl.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:vodCtrl animated:YES];
            }
                break;
                
            case 2:
            {
                storyViewController *storyCtrl = [storyViewController new];
                storyCtrl.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:storyCtrl animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (index) {
                
            case 0:
            {
                vodViewController *vodCtrl = [vodViewController new];
                vodCtrl.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:vodCtrl animated:YES];
            }
                break;
                
            case 1:
            {
                storyViewController *storyCtrl = [storyViewController new];
                storyCtrl.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:storyCtrl animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"liveStreamViewController dealloc");
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
