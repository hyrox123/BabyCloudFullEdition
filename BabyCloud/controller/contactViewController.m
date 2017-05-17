//
//  contactViewController.m
//  YSTParentClient
//
//  Created by apple on 15/5/15.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "contactViewController.h"
#import "MBProgressHUD.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "mobClick.h"
#import "UIImageView+WebCache.h"
#import "SDTransparentPieProgressView.h"
#import "RCIM.h"
#import "customerChatViewController.h"
#import "messageTipView.h"
#import "KxTextField.h"

@interface PhoneBtn : UIButton
@property(nonatomic) NSString *phoneNumber;
@end

@implementation PhoneBtn
@end

@interface contactViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property(nonatomic) UITableView *contactTable;
@property(nonatomic) NSMutableArray *selectedArray, *searchArray, *tmpArray1, *tmpArray2;
@property(nonatomic) KxTextField *searchField;
@property(nonatomic) UIButton *cancelBtn;
@property(nonatomic) NSMutableDictionary *tmpDict;
@property(nonatomic) BOOL searchMode;
@end

@implementation contactViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.contactArray.count > 0) {
        
        for (CandidateItem *item in self.selectedArray) {
            item.checked = NO;
        }
        
        [_selectedArray removeAllObjects];
        [_contactTable reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (NSMutableArray*)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray new];
    }
    
    return _selectedArray;
}

