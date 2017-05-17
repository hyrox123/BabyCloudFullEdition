//
//  babyInfoViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/31.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "babyInfoViewController.h"
#import "ProtoType.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "CKCalendarView.h"
#import "KxMenu.h"
#import "messageTipView.h"
#import "createBabyViewController.h"
#import "selfServiceAddViewController.h"
#import "LCProgressHUD.h"

@interface babyInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CKCalendarDelegate>
@property(nonatomic) UITableView *infoList;
@property(nonatomic) int selectDataRow, userIndex, menuType;
@property(nonatomic) CKCalendarView *calendar;

-(void)onBtnModify;
@end

@implementation babyInfoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[HttpService getInstance].userExtentInfo.babyArray count] > 0)
    {
        [_infoList reloadData];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"宝宝档案";
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"caidan"] style:UIBarButtonItemStylePlain target:self action:@selector(onOption:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:userBtn];
    
    userBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    userBtn.titleLabel.textColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    userBtn.frame = CGRectMake((self.view.frame.size.width/2)-40, 15, 80, 20);
    userBtn.showsTouchWhenHighlighted = YES;
    userBtn.tag = 0x300;
    [userBtn addTarget:self action:@selector(onStudent:) forControlEvents:UIControlEventTouchUpInside];
    
    _infoList = [[UITableView alloc] initWithFrame:CGRectMake(10, 45, clientRect.size.width-20, 350)];
    [self.view addSubview:_infoList];
    
    _infoList.delegate = self;
    _infoList.dataSource = self;
    _infoList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [utilityFunction setExtraCellLineHidden:_infoList];
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnConfirm.layer.cornerRadius = 4;
    btnConfirm.layer.masksToBounds = YES;
    btnConfirm.frame = CGRectMake(5, 340, clientRect.size.width-10, 35);
    btnConfirm.showsTouchWhenHighlighted = YES;
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:20];
    btnConfirm.titleLabel.textColor = [UIColor whiteColor];
    btnConfirm.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    [btnConfirm setTitle: @"修 改" forState: UIControlStateNormal];
    [btnConfirm addTarget:self action:@selector(onBtnModify) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnConfirm];
    
    btnConfirm.tag = 0x301;
    _userIndex = 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    UIButton *userBtn = (UIButton*)[self.view viewWithTag:0x300];
    UIButton *btnConfirm = (UIButton*)[self.view viewWithTag:0x301];
    
    if ([[HttpService getInstance].userExtentInfo.babyArray count] == 0)
    {
        [messageTipView showTipView:self.view style:0 tip:@"请添加宝宝~"];
        userBtn.hidden = YES;
        btnConfirm.hidden = YES;
        return 0;
    }
    else
    {
        [messageTipView removeTipView:self.view];
        userBtn.hidden = NO;
        btnConfirm.hidden = NO;
        
        [userBtn setTitle:((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).studentName forState: UIControlStateNormal];
        
        return 6;
    }
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
    
    BabyInfo *babyInfo = [[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex];
    
    if([indexPath row] == 0)
    {
        descLabel.text = @"姓名";
        textField.placeholder = @"宝宝真实姓名";
        textField.text = babyInfo.studentName;
        textField.tag = 0x1001;
    }
    else if ([indexPath row] == 1)
    {
        descLabel.text = @"性别";
        textField.placeholder = @"宝宝性别";
        
        if ([babyInfo.sex isEqualToString:@"0"])
        {
            textField.text = @"男";
        }
        else if ([babyInfo.sex isEqualToString:@"1"])
        {
            textField.text = @"女";
        }
        else
        {
            textField.text = @"";
        }
        
        textField.tag = 0x1002;
    }
    else if([indexPath row] == 2)
    {
        descLabel.text = @"出生日期";
        textField.text = babyInfo.birthDay;
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
        textField.text = babyInfo.relation;
        textField.placeholder = @"我是宝宝的";
        textField.tag = 0x1005;
    }
    else if([indexPath row] == 4)
    {
        descLabel.text = @"所属学校";
        
        if ([HttpService getInstance].userExtentInfo.schoolName != nil
            && [HttpService getInstance].userExtentInfo.schoolName.length > 0) {
            textField.text = [HttpService getInstance].userExtentInfo.schoolName;
        }
        else
        {
            textField.text = @"未分配";
        }
        
        textField.enabled = NO;
    }
    else if([indexPath row] == 5)
    {
        descLabel.text = @"所属班级";
        
        if (babyInfo.className != nil && babyInfo.className.length > 0) {
            textField.text = babyInfo.className;
        }
        else
        {
            textField.text = @"未分配";
            
            UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [cell.contentView addSubview:selectBtn];
            
            selectBtn.frame = CGRectMake(self.view.frame.size.width-110, 10, 80, 30);
            selectBtn.showsTouchWhenHighlighted = YES;
            selectBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            selectBtn.titleLabel.textColor = [UIColor whiteColor];
            selectBtn.backgroundColor = [UIColor whiteColor];
            [selectBtn setTitle: @"申请加班" forState: UIControlStateNormal];
            [selectBtn addTarget:self action:@selector(showAddClass:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        textField.enabled = NO;
    }
    
    [cell.contentView addSubview:descLabel];
    [cell.contentView addSubview:textField];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *horiz = [[UIImageView alloc] initWithFrame: CGRectMake(15, 44.5, CGRectGetWidth(tableView.frame)-30,  0.5)];
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

-(void)onBtnModify
{
    UITableViewCell *cell1 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITableViewCell *cell2 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    UITableViewCell *cell3 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UITableViewCell *cell4 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
    
    UITextField *textfield1 = (UITextField*)[cell1 viewWithTag:0x1001];
    UITextField *textfield2 = (UITextField*)[cell2 viewWithTag:0x1002];
    UITextField *textfield3 = (UITextField*)[cell3 viewWithTag:0x1003];
    UITextField *textfield4 = (UITextField*)[cell4 viewWithTag:0x1005];
    
    
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
    babyInfo.studentId = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).studentId;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"处理中...";
    
    [[HttpService getInstance] modifyBabyInfo:babyInfo andBlock:^(int retValue) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *messageTip = @"";
        
        if (retValue == 200)
        {
            messageTip = @"修改宝宝信息成功";
            
            if (babyInfo.sex.length > 0) {
                ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).sex = babyInfo.sex;
            }
            
            if (babyInfo.studentName.length > 0) {
                ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).studentName = babyInfo.studentName;
            }
            
            if (babyInfo.birthDay.length > 0) {
                ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).birthDay = babyInfo.birthDay;
            }
            
            if (babyInfo.relation.length > 0) {
                ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).relation = babyInfo.relation;
            }
        }
        else
        {
            messageTip = @"修改宝宝信息失败";
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

- (void)onStudent:(UIButton*)sender
{
    _menuType = 0;
    [self showMenu:sender];
}

- (void)onOption:(UIButton*)sender
{
    _menuType = 1;
    [self showMenu:sender];
}

- (void)showAddClass:(UIButton*)sender
{
    selfServiceAddViewController *selfAddCtrl = [[selfServiceAddViewController alloc] init];
    selfAddCtrl.hidesBottomBarWhenPushed = YES;
    selfAddCtrl.userIndex = _userIndex;
    
    [self.navigationController pushViewController:selfAddCtrl animated:YES];
}

- (void)showMenu:(UIButton *)sender
{
    int itemIndex = 0;
    
    NSMutableArray *menuItems = [NSMutableArray new];
    
    if (_menuType == 0)
    {
        for (BabyInfo *babyInfo in [HttpService getInstance].userExtentInfo.babyArray ) {
            
            KxMenuItem *item = [KxMenuItem menuItem:babyInfo.studentName
                                              image:nil
                                             target:self
                                             action:@selector(onMenuItem:)];
            
            [menuItems addObject:item];
            item.index = itemIndex;
            itemIndex++;
        }
        
        [KxMenu showMenuInView:self.view
                      fromRect:sender.frame
                     menuItems:menuItems];
    }
    else
    {
        
        KxMenuItem *item1 = [KxMenuItem menuItem:@"添加宝宝"
                                           image:nil
                                          target:self
                                          action:@selector(onMenuItem:)];
        
        [menuItems addObject:item1];
        item1.index = 0;
        
        if ([HttpService getInstance].userExtentInfo.babyArray.count > _userIndex)
        {
            KxMenuItem *item2 = [KxMenuItem menuItem:@"删除宝宝"
                                               image:nil
                                              target:self
                                              action:@selector(onMenuItem:)];
            
            [menuItems addObject:item2];
            item2.index = 1;
        }
        
        [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake([UIScreen mainScreen].bounds.size.width-50, -20, 50, 20)
                     menuItems:menuItems];
    }
}

- (void)onMenuItem:(id)sender
{
    if (_menuType == 0)
    {
        _userIndex = ((KxMenuItem*)sender).index;
        
        UIButton *userBtn = (UIButton*)[self.view viewWithTag:0x300];
        BabyInfo *babyInfo = [[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex];
        
        if (userBtn != nil) {
            [userBtn setTitle:babyInfo.studentName forState:UIControlStateNormal];
        }
        
        [_infoList reloadData];
    }
    else
    {
        if (((KxMenuItem*)sender).index == 0)
        {
            createBabyViewController *createBabyCtrl = [createBabyViewController new];
            createBabyCtrl.hidesBottomBarWhenPushed = YES;
            createBabyCtrl.style = 0;
            
            [self.navigationController pushViewController:createBabyCtrl animated:YES];
        }
        else
        {
            BabyInfo *babyInfo = [[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex];
            
            if (babyInfo.classId != nil && babyInfo.classId.length > 0)
            {
                NSString *messageTip =  [NSString stringWithFormat:@"%@小朋友已经分班,请联系老师删除", babyInfo.studentName];
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:messageTip delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertV show];
            }
            else
            {
                NSString *messageTip =  [NSString stringWithFormat:@"要删除%@小朋友的资料吗?", babyInfo.studentName];
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:messageTip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertV show];
            }
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        BabyInfo *babyInfo = [[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex];
        [[HttpService getInstance] deleteStudent:babyInfo.studentId andBlock:^(int retValue) {
            
            if (retValue == 200) {
                
                [[HttpService getInstance].userExtentInfo.babyArray removeObjectAtIndex:_userIndex];
                
                if (_userIndex > 0) {
                    _userIndex--;
                }
                
                [LCProgressHUD showStatus:LCProgressHUDStatusSuccess text:@"删除成功"];
                
                [_infoList reloadData];
            }
            else
            {
                [LCProgressHUD showStatus:LCProgressHUDStatusError text: @"删除失败"];
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"babyInfoViewController dealoc");
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
