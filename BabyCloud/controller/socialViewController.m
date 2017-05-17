//
//  socialViewController.m
//  BabyCloud
//
//  Created by apple on 15/7/23.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "socialViewController.h"
#import "InfoTableViewCell.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "storyListViewController.h"
#import "vodListViewController.h"

@interface socialViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) UITableView *functionList;
@end

@implementation socialViewController

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
    self.navigationItem.hidesBackButton = YES;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"亲 子";
    
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
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"castle@2x" ofType:@"png"]];
            cell.nameLabel.text = @"商城";
            cell.decLabel.text  = @"幼教商品大全";
            cell.updateTimeLabel.text = @"";
        }
            break;

        case 1:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_kcb@2x" ofType:@"png"]];
            cell.nameLabel.text = @"幼学堂";
            cell.decLabel.text  = @"幼儿教育资源";
            cell.updateTimeLabel.text = @"";
        }
            break;
            
        case 2:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tubiao_shipindianbo@2x" ofType:@"png"]];
            cell.nameLabel.text = @"动漫";
            cell.decLabel.text  = @"海量的动漫资源等你来看";
            cell.updateTimeLabel.text = @"";
        }
            break;
            
        case 3:
        {
            cell.logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ICON_sqgs@2x" ofType:@"png"]];            cell.nameLabel.text = @"儿歌";
            cell.decLabel.text  = @"最新的儿歌大全";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
            
        case 0:
        {

        }
            break;
            
        case 1:
        {

        }
            break;
            
        case 2:
        {
            vodListViewController *vodCtrl = [vodListViewController new];
            vodCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vodCtrl animated:YES];
        }
            break;
            
        case 3:
        {
            storyListViewController *storyCtrl = [storyListViewController new];
            storyCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:storyCtrl animated:YES];
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
    NSLog(@"socialViewController dealloc");
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