- (NSMutableArray*)searchArray
{
    if (!_searchArray) {
        _searchArray = [NSMutableArray new];
    }
    
    return _searchArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"联系人";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"聊天" style:UIBarButtonItemStylePlain target:self action:@selector(onConfirm)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _contactTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 15, clientRect.size.width, clientRect.size.height-80) style:UITableViewStyleGrouped];
    
    _contactTable.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contactTable];
    
    [_contactTable setDelegate:self];
    [_contactTable setDataSource:self];
    _contactTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [utilityFunction setExtraCellLineHidden:_contactTable];
    
    _searchField = [[KxTextField alloc] initWithFrame:CGRectZero];
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.enablesReturnKeyAutomatically = YES;
    _searchField.delegate = self;
    [self.view addSubview:_searchField];
    
    _searchField.backgroundColor = [UIColor colorWithRed:0.8784f green:0.8784f blue:0.8784f alpha:1.0f];
    _searchField.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _searchField.layer.borderWidth = 0.65f;
    _searchField.layer.cornerRadius = 6.0f;
    _searchField.frame = CGRectMake(5.0f, 8.0f, CGRectGetWidth(clientRect)-10, 36);
    _searchField.placeholder = @"输入联系人姓名";
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.textAlignment = NSTextAlignmentCenter;
    _searchField.hidden = YES;
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_cancelBtn];
    
    _cancelBtn.frame = CGRectMake(CGRectGetWidth(clientRect)+5, 15, 40, 20);
    _cancelBtn.showsTouchWhenHighlighted = YES;
    _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_cancelBtn setTitle: @"取消" forState: UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor colorWithRed:0.121f green:0.376f blue:1.0f alpha:1] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [_cancelBtn addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (self.contactArray == nil) {
        unsigned long completeGoal = [HttpService getInstance].userExtentInfo.babyArray.count+3;
        
        if (completeGoal > 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"加载联系人...";
        }
        
        _tmpArray1 = [NSMutableArray new];
        _tmpArray2 = [NSMutableArray new];
        _tmpDict = [NSMutableDictionary new];
        
        _organizationColum = 0;
        self.contactArray = _tmpArray1;
        self.classArray = _tmpArray2;
        self.contactStatusDict = _tmpDict;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[HttpService getInstance] queryContactsOneByOne:@"XXYGLS" organizationId:[HttpService getInstance].userExtentInfo.schoolId andBlock:^(NSMutableArray *resultArray) {
                
                if (resultArray.count > 0) {
                    NSMutableArray *teacherArray = [[NSMutableArray alloc] initWithArray:resultArray];
                    [self.contactStatusDict setValue:@"1-xx" forKey:@"0"];
                    [self.contactArray addObject:teacherArray];
                    _organizationColum++;
                }
            }];
            
            [[HttpService getInstance] queryContactsOneByOne:@"JWYZRZ" organizationId:[HttpService getInstance].userExtentInfo.schoolId andBlock:^(NSMutableArray *resultArray) {
                
                if (resultArray.count > 0) {
                    NSMutableArray *teacherArray = [[NSMutableArray alloc] initWithArray:resultArray];
                    [self.contactStatusDict setValue:@"1-jw" forKey:[NSString stringWithFormat:@"%lu", (unsigned long)self.contactArray.count]];
                    [self.contactArray addObject:teacherArray];
                    _organizationColum++;
                }
            }];
            
            [[HttpService getInstance] queryContactsOneByOne:@"DQXXYZ" organizationId:@"" andBlock:^(NSMutableArray *resultArray) {
                
                if (resultArray.count > 0) {
                    NSMutableArray *teacherArray = [[NSMutableArray alloc] initWithArray:resultArray];
                    [self.contactStatusDict setValue:@"1-dq" forKey:[NSString stringWithFormat:@"%lu", (unsigned long)self.contactArray.count]];
                    [self.contactArray addObject:teacherArray];
                    _organizationColum++;
                }
            }];
            
            //剔除重复的班级
            for (BabyInfo *babyInfo in [HttpService getInstance].userExtentInfo.babyArray) {
                
                if (babyInfo.classId != nil && babyInfo.classId.length > 0) {
                    
                    int repeateNum = 0;
                    for (BabyInfo *temp in self.classArray ){
                        if (temp.classId != nil && [temp.classId isEqualToString:babyInfo.classId]) {
                            repeateNum++;
                        }
                    }
                    
                    if (repeateNum == 0) {
                        [[HttpService getInstance] queryContactsOneByOne:@"BJJZLS" organizationId:babyInfo.classId andBlock:^(NSMutableArray *resultArray) {
                            {
                                NSMutableArray *studentArray = [[NSMutableArray alloc] initWithArray:resultArray];
                                [self.contactStatusDict setValue:@"1-jz" forKey:[NSString stringWithFormat:@"%lu", (unsigned long)self.contactArray.count]];
                                [self.contactArray addObject:studentArray];
                            }
                        }];
                        
                        [self.classArray addObject:babyInfo];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if([self.contactArray count] > 0)
                {
                    _searchField.hidden = NO;
                    _searchMode = NO;
                    [_contactTable reloadData];
                }
                else
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [messageTipView showTipView:self.view style:0 tip:@"没有找到联系人~"];
                    });
                }
            });
        });
        
    }
    else
    {
        if([self.contactArray count] > 0)
        {
            _searchField.hidden = NO;
            _searchMode = NO;
            [_contactTable reloadData];
        }
        else
        {
            [messageTipView showTipView:self.view style:0 tip:@"没有找到联系人~"];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searchMode) {
        return 1;
    }
    else
    {
        return [self.contactArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_searchMode) {
        return [self.searchArray count];
    }
    else
    {
        NSString *itemStatus = [self.contactStatusDict valueForKey:[NSString stringWithFormat:@"%ld", (long)section]];
        
        if (itemStatus.intValue == 1) {
            return [self.contactArray[section] count];
        }
        else
        {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storyTableCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"storyTableCell"];
    }
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIImageView *portraitV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 45, 45)];
    [cell.contentView addSubview:portraitV];
    
    portraitV.layer.masksToBounds = YES;
    portraitV.layer.cornerRadius = 8;
    
    UILabel *nicklabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 10, 150, 20)];
    [cell.contentView addSubview:nicklabel];
    
    nicklabel.font = [UIFont boldSystemFontOfSize:15];
    nicklabel.textColor = [UIColor blackColor];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    [cell.contentView addSubview:phoneLabel];
    
    phoneLabel.font = [UIFont systemFontOfSize:12];
    phoneLabel.textColor = [UIColor orangeColor];

    UILabel *desclabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 30, 150, 15)];
    [cell.contentView addSubview:desclabel];
    
    desclabel.font = [UIFont systemFontOfSize:12];
    desclabel.textColor = [UIColor lightGrayColor];
    
    PhoneBtn *phoneBtn = [PhoneBtn buttonWithType:UIButtonTypeCustom];
    [cell.contentView addSubview:phoneBtn];
    
    CandidateItem * item = nil;
    
    if (_searchMode) {
        item = [self.searchArray objectAtIndex:[indexPath row]];
    }
    else
    {
        NSMutableArray *array = [self.contactArray objectAtIndex:[indexPath section]];
        item = [array objectAtIndex:[indexPath row]];
    }
    
    phoneBtn.phoneNumber = item.phone;
    phoneBtn.frame = CGRectMake(CGRectGetWidth(tableView.frame)-80, 15, 30, 30);
    phoneBtn.showsTouchWhenHighlighted = YES;
    [phoneBtn setImage:[UIImage imageNamed:@"phoneBlue"] forState:UIControlStateNormal];
    [phoneBtn setImage:[UIImage imageNamed:@"phoneGray"] forState:UIControlStateSelected];
    [phoneBtn setImage:[UIImage imageNamed:@"phoneGray"] forState:UIControlStateHighlighted];
    [phoneBtn addTarget:self action:@selector(onBtnPhone:) forControlEvents:UIControlEventTouchUpInside];
    
    if (item.realName != nil && item.realName.length > 0) {
        nicklabel.text = item.realName;
    }
    else
    {
        nicklabel.text = item.nickName;
    }
    
    CGSize nicklabelW = [nicklabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15],NSFontAttributeName, nil]];
    phoneLabel.frame = CGRectMake(82+nicklabelW.width, 12, 100, 15);
   
    if (item.phone != nil && item.phone.length > 0) {
        phoneLabel.text = [NSString stringWithFormat:@"(%@)", item.phone];
    }
    else
    {
        phoneLabel.text = @"(无电话号码)";
    }

    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"4"]) {
        desclabel.text = item.schoolName;
        desclabel.font = [UIFont boldSystemFontOfSize:13];
        desclabel.textColor = [UIColor colorWithRed:0.3686f green:0.4275f blue:0.8275f alpha:1.0f];
    }
    else
    {
        if ([item.userType isEqualToString:@"1"]) {
            
            if (item.position != nil && item.position.length > 0)
            {
                desclabel.text = item.position;
            }
            else
            {
                desclabel.text = @"园长";
            }
            
            desclabel.font = [UIFont boldSystemFontOfSize:13];
            desclabel.textColor = [UIColor colorWithRed:0.3686f green:0.4275f blue:0.8275f alpha:1.0f];
        }
        else if([item.userType isEqualToString:@"2"])
        {
            if (item.position != nil && item.position.length > 0)
            {
                desclabel.text = item.position;
            }
            else
            {
                desclabel.text = @"老师";
            }
            
            desclabel.font = [UIFont boldSystemFontOfSize:13];
            desclabel.textColor = [UIColor colorWithRed:0.3686f green:0.4275f blue:0.8275f alpha:1.0f];
        }
        else if([item.userType isEqualToString:@"4"])
        {
            desclabel.text = @"教委工作人员";
            desclabel.font = [UIFont boldSystemFontOfSize:13];
            desclabel.textColor = [UIColor orangeColor];
        }
        else
        {
            if (item.relation != nil && item.relation.length > 0) {
                desclabel.text = [NSString stringWithFormat:@"%@同学的%@", item.studentName, item.relation];
            }
            else
            {
                desclabel.text = [NSString stringWithFormat:@"%@同学的家长", item.studentName];
            }
        }
    }
    
    if (item.portrait != nil && [item.portrait length] > 0 ) {
        
        NSString *portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, item.portrait];
        
        __block SDTransparentPieProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = portraitV;
        [portraitV sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
                     placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contactTX@2x" ofType:@"png"]]
                              options:SDWebImageProgressiveDownload
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 if (!activityIndicator) {
                                     activityIndicator = [SDTransparentPieProgressView progressView];
                                     activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-40)/2, (weakImageView.frame.size.height-40)/2, 40, 40);
                                     [weakImageView addSubview:activityIndicator];
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     activityIndicator.progress = (float)receivedSize/(float)expectedSize;
                                 });
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                [activityIndicator dismiss];
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
    }
    else
    {
        portraitV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contactTX@2x" ofType:@"png"]];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (item.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UIImageView *horiz = [[UIImageView alloc] initWithFrame:CGRectMake(10, 59.5, CGRectGetWidth(tableView.frame)-20,  0.5)];
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 45.0;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CandidateItem * item = nil;
    
    if (_searchMode) {
        item = [self.searchArray objectAtIndex:[indexPath row]];
    }
    else
    {
        NSMutableArray *array = [self.contactArray objectAtIndex:[indexPath section]];
        item = [array objectAtIndex:[indexPath row]];
    }
    
    item.checked = !item.checked;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (item.checked)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedArray addObject:item];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self removeUnselectedItem:item.rcid];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onConfirm
{
    if (self.selectedArray.count == 0)
    {
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有选择联系人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    else if (self.selectedArray.count == 1)
    {
        CandidateItem *item = self.selectedArray[0];
        
        NSString *title = nil;
        
        if (item.realName != nil && item.realName.length > 0)
        {
            title = item.realName;
        }
        else if(item.nickName != nil && item.nickName.length > 0)
        {
            title = item.nickName;
        }
        else
        {
            if (item.relation != nil && item.relation.length > 0)
            {
                title = [NSString stringWithFormat:@"%@同学的%@", item.studentName, item.relation];
            }
            else
            {
                title = [NSString stringWithFormat:@"%@同学的家长", item.studentName];
            }
        }
        
        customerChatViewController *chatViewCtrl = [[customerChatViewController alloc] init];
        chatViewCtrl.currentTarget = item.rcid;
        chatViewCtrl.currentTargetName = item.realName;
        chatViewCtrl.conversationType =  ConversationType_PRIVATE ;
        chatViewCtrl.enableUnreadBadge = YES;
        chatViewCtrl.enableVoIP = YES;
        
        [self.navigationController pushViewController:chatViewCtrl animated:YES];
    }
    else
    {
        NSMutableString *discussionName = [NSMutableString string];
        NSMutableArray *discussGroup = [NSMutableArray new];
        
        for (int i = 0; i < self.selectedArray.count; i++) {
            CandidateItem *item = self.selectedArray[i];
            
            if (i == self.selectedArray.count-1)
            {
                if(item.realName != nil && item.realName.length > 0)
                {
                    [discussionName appendString: item.realName];
                }
                else
                {
                    [discussionName appendString: item.nickName];
                }
            }
            else
            {
                if(item.realName != nil && item.realName.length > 0)
                {
                    [discussionName  appendString:[NSString stringWithFormat:@"%@%@", item.realName, @","]];
                }
                else
                {
                    [discussionName  appendString:[NSString stringWithFormat:@"%@%@", item.nickName, @","]];
                }
            }
            
            [discussGroup addObject:item.rcid];
        }
        
        NSArray *conversationTypeArray = [NSArray arrayWithObject:[[NSNumber alloc] initWithInteger:ConversationType_DISCUSSION]];
        NSArray *topicArray = [[RCIMClient sharedRCIMClient] getConversationList:conversationTypeArray];
        
        RCConversation *selectedTopic = [self findSameConversaion:discussionName topicArray:topicArray];
        
        if (!selectedTopic) {
            
            [[RCIMClient sharedRCIMClient]createDiscussion:discussionName userIdList:discussGroup completion:^(RCDiscussion *discussInfo) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    customerChatViewController *chat = [[customerChatViewController alloc] init];
                    chat.currentTarget = discussInfo.discussionId;
                    chat.currentTargetName = discussInfo.discussionName;
                    chat.conversationType = ConversationType_DISCUSSION;
                    chat.enableUnreadBadge = YES;
                    chat.enableVoIP = YES;
                    
                    [self.navigationController pushViewController:chat animated:YES];
                });
            } error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:@"创建讨论组失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                });
            }];
        }
        else
        {
            customerChatViewController *chat = [[customerChatViewController alloc] init];
            chat.currentTarget = selectedTopic.targetId;
            chat.currentTargetName = selectedTopic.conversationTitle;
            chat.conversationType = ConversationType_DISCUSSION;
            chat.enableUnreadBadge = YES;
            chat.enableVoIP = YES;
            
            [self.navigationController pushViewController:chat animated:YES];
        }
    }
}

