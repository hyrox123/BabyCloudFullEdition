//
//  signInViewController.m
//  YSTParentClient
//
//  Created by apple on 15/5/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "signInViewController.h"
#import "ProtoType.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "messageTipView.h"
#import "shuttleStaticView.h"
#import "shuttleViewController.h"
#import "registerShuttleView.h"
#import "MBProgressHUD.h"

@interface signInViewController ()<UITableViewDataSource,UITableViewDelegate,shuttleStaticDelegate,registerShuttleDelegate>
@property(nonatomic) shuttleStaticView *canvasView;
@property(nonatomic) NSMutableArray *unRigisterArray, *registerArray;
@property(nonatomic) BOOL statisticMode;
@end

@implementation signInViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (NSMutableArray*)registerArray
{
    if (!_registerArray) {
        _registerArray = [NSMutableArray new];
    }
    
    return _registerArray;
}

- (NSMutableArray*)unRigisterArray
{
    if (!_unRigisterArray) {
        _unRigisterArray = [NSMutableArray new];
    }
    
    return _unRigisterArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"班级入园统计";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    _canvasView = [[shuttleStaticView alloc] initWithFrame:clientRect];
    [self.view addSubview:_canvasView];
    
    NSDate *now = [NSDate date];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:now];
    NSString *traditionDay = [NSString stringWithFormat:@"%ld月%ld日", (long)[compsNow month], (long)[compsNow day]];
    _canvasView.mainTitle.text = [NSString stringWithFormat:@"%@ 出勤率", traditionDay];
    
    _canvasView.staticsTable.delegate = self;
    _canvasView.staticsTable.dataSource = self;
    _canvasView.delegate = self;
    
    [utilityFunction setExtraCellLineHidden:_canvasView.staticsTable];
    
    if (!_parentStaticArray)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"统计中...";

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *searchDate = [utilityFunction getTimeNow:NO];
            __block NSArray *resultArray = [[HttpService getInstance] queryShuttleStatistics:_classId validDate:searchDate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                for (SignInItem *item in resultArray) {
                    
                    if ([item.state isEqualToString:@"1"])
                    {
                        [self.registerArray addObject:item];
                    }
                    else
                    {
                        [self.unRigisterArray addObject:item];
                    }
                }
                
                if (resultArray.count > 0) {
                    _canvasView.percentage.text = [NSString stringWithFormat:@"%.02f%%", (self.registerArray.count/(float)resultArray.count)*100];
                    [_canvasView.staticsTable reloadData];
                }
            });
        });
    }
    else
    {
        for (SignInItem *item in _parentStaticArray) {
            
            if ([item.state isEqualToString:@"1"])
            {
                [self.registerArray addObject:item];
            }
            else
            {
                [self.unRigisterArray addObject:item];
            }
        }
        
        if (_parentStaticArray.count > 0) {
            _canvasView.percentage.text = [NSString stringWithFormat:@"%.02f%%", (self.registerArray.count/(float)_parentStaticArray.count)*100];
            [_canvasView.staticsTable reloadData];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_statisticMode)
    {
        return [self.unRigisterArray count];
    }
    else
    {
        return [self.registerArray count];
    }
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
    
    UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 15)];
    [cell.contentView addSubview:classLabel];
    
    classLabel.font = [UIFont systemFontOfSize:14];
    classLabel.textColor = [UIColor lightGrayColor];
    classLabel.text = _className;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 60, 15)];
    [cell.contentView addSubview:nameLabel];
    
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = [UIColor orangeColor];
    
    if (!_statisticMode)
    {
        UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cell.contentView addSubview:registerBtn];
        
        registerBtn.tag = 0x1000+indexPath.row;
        registerBtn.frame = CGRectMake(200, 5, 80, 25);
        registerBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        registerBtn.layer.borderWidth = 0.5;
        registerBtn.layer.cornerRadius = 12.5;
        registerBtn.showsTouchWhenHighlighted = YES;
        registerBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        registerBtn.titleLabel.textColor = [UIColor whiteColor];
        registerBtn.backgroundColor = [UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f];
        [registerBtn setTitle: @"手动签到" forState: UIControlStateNormal];
        [registerBtn addTarget:self action:@selector(onBtnRegister:) forControlEvents:UIControlEventTouchUpInside];
        
        SignInItem *item = self.unRigisterArray[indexPath.row];
        nameLabel.text = item.studentName;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 120, 15)];
        [cell.contentView addSubview:descLabel];
        
        descLabel.font = [UIFont systemFontOfSize:14];
        descLabel.textColor = [UIColor lightGrayColor];
        descLabel.text = @"已经签到";
        
        SignInItem *item = self.registerArray[indexPath.row];
        nameLabel.text = item.studentName;
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark Table Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 35)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.borderWidth = 0.5;
    headerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 100, 20)];
    [headerView addSubview:classLabel];
    
    classLabel.textColor = [UIColor blackColor];
    classLabel.font = [UIFont boldSystemFontOfSize:18];
    classLabel.text = @"班级";
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 8, 60, 20)];
    [headerView addSubview:nameLabel];
    
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    nameLabel.text = @"姓名";
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 8, 120, 20)];
    [headerView addSubview:descLabel];
    
    descLabel.textColor = [UIColor blackColor];
    descLabel.font = [UIFont boldSystemFontOfSize:18];
    descLabel.text = @"说明";
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onStaticModeChange:(BOOL)mode
{
    _statisticMode = mode;
    [_canvasView.staticsTable reloadData];
}

- (void)onBtnRegister:(id)sender
{
    int index = (int)((UIButton*)sender).tag-0x1000;
    SignInItem *item = self.unRigisterArray[index];
    
    [registerShuttleView showRegisterShuttleView:self studentId:item.studentId studentName:item.studentName];
}

- (void)onRegister:(NSString*)studentId reason:(NSString *)reason
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    [[HttpService getInstance] submitShuttle:_classId studentId:studentId date:date describ:reason andBlock:^(int retValue) {
        
        if (retValue == 200) {
            
            for (SignInItem *item in self.unRigisterArray) {
                
                if ([item.studentId isEqualToString:studentId]) {
                    [self.registerArray addObject:item];
                    [self.unRigisterArray removeObject:item];
                    break;
                }
            }
            
            _canvasView.percentage.text = [NSString stringWithFormat:@"%.02f%%", (self.registerArray.count/(float)self.registerArray.count+self.unRigisterArray.count)*100];
            [_canvasView.staticsTable reloadData];
        }
        else
        {
            NSString *description = @"";
            
            if (retValue == 403)
            {
                description = @"手动签到失败,用户没有绑定入离园卡";
            }
            else
            {
                description = [NSString stringWithFormat:@"手动签到失败,错误码[%d]", retValue];
            }
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:description
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"signInViewController dealloc");
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
