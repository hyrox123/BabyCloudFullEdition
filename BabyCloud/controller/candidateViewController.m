//
//  candidateViewController.m
//  YSTParentClient
//
//  Created by apple on 15/5/15.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "candidateViewController.h"
#import "customerChatViewController.h"
#import "contactViewController.h"
#import "RCIM.h"


@interface candidateViewController ()

@end

@implementation candidateViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    bool needReload = false;
    
    for (int i = 0; i < self.conversationStore.count; i++) {
        
        RCConversation *topic = self.conversationStore[i];
        
        if (topic.conversationType != ConversationType_PRIVATE
            && topic.conversationType != ConversationType_DISCUSSION) {
  
            [[RCIM sharedRCIM] removeConversation:topic.conversationType targetId:topic.targetId];
            needReload = true;
        }
    }
    
    if (needReload) {
        [self.conversationListView reloadData];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"qunliaotianjia"] style:UIBarButtonItemStylePlain target:self action:@selector(onContacts)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    UILabel *title = (UILabel*)self.navigationItem.titleView;
    title.textColor = [UIColor blackColor];
    
    UIBarButtonItem *currentBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = currentBackItem;
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSelectCandidate
{
  
}

- (void)onContacts
{
    contactViewController *contactsList = [contactViewController new];
    contactsList.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contactsList animated:YES];
}

-(void)onSelectedTableRow:(RCConversation*)conversation{
    
    //该方法目的延长会话聊天UI的生命周期
    customerChatViewController* chat = [self getChatController:conversation.targetId conversationType:conversation.conversationType];
    
    if (nil == chat) {
        chat =[[customerChatViewController alloc] init];
        chat.portraitStyle = RCUserAvatarCycle;
        [self addChatController:chat];
    }
    
    chat.currentTarget = conversation.targetId;
    chat.conversationType = conversation.conversationType;
    chat.currentTargetName = conversation.conversationTitle;
    
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"candidateViewController dealloc");
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
