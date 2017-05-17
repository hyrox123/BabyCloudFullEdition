//
//  discoveryViewController.m
//  YSTParentClient
//
//  Created by apple on 14-12-25.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "discoveryViewController.h"
#import "deviceListController.h"
#import "babyActivityViewController.h"
#import "teacherShowViewController.h"
#import "InfoTableViewCell.h"
#import "locationViewController.h"
#import "utilityFunction.h"
#import "shuttleViewController.h"
#import "ClassListViewController.h"
#import "signInViewController.h"
#import "schoolShuttleViewController.h"
#import "conversationViewController.h"
#import "HttpService.h"
#import "ProtoType.h"

@interface discoveryViewController()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property(nonatomic) UITableView *functionList;
@end

@implementation discoveryViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *currentTime = [utilityFunction getTimeNow:YES];
    NSString *lastQueryUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastQueryUpdateDiscovery"];
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
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"发 现";
    
    self.navigationItem.titleView = titleLable;
    
    _functionList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-112) style:UITableViewStylePlain];
    
    _functionList.backgroundColor = [UIColor colorWithRed:0.9647f green:0.9647f blue:0.9647f alpha:1.0f];
    [self.view addSubview:_functionList];
    _functionList.delegate = self;
    _functionList.dataSource = self;
    _functionList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [utilityFunction setExtraCellLineHidden:_functionList];
    [self.view addSubview:_functionList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    NSUInteger row = [indexPath row];
    cell.backgroundColor = [UIColor clearColor];
    
    switch (row) {
           
        case 0:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-BBDTSubjectUnRead", [HttpService getInstance].userId]])
            {
                cell.notifyView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notifyDot@2x" ofType:@"png"]];
            }
            else
            {
                cell.notifyView.image = nil;
            }
            
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_baby_dt@2x" ofType:@"png"]];
            cell.nameLabel.text = @"精彩瞬间";
            cell.updateTimeLabel.text = @"";
            
            if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
            {
                cell.decLabel.text  = @"用指尖拉近与家长的距离";
            }
            else
            {
                cell.decLabel.text  = @"用鲜花表达对老师的感谢";
            }
        }
            break;
            
        case 1:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shuttleSectionNew"])
            {
                cell.notifyView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notifyDot@2x" ofType:@"png"]];
            }
            else
            {
                cell.notifyView.image = nil;
            }
            
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_news2@2x" ofType:@"png"]];
            cell.nameLabel.text = @"入离园";
            cell.updateTimeLabel.text = @"";
            
            if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"])
            {
                cell.decLabel.text  = @"入离园汇总让考勤更轻松";
            }
            else if([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"])
            {
                cell.decLabel.text  = @"入离园补签更贴心";
            }
            else
            {
                cell.decLabel.text  = @"接送宝宝时记得刷卡呦";
            }
        }
            break;
            
        case 2:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kefu@2x" ofType:@"png"]];
            cell.nameLabel.text = @"聊天对话";
            cell.updateTimeLabel.text = @"";
            cell.decLabel.text = @"沟通无极限";            
        }
            break;

        case 3:
        {
            cell.logoView.image = [UIImage imageNamed:@"tubiao_shipinliulan.png"];
            cell.nameLabel.text = @"宝宝在线";
            cell.updateTimeLabel.text = @"";
            
            if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
            {
                cell.decLabel.text  = @"可限时开放的视频点播";
            }
            else
            {
                cell.decLabel.text  = @"尽情延伸你的视觉吧";
            }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
            
        case 0:
        {
            babyActivityViewController *babyCtrl = [babyActivityViewController new];
            babyCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:babyCtrl animated:YES];
        }
            break;
            
        case 1:
        {
            if(([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"]
                || [[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"])
               && ([HttpService getInstance].userExtentInfo.babyArray.count > 0))
            {
                if ([HttpService getInstance].userExtentInfo.babyArray.count == 1) {
                    
                    signInViewController *signInCtrl = [signInViewController new];
                    signInCtrl.classId = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:0]).classId;
                    signInCtrl.className = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:0]).className;
                    signInCtrl.hidesBottomBarWhenPushed = YES;
                    
                    [self.navigationController pushViewController:signInCtrl animated:YES];
                }
                else
                {
                    ClassListViewController *classlstCtrl = [ClassListViewController new];
                    classlstCtrl.hidesBottomBarWhenPushed = YES;
                    
                    [self.navigationController pushViewController:classlstCtrl animated:YES];
                }
            }
            else if([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"]
                    && ([HttpService getInstance].userExtentInfo.babyArray.count > 0))
            {
                
                if ([HttpService getInstance].userExtentInfo.babyArray.count > 1) {
                    
                    UIActionSheet* mySheet = [[UIActionSheet alloc]
                                              initWithTitle:@"选择孩子"
                                              delegate:self
                                              cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
                    
                    
                    for (BabyInfo* baybySub in [HttpService getInstance].userExtentInfo.babyArray) {
                        [mySheet addButtonWithTitle:baybySub.studentName];
                    }
                    
                    [mySheet showInView:self.view];
                }
                else
                {
                    NSString *entranceCardId = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[0]).entranceCardId;
                    shuttleViewController *shuttleCtrl = [[shuttleViewController alloc] init];
                    shuttleCtrl.hidesBottomBarWhenPushed = YES;
                    shuttleCtrl.entranceCardId = entranceCardId;
                    
                    [self.navigationController pushViewController:shuttleCtrl animated:YES];
                }
            }
            else
            {
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该账号不能查看入离园信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertV show];
            }

        }
            break;
            
        case 2:
        {
            conversationViewController *converCtrl = [conversationViewController new];
            converCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:converCtrl animated:YES];
        }
            break;
            
        case 3:
        {
            deviceListController *devicelstCtrl = [deviceListController new];
            devicelstCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:devicelstCtrl animated:YES];
        }
            break;
                        
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [actionSheet cancelButtonIndex])
    {
        NSString *entranceCardId = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[buttonIndex-1]).entranceCardId;
        shuttleViewController *shuttleCtrl = [[shuttleViewController alloc] init];
        shuttleCtrl.hidesBottomBarWhenPushed = YES;
        shuttleCtrl.entranceCardId = entranceCardId;
        
        [self.navigationController pushViewController:shuttleCtrl animated:YES];
    }
}

- (void)dealloc
{
    NSLog(@"discoveryViewController dealloc");
}

@end
