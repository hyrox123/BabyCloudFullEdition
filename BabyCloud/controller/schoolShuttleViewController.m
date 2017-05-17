//
//  schoolShuttleViewController.m
//  BabyCloud
//
//  Created by apple on 15/8/10.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "schoolShuttleViewController.h"
#import "schoolShuttleStatisticView.h"
#import "signInViewController.h"
#import "ProtoType.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "messageTipView.h"
#import "MBProgressHUD.h"

#import "Example2PieView.h"
#import "MyPieElement.h"
#import "PieLayer.h"

@interface schoolShuttleViewController()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) schoolShuttleStatisticView *canvasView;
@property(nonatomic) NSMutableDictionary *shttuleDict;
@end

@implementation schoolShuttleViewController

- (NSMutableDictionary*)shttuleDict
{
    if (!_shttuleDict) {
        _shttuleDict = [NSMutableDictionary new];
    }
    
    return  _shttuleDict;
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
    titleLable.text = @"学校入园统计";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    _canvasView = [[schoolShuttleStatisticView alloc] initWithFrame:clientRect];
    [self.view addSubview:_canvasView];
    
    NSDate *now = [NSDate date];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:now];
    NSString *traditionDay = [NSString stringWithFormat:@"%ld月%ld日", (long)[compsNow month], (long)[compsNow day]];
    _canvasView.mainTitle.text = [NSString stringWithFormat:@"%@ 本园出勤率", traditionDay];
    
    _canvasView.staticsTable.delegate = self;
    _canvasView.staticsTable.dataSource = self;
    
    [utilityFunction setExtraCellLineHidden:_canvasView.staticsTable];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"统计中...";
    
    NSString *searchDate = [utilityFunction getTimeNow:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block float totalP = 0, registerCount = 0;
        
        for (BabyInfo *item in [HttpService getInstance].userExtentInfo.babyArray)
        {
#if 0
            [[HttpService getInstance] queryShuttleStatistics:item.classId validDate:searchDate andBlock:^(NSMutableArray *resulteArray) {
                
                int tempNum = 0;
                
                for (SignInItem *item in resulteArray)
                {
                    if ([item.state isEqualToString:@"1"])
                    {
                        tempNum++;
                    }
                }
                
                if (resulteArray.count > 0)
                {
                    [self.shttuleDict setValue:[NSString stringWithFormat:@"%.02f%%", tempNum*100/(float)resulteArray.count] forKey:item.classId];
                }
                else
                {
                    [self.shttuleDict setValue:@"无数据" forKey:item.classId];
                }

                totalP += [resulteArray count];
                registerCount += tempNum;                
            }];
#endif
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            float registerPercentage = 0;
            
            if (totalP > 0) {
                registerPercentage = registerCount/(float)totalP;
            }

            MyPieElement* elem1 = [MyPieElement pieElementWithValue:(registerPercentage) color:[UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f]];
            elem1.title = @"已打卡";
            [_canvasView.pieCart.layer addValues:@[elem1] animated:YES];
            
            MyPieElement* elem2 = [MyPieElement pieElementWithValue:(1-registerPercentage) color:[UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f]];
            elem2.title = @"未打卡";
            [_canvasView.pieCart.layer addValues:@[elem2] animated:YES];
            
            //mutch easier do this with array outside
            _canvasView.pieCart.layer.transformTitleBlock = ^(PieElement* elem){
                return [(MyPieElement*)elem title];
            };
            _canvasView.pieCart.layer.showTitles = ShowTitlesAlways;
            _canvasView.percentage.text = [NSString stringWithFormat:@"%.02f%%", registerPercentage];
            [_canvasView.staticsTable reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [HttpService getInstance].userExtentInfo.babyArray.count;
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
    
    BabyInfo *item = [HttpService getInstance].userExtentInfo.babyArray[indexPath.row];
    
    UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 15)];
    [cell.contentView addSubview:classLabel];
    
    classLabel.font = [UIFont systemFontOfSize:14];
    classLabel.textColor = [UIColor lightGrayColor];
    classLabel.text = item.className;
    
    UILabel *statisticLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 60, 15)];
    [cell.contentView addSubview:statisticLabel];
    
    statisticLabel.font = [UIFont systemFontOfSize:14];
    statisticLabel.textColor = [UIColor orangeColor];
    statisticLabel.text = self.shttuleDict[item.classId];
    
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
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 8, 120, 20)];
    [headerView addSubview:descLabel];
    
    descLabel.textColor = [UIColor blackColor];
    descLabel.font = [UIFont boldSystemFontOfSize:18];
    descLabel.text = @"出勤率";
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    signInViewController *signInCtrl = [signInViewController new];
    signInCtrl.classId = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:[indexPath row]]).classId;
  //  signInCtrl.className = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:[indexPath row]]).className;
    signInCtrl.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:signInCtrl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"schoolShuttleViewController dealloc");
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
