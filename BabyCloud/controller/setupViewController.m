//
//  setupViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/31.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "setupViewController.h"
#import "instructionViewController.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "changePswViewController.h"
#import "reportView.h"

@interface setupViewController ()<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate>
@property(nonatomic) UITableView *functionList;
@end

@implementation setupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"设置";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationItem.titleView = titleLable;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _functionList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, 100) style:UITableViewStylePlain];
    
    _functionList.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_functionList];
    
    _functionList.delegate = self;
    _functionList.dataSource = self;
    [utilityFunction setExtraCellLineHidden:_functionList];
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConfirm.frame = CGRectMake(5, 130, clientRect.size.width-10, 35);
    btnConfirm.showsTouchWhenHighlighted = YES;
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:20];
    btnConfirm.titleLabel.textColor = [UIColor whiteColor];
    btnConfirm.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    [btnConfirm setTitle: @"注 销" forState: UIControlStateNormal];
    [btnConfirm addTarget:self action:@selector(onLogout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnConfirm];
}

- (void)onBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CustomCellIdentifier];
    }
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSUInteger row = [indexPath row];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 13, 24, 24)];
    UILabel *descLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 16, 200, 20)];
    descLable.font = [UIFont boldSystemFontOfSize:16];
    
    [cell.contentView addSubview:imageV];
    [cell.contentView addSubview:descLable];
    
    switch (row)
    {
        case 0:
        {
            descLable.text = @"修改密码";
            imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Change_the_password@2x" ofType:@"png"]];
        }
            break;
            
        case 1:
        {
            descLable.text = @"自动更新";
            imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Check_for_updates@2x" ofType:@"png"]];
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
    
    int index = indexPath.row;
    
    switch (index) {
            
        case 0:
        {
            changePswViewController *changePswCtrl = [changePswViewController new];
            changePswCtrl.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:changePswCtrl animated:YES];
            
        }
            break;
            
            
        case 1:
        {
            [self checkAppUpdate];
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

-(void)checkAppUpdate
{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *lastVersion = [HttpService getInstance].appVersion;
    
    if (lastVersion.length == 5) {
        if ([currentVersion compare:[HttpService getInstance].appVersion] == NSOrderedAscending) {
            [reportView showReportView:self.view];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前为最新版本!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"setupViewController dealloc");
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
