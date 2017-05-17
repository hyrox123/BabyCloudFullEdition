//
//  storyViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "storyViewController.h"
#import "storyListViewController.h"
#import "InfoTableViewCell.h"
#import "utilityFunction.h"
#import "MobClick.h"

@interface storyViewController ()
@property(nonatomic) UITableView *storyCategory;

@end

@implementation storyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"睡前故事"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"睡前故事"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.storyCategory reloadData];
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
    titleLable.text = @"睡前故事";
    self.navigationItem.titleView = titleLable;
    
     self.view.backgroundColor = [UIColor whiteColor];
    _storyCategory = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    
    _storyCategory.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_storyCategory];
    
    _storyCategory.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_storyCategory setDelegate:self];
    [_storyCategory setDataSource:self];
    
    [utilityFunction setExtraCellLineHidden:_storyCategory];
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
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ge_@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"格林童话";
            cell.decLabel.text  = @"世界童话的经典之作";
        }
            break;
            
        case 1:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"an_@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"安徒生童话";
            cell.decLabel.text  = @"世界童话的经典之作";
        }
            break;
            
        case 2:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yu_@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"寓言故事";
            cell.decLabel.text  = @"经典寓言故事";
        }
            break;
            
        case 3:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shen_@2x" ofType:@"png"]];
            cell.nameLabel.text  = @"神话故事";
            cell.decLabel.text  = @"中国民间神话故事";
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
    
    storyListViewController *storyLstCtrl = [storyListViewController new];
    storyLstCtrl.storyCatagory = indexPath.row;
    
    [self.navigationController pushViewController:storyLstCtrl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{    
    NSLog(@"storyViewController dealloc");
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