- (void)removeUnselectedItem:(NSString*)rcId
{
    for (CandidateItem *item in self.selectedArray) {
        
        if ([item.rcid isEqualToString:rcId]) {
            [self.selectedArray removeObject:item];
            break;
        }
    }
}

- (RCConversation*)findSameConversaion:(NSString*)title topicArray:(NSArray*)topicArray
{
    BOOL  completeSame = false;
    RCConversation *topic = nil;
    
    for (RCConversation *conversationItem in topicArray) {
        
        NSArray *srcArray = [conversationItem.conversationTitle componentsSeparatedByString:@","];
        NSArray *dstArray = [title componentsSeparatedByString:@","];
        
        if (srcArray.count != dstArray.count) {
            break;
        }
        
        for (NSString *srcElement in srcArray)
        {
            completeSame = false;
            
            for (NSString *dstElement in dstArray)
            {
                if ([srcElement isEqualToString:dstElement])
                {
                    completeSame = true;
                    break;
                }
            }
            
            if (completeSame == false) {
                break;
            }
        }
        
        if (completeSame == true) {
            topic = conversationItem;
        }
    }
    
    return topic;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] init];
    UIView *pannelV = [[UIView alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(tableView.frame)-10, 35)];
    [headerView addSubview:pannelV];
    
    pannelV.backgroundColor = [UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f];
    pannelV.layer.cornerRadius = 4;
    pannelV.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 200, 20)];
    [headerView addSubview:titleLabel];
    
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    if (_searchMode) {
        titleLabel.text = @"查找到的联系人";
    }
    else
    {
        CGRect clientRect = [UIScreen mainScreen].bounds;
        
        UIButton *expendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [headerView addSubview:expendBtn];
        
        expendBtn.tag = 0x100+section;
        expendBtn.frame = CGRectMake(CGRectGetWidth(clientRect)-40, 13, 20, 20);
        expendBtn.showsTouchWhenHighlighted = YES;
        
        NSString *tmp = [self.contactStatusDict valueForKey:[NSString stringWithFormat:@"%ld", (long)section]];
        NSArray *elementsArray = [tmp componentsSeparatedByString:@"-"];
        NSString *status = elementsArray[0];
        NSString *orangnization = elementsArray[1];
        
        if ([orangnization isEqualToString:@"xx"]) {
            titleLabel.text = [HttpService getInstance].userExtentInfo.schoolName;
        }
        else if([orangnization isEqualToString:@"jw"])
        {
            titleLabel.text = @"教委园长热线";
        }
        else if([orangnization isEqualToString:@"dq"])
        {
            titleLabel.text = @"地区学校园长";
        }
        else
        {
            if ([self.classArray count] > section-_organizationColum) {
                titleLabel.text = ((BabyInfo*)self.classArray[section-_organizationColum]).className;
            }
            else
            {
                titleLabel.text = @"未知分类联系人";
            }
        }
        
        if ([status isEqualToString:@"1"])
        {
            expendBtn.selected = NO;
        }
        else
        {
            expendBtn.selected = YES;
        }
        
        [expendBtn setImage:[UIImage imageNamed:@"arrowDN"] forState:UIControlStateNormal];
        [expendBtn setImage:[UIImage imageNamed:@"arrowUP"] forState:UIControlStateSelected];
        [expendBtn setImage:[UIImage imageNamed:@"arrowUP"] forState:UIControlStateHighlighted];
        [expendBtn addTarget:self action:@selector(onBtnExpend:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return headerView;
}

- (void)onBtnExpend:(id)target
{
    UIButton *targetBtn = (UIButton*)target;
    
    if([_contactArray[targetBtn.tag-0x100] count] == 0)
    {
        return;
    }
    
    NSString *tmp = [self.contactStatusDict valueForKey:[NSString stringWithFormat:@"%d", targetBtn.tag-0x100]];
    NSArray *elementsArray = [tmp componentsSeparatedByString:@"-"];
    NSString *status = elementsArray[0];
    NSString *orangnization = elementsArray[1];
    
    if ([status isEqualToString:@"1"])
    {
        status = @"0";
    }
    else
    {
        status = @"1";
    }
    
    [self.contactStatusDict setValue:[NSString stringWithFormat:@"%@-%@", status, orangnization] forKey:[NSString stringWithFormat:@"%d", targetBtn.tag-0x100]];
    
    [UIView transitionWithView: self.contactTable
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         [self.contactTable reloadData];
     }
                    completion: ^(BOOL isFinished)
     {
         
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchContacts:textField.text];
    _searchMode = YES;
    [textField resignFirstResponder];
    [_contactTable reloadData];
    return YES;
}

- (void)onCancel
{
    _searchField.text = nil;
    _searchMode = NO;
    [_searchField resignFirstResponder];
    [_contactTable reloadData];
}

- (void)searchContacts:(NSString*)searchName
{
    [self.searchArray removeAllObjects];
    
    for (NSMutableArray *sectionArray in self.contactArray) {
        
        for (CandidateItem *item in sectionArray) {
            
            NSRange subRange = [item.realName rangeOfString:searchName];
            
            if (subRange.length > 0) {
                
                if (![self checkDuplicateInSearchArray:item.rcid]) {
                    [self.searchArray addObject:item];
                }
            }
        }
    }
}

- (BOOL)checkDuplicateInSearchArray:(NSString*)rcId
{
    BOOL duplicate = false;
    
    for (CandidateItem *item in self.searchArray) {
        
        if ([item.rcid isEqualToString:rcId]) {
            duplicate = YES;
            break;
        }
    }
    
    return duplicate;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    _searchField.frame = CGRectMake(5.0f, 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds)-60, 36);
    _cancelBtn.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-50, 15, 40, 20);
    _searchField.textAlignment = NSTextAlignmentLeft;
    
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    _cancelBtn.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)+5, 15, 40, 20);
    _searchField.frame = CGRectMake(5.0f, 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds)-10, 36);
    _searchField.textAlignment = NSTextAlignmentCenter;
    
    [UIView commitAnimations];
}

- (void)onBtnPhone:(id)sender
{
    PhoneBtn *btn = (PhoneBtn*)sender;
  
    if (btn.phoneNumber.length == 11) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", btn.phoneNumber]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"contactViewController dealloc");
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
