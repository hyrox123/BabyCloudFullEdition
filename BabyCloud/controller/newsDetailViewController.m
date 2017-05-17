//
//  newsDetailViewController.m
//  YSTParentClient
//
//  Created by apple on 15/5/4.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "newsDetailViewController.h"
#import "messageScrollViewController.h"
#import "HttpService.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"
#import "UIImageView+WebCache.h"
#import "ProtoType.h"
#import <QuartzCore/QuartzCore.h>
#import "MobClick.h"
#import "utilityFunction.h"
#import "StyledTableViewCell.h"
#import "historyNewsViewController.h"
#import "LCProgressHUD.h"

@interface newsDetailViewController ()<StyledTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>
@property(nonatomic) UITableView *newsTable;
@property(nonatomic) BOOL needRefresh, modfied;
@end

@implementation newsDetailViewController

- (void)viewWillDisappear:(BOOL)animated
{
    if (_modfied) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshNews"
         object:nil
         userInfo:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"通知详情";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    _newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    [self.view addSubview:_newsTable];
    
    _newsTable.backgroundColor = [UIColor colorWithRed:0.8627f green:0.8627f blue:0.8627f alpha:1.0f];
    _newsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _newsTable.delegate = self;
    _newsTable.dataSource = self;
    
    [utilityFunction setExtraCellLineHidden:_newsTable];
    
    [self.view bringSubviewToFront:self.messageToolView];
    [self.view bringSubviewToFront:self.faceView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"newsDetail";
    
    StyledTableViewCell *cell = (StyledTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (_needRefresh) {
        _needRefresh = NO;
        cell = nil;
    }
    
    if (cell == nil) {
        cell = [[StyledTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CustomCellIdentifier
                NewsItem:_item];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    return cell;
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [StyledTableViewCell calculateCellHeight:_item];
}

- (void)onTapImage:(NSString*)newsId index:(int)index
{
    [super hideKeyboard];
    
    messageScrollViewController *scrlCtrl = [messageScrollViewController new];
    scrlCtrl.imageArray = [NSMutableArray arrayWithArray:_item.imageArray];
    scrlCtrl.currentIndex = index;
    scrlCtrl.imageIsUrl = YES;
    
    [self presentViewController:scrlCtrl animated:YES completion:nil];
}

-(void)onTapReport:(NSString*)newsId
{
    [super showKeyboard:newsId type:1 andBlock:^(NSString *message) {
        
        [[HttpService getInstance] reportIllegal:newsId reason:message andBlock:^(int status) {
            
            if (status == 200)
            {
                [LCProgressHUD showStatus:LCProgressHUDStatusSuccess text:@"举报已受理"];
            }
            else
            {
                [LCProgressHUD showStatus:LCProgressHUDStatusError text: @"举报失败"];
            }
        }];
    }];
}

-(void)onTapComment:(NSString*)newsId
{
    [super showKeyboard:newsId type:0 andBlock:^(NSString *message) {
        
        [[HttpService getInstance] publishComment:newsId content:message andBlock:^(int retValue) {
            
            if (retValue == 200)
            {
                commentItem *item = [commentItem new];
                
                item.authorName = @"我";
                item.content = message;
                [self.item.commentArray addObject:item];
                _needRefresh = YES;
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [_newsTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"评论失败"];
            }
        }];
    }];
}

-(void)onTapPraise:(NSString*)newsId authorId:(NSString *)authorId
{
    [super hideKeyboard];
    
    if ([HttpService getInstance].userBaseInfo.score == 0) {
        [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"积分不够"];
        return;
    }
    
    if ([[HttpService getInstance].userId isEqualToString:authorId]) {
        [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"不能给自己送花"];        
        return;
    }
    
    [[HttpService getInstance] supportNotice:newsId authorId:authorId andBlock:^(int retValue) {
        
        if (retValue == 200)
        {
            [LCProgressHUD showStatus:LCProgressHUDStatusSuccess text:@"送花成功~"];
            [HttpService getInstance].userBaseInfo.score--;
            _item.supportNumber = [NSString stringWithFormat:@"%d",  [_item.supportNumber intValue]+1];
            _needRefresh = YES;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [_newsTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            NSString *tip = nil;
            
            if (retValue == 409) {
                tip = @"不能重复送花";
            }
            else
            {
                tip = @"服务器无响应";
            }
            
            [LCProgressHUD showStatus:LCProgressHUDStatusError text:tip];
        }
    }];
}

-(void)onTapAutor:(NSString*)authorId authorName:(NSString*)authorName portriat:(NSString*)portrait
{
    [super hideKeyboard];
    
    historyNewsViewController *historyCtrl = [historyNewsViewController new];
    historyCtrl.authorId = authorId;
    historyCtrl.authorName = authorName;
    historyCtrl.portrait = portrait;
    
    [self.navigationController pushViewController:historyCtrl animated:YES];
}

-(void)onTapDelete:(NSString*)newsId
{
    [super hideKeyboard];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:@"要删除这条消息吗?"
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"删除", nil];
    
    [alert show];
}

-(void)onTapBlank
{
    [super hideKeyboard];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[HttpService getInstance] deleteNotice:_item.newsId andBlock:^(int retValue) {
            
            if (retValue == 200)
            {
                _modfied = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"删除失败"];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"newsDetailViewController dealloc");
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
