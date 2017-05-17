//
//  ClassListViewController.m
//  YSTParentClient
//
//  Created by apple on 15/5/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "ClassListViewController.h"
#import "ProtoType.h"
#import "mobClick.h"
#import "utilityFunction.h"
#import "messageTipView.h"
#import "HttpService.h"
#import "signInViewController.h"
#import "MBProgressHUD.h"
#import "Example2PieView.h"
#import "MyPieElement.h"
#import "PieLayer.h"

@interface ClassListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) UITableView *classlst;
@property(nonatomic) NSMutableArray *classArray;
@property(nonatomic) NSMutableDictionary *classDict;
@end

@implementation ClassListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"班级列表"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"班级列表"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shuttleSectionNew"];
}

- (NSMutableArray*)classArray
{
    if (!_classArray) {
        _classArray = [NSMutableArray new];
    }
    
    return _classArray;
}

- (NSMutableDictionary*)classDict
{
    if (!_classDict) {
        _classDict = [NSMutableDictionary new];
    }
    
    return _classDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"总体出勤率";
    self.navigationItem.titleView = titleLable;
    
    if ([HttpService getInstance].userExtentInfo.babyArray.count == 0) {
        [messageTipView showTipView:self.view style:0 tip:@"找不到班级~"];
        return;
    }
    
    UILabel *classNameL = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 150, 20)];
    [self.view addSubview:classNameL];
    
    classNameL.font = [UIFont boldSystemFontOfSize:18];
    classNameL.textColor = [UIColor blackColor];
    classNameL.backgroundColor = [UIColor clearColor];
    
    UILabel *rateL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(clientRect)-100, 10, 150, 20)];
    [self.view addSubview:rateL];
    
    rateL.font = [UIFont boldSystemFontOfSize:18];
    rateL.textColor = [UIColor blackColor];
    rateL.backgroundColor = [UIColor clearColor];
   
    unsigned long realHeight = [HttpService getInstance].userExtentInfo.babyArray.count*45;
    
    if (realHeight > CGRectGetHeight(clientRect)-300) {
        realHeight = CGRectGetHeight(clientRect)-300;
    }
    
    _classlst = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, clientRect.size.width, realHeight) style:UITableViewStylePlain];
    [self.view addSubview:_classlst];
    
    if (realHeight < CGRectGetHeight(clientRect)-300) {
        realHeight += 40;
    }
    
    _classlst.backgroundColor = [UIColor clearColor];
    _classlst.separatorStyle = UITableViewCellSelectionStyleNone;
    [_classlst setDelegate:self];
    [_classlst setDataSource:self];
    [utilityFunction setExtraCellLineHidden:_classlst];
    
    UILabel *describTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, realHeight+40, CGRectGetWidth(clientRect), 20)];
    [self.view addSubview:describTitle];
    
    describTitle.font = [UIFont boldSystemFontOfSize:18];
    describTitle.textColor = [UIColor blackColor];
    describTitle.backgroundColor = [UIColor clearColor];
    describTitle.textAlignment = NSTextAlignmentCenter;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"统计中...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        __block int totalStudentNumber = 0, totalRegisterNumber = 0;
        NSString *searchDate = [utilityFunction getTimeNow:NO];

        for (BabyInfo *item in [HttpService getInstance].userExtentInfo.babyArray) {
            
            NSArray *resultArray = [[HttpService getInstance] queryShuttleStatistics:item.classId validDate:searchDate];
            [self.classArray addObject:resultArray];
            
            int registerNum = 0;
            
            for (SignInItem *item in resultArray) {
                
                if ([item.state isEqualToString:@"1"])
                {
                    registerNum++;
                }
            }
            
            if (resultArray.count > 0)
            {
                [self.classDict setValue:[NSString stringWithFormat:@"%.02f%%", registerNum*100/(float)resultArray.count] forKey:item.classId];
            }
            else
            {
                [self.classDict setValue:@"无数据" forKey:item.classId];
            }

            totalStudentNumber += resultArray.count;
            totalRegisterNumber += registerNum;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float registerPercentage = 0;
            
            if (totalStudentNumber > 0) {
                registerPercentage = totalRegisterNumber/(float)totalStudentNumber;
            }
            
            rateL.text = @"出勤率";
            classNameL.text = @"班级";
            describTitle.text = [NSString stringWithFormat:@"%@日平均入园率:%.02f%%", searchDate, registerPercentage*100];
            
            Example2PieView *pieCart = [[Example2PieView alloc] initWithFrame:CGRectMake((CGRectGetWidth(clientRect)-230)/2, realHeight+30, 230, 230)];
            [self.view addSubview:pieCart];
            
            pieCart.backgroundColor = [UIColor clearColor];
            MyPieElement* elem1 = [MyPieElement pieElementWithValue:(registerPercentage) color:[UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f]];
            elem1.title = @"已打卡";
            [pieCart.layer addValues:@[elem1] animated:YES];
            
            MyPieElement* elem2 = [MyPieElement pieElementWithValue:(1-registerPercentage) color:[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f]];
            elem2.title = @"未打卡";
            [pieCart.layer addValues:@[elem2] animated:YES];
            
            pieCart.layer.transformTitleBlock = ^(PieElement* elem){
                return [(MyPieElement*)elem title];
            };
            pieCart.layer.showTitles = ShowTitlesAlways;

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [_classlst reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.classArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceTableCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"deviceTableCell"];
    }
    
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    BabyInfo *item = [[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:[indexPath row]];
    
    UILabel *className = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 200, 20)];
    [cell.contentView addSubview:className];
    className.font = [UIFont systemFontOfSize:16];
    className.text = item.className;
    
    UILabel *percentage = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)-100, 14, 100, 20)];
    [cell.contentView addSubview:percentage];
    percentage.font = [UIFont boldSystemFontOfSize:16];
    percentage.text = self.classDict[item.classId];
    percentage.textColor = [UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f];

    UIImageView *horiz = [[UIImageView alloc] initWithFrame:CGRectMake(10, 44.5, CGRectGetWidth(tableView.frame)-20,  0.5)];
    [cell.contentView addSubview:horiz];
    
    UIGraphicsBeginImageContext(horiz.frame.size);
    [horiz.image drawInRect:CGRectMake(0, 0, horiz.frame.size.width, horiz.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    const CGFloat lengths[] = {2,2};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor blackColor].CGColor);
    
    CGContextSetLineDash(line, 0, lengths, 2);
    CGContextMoveToPoint(line, 0, 0);
    CGContextAddLineToPoint(line, CGRectGetWidth(horiz.frame), 0);
    CGContextStrokePath(line);
    
    horiz.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    signInViewController *signInCtrl = [signInViewController new];
    signInCtrl.classId = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:[indexPath row]]).classId;
    signInCtrl.className = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:[indexPath row]]).className;
    signInCtrl.parentStaticArray = self.classArray[indexPath.row];
    [self.navigationController pushViewController:signInCtrl animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"ClassListViewController dealloc");
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
