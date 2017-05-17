//
//  conversationViewController.m
//  YSTParentClient
//
//  Created by apple on 14-12-22.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "conversationViewController.h"
#import "InfoTableViewCell.h"
#import "HttpService.h"
#import "RCIM.h"
#import "RCChatViewController.h"
#import "RCChatListViewController.h"
#import "RCGroupListViewController.h"
#import "MBProgressHUD.h"
#import "userInfoViewController.h"
#import "utilityFunction.h"
#import "ProtoType.h"
#import "MobClick.h"
#import "candidateViewController.h"
#import "contactViewController.h"
#import "messageTipView.h"

@interface conversationViewController()<UITableViewDataSource,UITableViewDelegate,RCIMReceiveMessageDelegate,RCIMFriendsFetcherDelegate,RCIMUserInfoFetcherDelegagte,RCIMGroupInfoFetcherDelegate>

@property(nonatomic) UITableView *friendList;
@property(nonatomic) int columCount;
@property(nonatomic) NSMutableArray *contactsArray, *classArray, *columnArray;
@property(nonatomic) NSMutableDictionary *contactDict, *contactStatusDict;


-(id)getCandidateByRcid:(NSString*)rcId;
@end

@implementation conversationViewController

- (conversationViewController*)init
{
    self = [super init];
    
    if (self) {
        
        [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
        _columCount = 0;
    }
    
    return self;
}

- (NSMutableArray*)contactsArray
{
    if (_contactsArray == nil) {
        _contactsArray = [NSMutableArray new];
    }
    
    return _contactsArray;
}

- (NSMutableArray*)columnArray
{
    if (_columnArray == nil) {
        _columnArray = [NSMutableArray new];
    }
    
    return _columnArray;
}

- (NSMutableArray*)classArray
{
    if (_classArray == nil) {
        _classArray = [NSMutableArray new];
    }
    
    return _classArray;
}

- (NSMutableDictionary*)contactDict
{
    if (_contactDict == nil) {
        _contactDict = [NSMutableDictionary new];
    }
    
    return _contactDict;
}

- (NSMutableDictionary*)contactStatusDict
{
    if (!_contactStatusDict) {
        _contactStatusDict = [NSMutableDictionary new];
    }
    
    return _contactStatusDict;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([HttpService getInstance].isConnectedIM == YES)
    {
        [_friendList reloadData];
    }
    else
    {
        [messageTipView showTipView:self.view style:0 tip:@"服务不可用~"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"会 话";
    
    self.navigationItem.titleView = titleLable;
    
    _friendList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-112) style:UITableViewStylePlain];
    [self.view addSubview:_friendList];
    
    _friendList.backgroundColor = [UIColor whiteColor];
    _friendList.delegate = self;
    _friendList.dataSource = self;
    
    [utilityFunction setExtraCellLineHidden:_friendList];
    [self.view addSubview:_friendList];
    
    [RCIM setUserInfoFetcherWithDelegate:self isCacheUserInfo:true];
    [RCIM setFriendsFetcherWithDelegate:self];
    [RCIM setGroupInfoFetcherWithDelegate:self];
    
    if ([HttpService getInstance].isConnectedIM == YES
        && ![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"9"])
    {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"同步联系人...";
        
        [self.contactsArray removeAllObjects];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[HttpService getInstance] queryContactsOneByOne:@"XXYGLS" organizationId:[HttpService getInstance].userExtentInfo.schoolId andBlock:^(NSMutableArray *resultArray) {
                
                if (resultArray.count > 0) {
                    [self.contactsArray addObjectsFromArray:resultArray];
                    
                    NSMutableArray *teacherArray = [[NSMutableArray alloc] initWithArray:resultArray];
                    [self.contactStatusDict setValue:@"1-xx" forKey:@"0"];
                    [self.columnArray addObject:teacherArray];
                    _columCount++;
                }
            }];
            
            [[HttpService getInstance] queryContactsOneByOne:@"JWYZRZ" organizationId:[HttpService getInstance].userExtentInfo.schoolId andBlock:^(NSMutableArray *resultArray) {
                
                if (resultArray.count > 0) {
                    [self.contactsArray addObjectsFromArray:resultArray];
                    
                    NSMutableArray *teacherArray = [[NSMutableArray alloc] initWithArray:resultArray];
                    [self.contactStatusDict setValue:@"1-jw" forKey:[NSString stringWithFormat:@"%d", self.columnArray.count]];
                    [self.columnArray addObject:teacherArray];
                    _columCount++;
                }
            }];
            
            [[HttpService getInstance] queryContactsOneByOne:@"DQXXYZ" organizationId:@"" andBlock:^(NSMutableArray *resultArray) {
                
                if (resultArray.count > 0) {
                    [self.contactsArray addObjectsFromArray:resultArray];
                    
                    NSMutableArray *teacherArray = [[NSMutableArray alloc] initWithArray:resultArray];
                    [self.contactStatusDict setValue:@"1-dq" forKey:[NSString stringWithFormat:@"%d", self.columnArray.count]];
                    [self.columnArray addObject:teacherArray];
                    _columCount++;
                }
            }];
            
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
                                [self.contactsArray addObjectsFromArray:resultArray];
                                
                                NSMutableArray *studentArray = [[NSMutableArray alloc] initWithArray:resultArray];
                                [self.contactStatusDict setValue:@"1-jz" forKey:[NSString stringWithFormat:@"%d", self.columnArray.count]];
                                [self.columnArray addObject:studentArray];
                            }
                        }];
                        
                        [self.classArray addObject:babyInfo];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
        [[RCIM sharedRCIM] setUserPortraitClickEvent:^(UIViewController *viewController, RCUserInfo *userInfo)
         {
             if (![userInfo.userId isEqualToString:[HttpService getInstance].rcId])
             {
                 UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
                 backItem.title = @"返回";
                 viewController.navigationItem.backBarButtonItem = backItem;
                 
                 userInfoViewController *infoCtrl = [[userInfoViewController alloc] init];
                 infoCtrl.personInfo.rcid = userInfo.userId;
                 infoCtrl.personInfo.nickName = userInfo.name;
                 infoCtrl.personInfo.portrait = userInfo.portraitUri;
                 infoCtrl.solidStyle = NO;
                 [self.navigationController pushViewController:infoCtrl animated:YES];
             }
         }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([HttpService getInstance].isConnectedIM == NO)
    {
        return 0;
    }
    else
    {
        return 2;
    }
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
    
    if (row == 0)
    {
        if ([((NSString*)[self.contactDict valueForKey:@"private"]) integerValue] > 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"xiaoxi1.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"xiaoxi.png"];
        }
        
        cell.nameLabel.text = @"会话";
        cell.decLabel.text  = @"聊天记录";
        cell.updateTimeLabel.text = @"";
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"tongxunlu.png"];
        cell.nameLabel.text = @"通讯录";
        cell.decLabel.text  = @"联系人通讯录";
        cell.updateTimeLabel.text = @"";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"HHLT"];
    
    if (indexPath.row == 0)
    {
        candidateViewController *chatListViewController = [[candidateViewController alloc] init];
        [self.contactDict setValue:@"0" forKey:@"private"];
        
        chatListViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatListViewController animated:YES];
    }
    else
    {
        contactViewController *contactsList = [contactViewController new];
        
        contactsList.hidesBottomBarWhenPushed = YES;
        contactsList.classArray = self.classArray;
        contactsList.contactArray = self.columnArray;
        contactsList.contactStatusDict = self.contactStatusDict;
        contactsList.organizationColum = self.columCount;
        
        [self.navigationController pushViewController:contactsList animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray*)getFriends
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (CandidateItem *item in _contactsArray)
    {
        RCUserInfo *user = [[RCUserInfo alloc] init];
        user.userId = item.rcid;
        
        if (item.realName != nil && [item.realName length] > 0)
        {
            user.name = item.realName;
        }
        else
        {
            user.name = item.nickName;
        }
        
        user.portraitUri = item.portrait;
        [array addObject:user];
    }
    
    return array;
}

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(RCUserInfo* userInfo))completion
{
    if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"9"])
    {
        RCUserInfo *user = nil;
        CandidateItem *item = nil;
        NSString *portraitUrl = nil, *displayName = nil;
        
        if ([userId isEqualToString:[HttpService getInstance].rcId] == YES)
        {
            if ([HttpService getInstance].userBaseInfo.portrait != nil
                && [HttpService getInstance].userBaseInfo.portrait.length > 0)
            {
                portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, [HttpService getInstance].userBaseInfo.portrait];
            }
            
            if ( [HttpService getInstance].userBaseInfo.realName != nil
                && [[HttpService getInstance].userBaseInfo.realName length] > 0)
            {
                displayName = [HttpService getInstance].userBaseInfo.realName;
            }
            else if([HttpService getInstance].userBaseInfo.nickName != nil
                    && [[HttpService getInstance].userBaseInfo.nickName length] > 0)
            {
                displayName = [HttpService getInstance].userBaseInfo.nickName;
            }
            else
            {
                displayName = [HttpService getInstance].userName;
            }
            
            user = [[RCUserInfo alloc] initWithUserId:userId name:displayName portrait:portraitUrl];
        }
        else
        {
            item = [self getCandidateByRcid:userId];
            
            if (item) {
                
                if (item.portrait != nil && item.portrait.length > 0) {
                    portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, item.portrait];
                }
                
                if (item.realName != nil && [item.realName length] > 0)
                {
                    displayName = item.realName;
                }
                else if(item.nickName != nil &&  [item.nickName length] > 0)
                {
                    displayName = item.nickName;
                }
                else
                {
                    displayName = item.rcid;
                }
                
                user = [[RCUserInfo alloc] initWithUserId:userId name:displayName portrait:portraitUrl];
            }
            else
            {
                user = [[RCUserInfo alloc] initWithUserId:userId name:[userId substringFromIndex:10] portrait:portraitUrl];
            }
        }
        
        return completion(user);
    }
    else
    {
        [[HttpService getInstance] queryUserInfoByRcid:userId andBlock:^(RCUserInfo *rcUsrInf) {
            return completion(rcUsrInf);
        }];
    }
}

