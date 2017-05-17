//
//  createBabyViewController.m
//  YSTParentClient
//
//  Created by apple on 15/6/30.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "createBabyViewController.h"
#import "ProtoType.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "MBProgressHUD.h"
#import "CKCalendarView.h"
#import "selfServiceAddViewController.h"

@interface createBabyViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CKCalendarDelegate>
@property(nonatomic) UITableView *infoList;
@property(nonatomic) CKCalendarView *calendar;
@property(nonatomic) bool succeed;

-(void)onBtnAdd;
@end

@implementation createBabyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"添加宝宝";
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    _infoList = [[UITableView alloc] initWithFrame:CGRectMake(10, 15, clientRect.size.width-20, 350)];
    [self.view addSubview:_infoList];
    
    _infoList.delegate = self;
    _infoList.dataSource = self;
    _infoList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [utilityFunction setExtraCellLineHidden:_infoList];
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnConfirm.layer.cornerRadius = 4;
    btnConfirm.layer.masksToBounds = YES;
    btnConfirm.frame = CGRectMake(5, 220, clientRect.size.width-10, 35);
    btnConfirm.showsTouchWhenHighlighted = YES;
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:20];
    btnConfirm.titleLabel.textColor = [UIColor whiteColor];
    btnConfirm.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    [btnConfirm setTitle: @"添 加" forState: UIControlStateNormal];
    [btnConfirm addTarget:self action:@selector(onBtnAdd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnConfirm];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 160, 30)];
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    textField.delegate = self;
    descLabel.font = [UIFont systemFontOfSize:18];
    textField.font = [UIFont systemFontOfSize:16];
    
    if([indexPath row] == 0)
    {
        descLabel.text = @"姓名";
        textField.placeholder = @"宝宝真实姓名";
        textField.tag = 0x1001;
    }
    else if ([indexPath row] == 1)
    {
        descLabel.text = @"性别";
        textField.placeholder = @"宝宝性别";
        textField.tag = 0x1002;
    }
    else if([indexPath row] == 2)
    {
        descLabel.text = @"出生日期";
        textField.tag = 0x1003;
        textField.enabled = NO;
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cell.contentView addSubview:selectBtn];
        
        selectBtn.tag = 0x1004;
        selectBtn.frame = CGRectMake(self.view.frame.size.width-100, 10, 80, 30);
        selectBtn.showsTouchWhenHighlighted = YES;
        selectBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        selectBtn.titleLabel.textColor = [UIColor whiteColor];
        selectBtn.backgroundColor = [UIColor whiteColor];
        [selectBtn setTitle: @"选择" forState: UIControlStateNormal];
        [selectBtn addTarget:self action:@selector(showDataSelector:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else if([indexPath row] == 3)
    {
        descLabel.text = @"亲属关系";
        textField.placeholder = @"我是宝宝的";
        textField.tag = 0x1005;
    }
    
    [cell.contentView addSubview:descLabel];
    [cell.contentView addSubview:textField];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *horiz = [[UIImageView alloc] initWithFrame:CGRectMake(17, 44.5, CGRectGetWidth(tableView.frame)-36,  0.5)];
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
    
    return cell;
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0;
}

-(void)onBtnAdd
{
    UITableViewCell *cell1 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITableViewCell *cell2 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    UITableViewCell *cell3 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UITableViewCell *cell4 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
    
    UITextField *textfield1 = (UITextField*)[cell1 viewWithTag:0x1001];
    UITextField *textfield2 = (UITextField*)[cell2 viewWithTag:0x1002];
    UITextField *textfield3 = (UITextField*)[cell3 viewWithTag:0x1003];
    UITextField *textfield4 = (UITextField*)[cell4 viewWithTag:0x1005];

    if (textfield1.text.length == 0 || textfield2.text.length == 0
        || textfield3.text.length == 0 || textfield4.text.length == 0) {
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"宝宝资料需要填全" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
        
        return;
    }
    
    BabyInfo *babyInfo = [BabyInfo new];
    
    if ([textfield2.text isEqualToString:@"男"])
    {
        babyInfo.sex = @"0";
    }
    else if([textfield2.text isEqualToString:@"女"])
    {
        babyInfo.sex = @"1";
    }
    else
    {
        babyInfo.sex = @"";
    }
    
    babyInfo.studentName = textfield1.text;
    babyInfo.birthDay = textfield3.text;
    babyInfo.relation = textfield4.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"处理中...";
    
    [[HttpService getInstance] addStudent:babyInfo andBlock:^(int retValue, NSString *studentId) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *messageTip = @"";
        
        if (retValue == 200)
        {
            babyInfo.studentId = studentId;
            [[HttpService getInstance].userExtentInfo.babyArray addObject:babyInfo];
            messageTip = @"添加宝宝成功";
            _succeed = YES;
        }
        else
        {
            messageTip = @"添加宝宝失败";
            _succeed = NO;
        }
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:messageTip delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
    }];
    
}

- (void)showDataSelector:(id)sender
{
    if (_calendar == nil) {
        _calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
        _calendar.frame = CGRectMake(10, 10, 300, 470);
        [self.view addSubview:_calendar];
        
        _calendar.delegate = self;
    }
    
    _calendar.hidden = NO;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    UITableViewCell *cell = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UITextField *textfield = (UITextField*)[cell viewWithTag:0x1003];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsSource = [myCal components:unitFlags fromDate:date];
    
    textfield.text = [NSString stringWithFormat:@"%04d-%02d-%02d", [compsSource year], [compsSource month], [compsSource day]];
    _calendar.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_succeed)
    {
        if (_style == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            selfServiceAddViewController *selfCtrl = [selfServiceAddViewController new];
            selfCtrl.userIndex = 0;
            
            [self.navigationController pushViewController:selfCtrl animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"createBabyViewController dealoc");
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
