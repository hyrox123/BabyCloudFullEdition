//
//  infomationViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "infomationViewController.h"
#import "InfoTableViewCell.h"
#import "babyActivityViewController.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "lastestNoticeViewController.h"
#import "campaignViewController.h"
#import "schoolActivityViewController.h"
#import "ProtoType.h"

@interface infomationViewController ()
@property(nonatomic) UITableView *functionList;
@property(nonatomic) UIView *headerView;

@end

@implementation infomationViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *currentTime = [utilityFunction getTimeNow:YES];
    NSString *lastQueryUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastQueryUpdateInfo"];
    NSTimeInterval timeGap = [utilityFunction compareTime:currentTime time2:lastQueryUpdateTime complex:YES];
    
    if (timeGap > 60)
    {
        [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:@"lastQueryUpdate"];
        [[HttpService getInstance] queryMessageUpdate:^(int retValue) {
            if (retValue == 200) {
                [_functionList reloadData];
            }
        }];
    }
    else
    {
        [_functionList reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width-120, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"消 息";
    self.navigationItem.titleView = titleLable;
    
    _functionList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-112) style:UITableViewStylePlain];
    
    _functionList.backgroundColor = [UIColor colorWithRed:0.9647f green:0.9647f blue:0.9647f alpha:1.0f];
    [self.view addSubview:_functionList];
    
    _functionList.delegate = self;
    _functionList.dataSource = self;
    _functionList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [utilityFunction setExtraCellLineHidden:_functionList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
    
    switch (row) {
            
        case 0:
        {            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"schoolActivitySectionNew"])
            {
                cell.notifyView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notifyDot@2x" ofType:@"png"]];
            }
            else
            {
                cell.notifyView.image = nil;
            }
            
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_xygs@2x" ofType:@"png"]];
            cell.nameLabel.text = @"校园风采";
            cell.decLabel.text = @"校园风采面貌尽在这里";
            cell.updateTimeLabel.text = @"";
        }
            break;
            
            
        case 1:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-XXTZSubjectUnRead", [HttpService getInstance].userId]])
            {
                cell.notifyView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notifyDot@2x" ofType:@"png"]];
            }
            else
            {
                cell.notifyView.image = nil;
            }
            
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_rlytz@2x" ofType:@"png"]];
            cell.nameLabel.text = @"校讯";
            cell.decLabel.text = @"通知,课程,食谱都知道";
            cell.updateTimeLabel.text = @"";
        }
            break;
            
        case 2:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lipin@2x" ofType:@"png"]];
            cell.nameLabel.text = @"活动";
            cell.decLabel.text = @"精彩活动欢迎你的参与";
            cell.updateTimeLabel.text = @"";
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 3.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch ([indexPath row]) {
            
        case 0:
        {
            schoolActivityViewController *schoolCtrl = [[schoolActivityViewController alloc] init];
            schoolCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:schoolCtrl animated:YES];
            
        }
            break;
            
            
        case 1:
        {
            lastestNoticeViewController *noticeCtrl = [[lastestNoticeViewController alloc] init];
            noticeCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:noticeCtrl animated:YES];
        }
            break;
            
        case 2:
        {
            /*
            campaignViewController *campCtrl = [[campaignViewController alloc] init];
            campCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:campCtrl animated:YES];
            */
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"infomationViewController dealloc");
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