-(void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup *group))completion
{
    if ([groupId isEqualToString:[HttpService getInstance].userExtentInfo.schoolId] == YES)
    {
        RCGroup *group = [[RCGroup alloc] initWithGroupId:groupId groupName:[HttpService getInstance].userExtentInfo.schoolName portraitUri:nil];
        return completion(group);
    }
    else
    {
        for (BabyInfo* item in self.classArray)
        {
            if ([item.classId isEqualToString:groupId] == YES) {
                RCGroup *group = [[RCGroup alloc] initWithGroupId:groupId groupName:item.className portraitUri:nil];
                return completion(group);
            }
        }
    }
    
    return completion(nil);
}


-(void)didReceivedMessage:(RCMessage*)message left:(int)left
{
    int unreadMessage = 0;
    
    if (message.conversationType == ConversationType_PRIVATE)
    {
        unreadMessage = [((NSString*)[self.contactDict valueForKey:@"private"]) integerValue];
        unreadMessage++;
        
        [self.contactDict setValue:[NSString stringWithFormat:@"%d", unreadMessage] forKey:@"private"];
    }
    else if(message.conversationType == ConversationType_GROUP)
    {
        unreadMessage = [((NSString*)[self.contactDict valueForKey:message.targetId]) integerValue];
        unreadMessage++;
        
        [self.contactDict setValue:[NSString stringWithFormat:@"%d", unreadMessage] forKey:message.targetId];
    }
    else if (message.conversationType == ConversationType_SYSTEM)
    {
        if ([message.content isMemberOfClass:RCTextMessage.class])
        {
            RCTextMessage *textMessage = (RCTextMessage*)message.content;
        }
    }
    
    if (unreadMessage > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_friendList reloadData];
        });
    }
}

-(CandidateItem*)getCandidateByRcid:(NSString*)rcId
{
    CandidateItem *candidateItem = nil;
    
    for (int i = 0; i < [self.contactsArray count]; i++) {
        CandidateItem *item = [self.contactsArray objectAtIndex:i];
        
        if ([item.rcid isEqualToString:rcId] == YES) {
            candidateItem = item;
        }
    }
    
    return candidateItem;
}

-(void)unloadConversationCtrl
{
    [[RCIM sharedRCIM] disconnect];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:nil];
    [RCIM setFriendsFetcherWithDelegate:nil];
    [RCIM setGroupInfoFetcherWithDelegate:nil];
    [RCIM setUserInfoFetcherWithDelegate:nil isCacheUserInfo:NO];
}

- (void)dealloc
{
    [_friendList setDelegate:nil];
    [_friendList setDataSource:nil];
    
    NSLog(@"conversationViewController dealloc");
}

@end
