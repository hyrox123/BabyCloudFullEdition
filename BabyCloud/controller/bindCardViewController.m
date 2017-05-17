//
//  bindCardViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "bindCardViewController.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "utilityFunction.h"
#import "ProtoType.h"
#import "KxMenu.h"
#import "MobClick.h"

@interface bindCardViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property(nonatomic) UITableView *infoTable;
@property(nonatomic) UILabel *childNameLable;
@property(nonatomic) int userIndex;

-(void)onMenuItem:(id)sender;
@end

@implementation bindCardViewController

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
    
    CGRect frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"绑定卡";
    self.navigationItem.titleView = titleLable;
    
    if ([HttpService getInstance].userExtentInfo.babyArray.count > 1) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"caidan"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    _childNameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(frame), 20)];
    [self.view addSubview:_childNameLable];
    
    _childNameLable.textAlignment = NSTextAlignmentCenter;
    _childNameLable.font = [UIFont boldSystemFontOfSize:18];
    _childNameLable.text = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[0]).studentName;
    
    self.infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, frame.size.width, 250) style:UITableViewStylePlain];
    [self.view addSubview:self.infoTable];
    
    self.infoTable.backgroundColor = [UIColor whiteColor];
    self.infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.infoTable setDelegate:self];
    [self.infoTable setDataSource:self];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btnNext];
    
    btnNext.layer.cornerRadius = 4;
    btnNext.layer.masksToBounds = YES;
    btnNext.frame = CGRectMake(10, 300, frame.size.width-20, 35);
    btnNext.showsTouchWhenHighlighted = YES;
    btnNext.titleLabel.font = [UIFont systemFontOfSize:20];
    btnNext.titleLabel.textColor = [UIColor whiteColor];
    btnNext.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    [btnNext setTitle: @"绑 定" forState: UIControlStateNormal];
    [btnNext addTarget:self action:@selector(onBtnNext) forControlEvents:UIControlEventTouchUpInside];
    
    _userIndex = 0;
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
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 80, 25)];
    UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 25)];
    textFiled.returnKeyType = UIReturnKeyDone;
    textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    textFiled.delegate = self;
    
    label.text = [NSString stringWithFormat:@"入离园卡%d", [indexPath row]+1];
    textFiled.placeholder = @"请输入您的卡号";
    textFiled.tag = 0x101;
    
    NSArray *tmpArray = [((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).entranceCardId componentsSeparatedByString:@","];
    
    if (tmpArray != nil)
    {
        if ([tmpArray count] > [indexPath row])
        {
            textFiled.text = [tmpArray objectAtIndex:[indexPath row]];
        }
        else
        {
            textFiled.text = @"";
        }
    }
    
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:textFiled];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *horiz = [[UIImageView alloc] initWithFrame:CGRectMake(10, 49.5, CGRectGetWidth(tableView.frame)-20,  0.5)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)onBtnNext
{
    UITableViewCell *cell1 = [_infoTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITableViewCell *cell2 = [_infoTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    UITableViewCell *cell3 = [_infoTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UITableViewCell *cell4 = [_infoTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
    UITextField *cardfield1 = (UITextField*)[cell1.contentView viewWithTag:0x101];
    UITextField *cardfield2 = (UITextField*)[cell2.contentView viewWithTag:0x101];
    UITextField *cardfield3 = (UITextField*)[cell3.contentView viewWithTag:0x101];
    UITextField *cardfield4 = (UITextField*)[cell4.contentView viewWithTag:0x101];
    
    NSString *entranceCardId = cardfield1.text;
    
    if (cardfield2.text.length > 0) {
        entranceCardId = [entranceCardId stringByAppendingString:[NSString stringWithFormat:@",%@", cardfield2.text]];
    }
    
    if (cardfield3.text.length > 0) {
        entranceCardId = [entranceCardId stringByAppendingString:[NSString stringWithFormat:@",%@", cardfield3.text]];
    }
    
    if (cardfield4.text.length > 0) {
        entranceCardId = [entranceCardId stringByAppendingString:[NSString stringWithFormat:@",%@", cardfield4.text]];
    }
    
    BabyInfo *babyInfo = [BabyInfo new];
    babyInfo.studentId = ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).studentId;
    babyInfo.entranceCardId = entranceCardId;
    
    if (babyInfo.entranceCardId.length == 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"入离园卡号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"处理中...";
        
        [[HttpService getInstance] modifyBabyInfo:babyInfo andBlock:^(int retValue) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MobClick event:@"BDK"];
            
            NSString *messageTip = @"";
            
            if (retValue == 200)
            {
                messageTip = @"添加入离园卡成功";
                
                if (babyInfo.entranceCardId.length > 0) {
                    ((BabyInfo*)[[HttpService getInstance].userExtentInfo.babyArray objectAtIndex:_userIndex]).entranceCardId = babyInfo.entranceCardId;
                }
            }
            else
            {
                messageTip = @"添加入离园卡失败";
            }
            
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:messageTip delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertV show];
        }];
    }
}

- (void)showMenu:(UIButton *)sender
{
    int itemIndex = 0;
    
    NSMutableArray *menuItems = [NSMutableArray new];
    
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
                  fromRect:CGRectMake([UIScreen mainScreen].bounds.size.width-50, -20, 50, 20)
                 menuItems:menuItems];
}

-(void)onMenuItem:(id)sender
{
    _userIndex = ((KxMenuItem*)sender).index;
    
    _childNameLable.text = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[_userIndex]).studentName;
    
    [_infoTable reloadData];
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
    NSLog(@"bindCardViewController dealoc");
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
