//
//  vodViewController.m
//  YSTParentClient
//
//  Created by apple on 14-11-28.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "vodViewController.h"
#import "InfoTableViewCell.h"
#import "vodListViewController.h"
#import "utilityFunction.h"
#import "MobClick.h"

@interface vodViewController()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) UITableView *vodCategory;
@end

@implementation vodViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"视频点播"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"视频点播"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.vodCategory reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"视频点播";
    self.navigationItem.titleView = titleLable;
    
     self.view.backgroundColor = [UIColor whiteColor];
    _vodCategory = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    [self.view addSubview:_vodCategory];
    
    _vodCategory.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_vodCategory setDelegate:self];
    [_vodCategory setDataSource:self];
    
    [utilityFunction setExtraCellLineHidden:_vodCategory];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    
    InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[InfoTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CustomCellIdentifier];
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    switch ([indexPath row]) {
            
        case 0:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icn-yezs@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"家长学堂";
            cell.decLabel.text  = @"育儿教学类视频";
        }
            break;
            
        case 1:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icn-bbdh@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"宝贝动画";
            cell.decLabel.text  = @"动画视频";
        }
            break;
            
        case 2:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icn-gxpp@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"搞笑拍拍";
            cell.decLabel.text  = @"搞笑视频";
        }
            break;
            
        case 3:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icn-qmjy@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"启蒙教育";
            cell.decLabel.text  = @"启蒙教育视频";
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    vodListViewController  *vodLstCtrl = [vodListViewController new];
    vodLstCtrl.vodCatagory = indexPath.row;
    
    [self.navigationController pushViewController:vodLstCtrl animated:YES];
}

- (void)dealloc
{
    NSLog(@"vodViewController dealloc");
}

@end
