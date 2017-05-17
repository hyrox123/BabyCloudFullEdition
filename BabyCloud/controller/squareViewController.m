//
//  squareViewController.m
//  YSTParentClient
//
//  Created by apple on 15/9/9.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "squareViewController.h"
#import "HttpService.h"
#import "utilityFunction.h"
#import "StyledTableViewCell.h"
#import "messageScrollViewController.h"
#import "publishMessageViewController.h"
#import "ProtoType.h"
#import "MJRefresh.h"
#import "MobClick.h"
#import "reportView.h"
#import "historyNewsViewController.h"
#import "LCProgressHUD.h"

@interface squareViewController ()<StyledTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>
@property(nonatomic) UITableView *newsTable;
@property(nonatomic) UILabel *describLabel;
@property(nonatomic) NSMutableArray *newsArray;
@property(nonatomic) NSString *imgServerUrl, *selectedNewsId, *reloadCell;
@property(nonatomic) int totalPage, currentPage;
@property(nonatomic) bool isLoading, needLoad;

-(void)setupRefresh;
-(void)headerRereshing;
-(void)footerRereshing;
@end

@implementation squareViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"快乐广场"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"快乐广场"];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_needLoad == YES)
    {
        [super hideKeyboard];
        [self refreshAll];
    }
}

- (void)refreshAll
{
    _needLoad = NO;
    _currentPage = 0, _totalPage = 0;
    [_newsTable headerBeginRefreshing];
}

- (NSMutableArray*)newsArray
{
    if (_newsArray == nil) {
        _newsArray = [NSMutableArray new];
    }
    
    return _newsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"快乐广场";
    
    self.navigationItem.titleView = titleLable;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"jiahao_"] style:UIBarButtonItemStylePlain target:self action:@selector(onPublish)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    _newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    [self.view addSubview:_newsTable];
    
    self.newsTable.backgroundColor = [UIColor whiteColor];
    self.newsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _newsTable.delegate = self;
    _newsTable.dataSource = self;
    
    _describLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, clientRect.size.width, 20)];
    [self.view addSubview:_describLabel];
    
    _describLabel.font = [UIFont boldSystemFontOfSize:16];
    _describLabel.textColor = [UIColor lightGrayColor];
    _describLabel.textAlignment = NSTextAlignmentCenter;
    
    [utilityFunction setExtraCellLineHidden:_newsTable];
    
    _needLoad = NO;
    _currentPage = 0, _totalPage = 0;
    
    [_newsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newsTableCell"];
    [self setupRefresh];
    
    [self.view bringSubviewToFront:self.messageToolView];
    [self.view bringSubviewToFront:self.faceView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needRefresh:)
                                                 name:@"refreshNews"
                                               object:nil];

}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_newsTable addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"squareTable"];
    [_newsTable headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_newsTable addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _newsTable.headerPullToRefreshText = @"下拉可以刷新了";
    _newsTable.headerReleaseToRefreshText = @"松开马上刷新了";
    _newsTable.headerRefreshingText = @"正在查找新的内容";
    
    _newsTable.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _newsTable.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _newsTable.footerRefreshingText = @"正在查找历史内容";
}

- (void)headerRereshing
{
    if (_isLoading == NO && _totalPage == 0)
    {
        _isLoading = YES;
        _describLabel.text = @"";
        
        [[HttpService getInstance] querySquareNews:1 noticeType:@"" andBlock:^(NSMutableArray *noticeArray, NSDictionary *dict) {
            
            _isLoading = NO;
            _imgServerUrl = [dict objectForKey:@"imgServerUrl"];
            [_newsTable headerEndRefreshing];
            [_newsTable footerEndRefreshing];
            
            if (noticeArray != nil && [noticeArray count] > 0)
            {
                [_newsArray removeAllObjects];
                [_newsArray addObjectsFromArray:noticeArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                
                [self.newsTable reloadData];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _describLabel.text = @"还没有人在广场上发表过内容:(~";
                });
            }
        }];
    }
    else
    {
        [_newsTable headerEndRefreshing];
    }
}

- (void)footerRereshing
{
    if (_isLoading)
    {
        return;
    }
    
    if (_totalPage == _currentPage)
    {
        [_newsTable footerEndRefreshing];
    }
    else
    {
        _isLoading = YES;
        [[HttpService getInstance] querySquareNews:_currentPage+1 noticeType:@"" andBlock:^(NSMutableArray *noticeArray, NSDictionary *dict) {
            
            _isLoading = NO;
            _imgServerUrl = [dict objectForKey:@"imgServerUrl"];
            [_newsTable headerEndRefreshing];
            [_newsTable footerEndRefreshing];
            
            if (noticeArray != nil && [noticeArray count] > 0)
            {
                [_newsArray addObjectsFromArray:noticeArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                
                [self.newsTable reloadData];
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsArray count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultPannel"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"defaultPannel"];
        }
        
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetWidth(tableView.frame)*0.5468)];
        [cell.contentView addSubview:headerView];
        
        headerView.layer.contents = (__bridge id)([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"squareHeader@2x" ofType:@"png"]].CGImage);
        return cell;
    }
    
    NewsItem *item = [self.newsArray objectAtIndex:indexPath.row-1];
    NSString * identifier = [NSString stringWithFormat:@"cell-%@", item.newsId];
    item.open = YES;
    
    StyledTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if ([_reloadCell isEqualToString:identifier]) {
        _reloadCell = @"";
        cell = nil;
    }
    
    if (cell == nil) {
        
        cell = [[StyledTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:identifier
                NewsItem:item];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    return cell;
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return CGRectGetWidth(tableView.frame)*0.5468;
    }
    
    NewsItem *item = [self.newsArray objectAtIndex:indexPath.row-1];
    return [StyledTableViewCell calculateCellHeight:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)onTapImage:(NSString*)newsId index:(int)index
{
    [super hideKeyboard];
    
    int idx = [self findNewsIndex:newsId];
    
    if (idx != -1)
    {
        NewsItem *item = [_newsArray objectAtIndex:idx];
        
        if(item != nil)
        {
            messageScrollViewController *scrlCtrl = [messageScrollViewController new];
            scrlCtrl.imageArray = [NSMutableArray arrayWithArray:item.imageArray];
            scrlCtrl.currentIndex = index;
            scrlCtrl.imageIsUrl = YES;
            
            [self presentViewController:scrlCtrl animated:YES completion:nil];
        }
    }
}

-(void)onTapDelete:(NSString*)newsId
{
    [super hideKeyboard];
    
    _selectedNewsId = newsId;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:@"要删除这条消息吗?"
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"删除", nil];
    
    [alert show];
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
                int index = [self findNewsIndex:newsId];
                
                if (index != -1) {
                    NewsItem *item1 = _newsArray[index];
                    commentItem *item2 = [commentItem new];
                    
                    item2.authorName = @"我";
                    item2.content = message;
                    [item1.commentArray addObject:item2];
                    
                    _reloadCell = [NSString stringWithFormat:@"cell-%@", newsId];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
                    [_newsTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                }
                else
                {
                    [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"评论失败"];
                }
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
            
            int index = [self findNewsIndex:newsId];
            
            if (index != -1) {
                
                NewsItem *item = _newsArray[index];
                item.supportNumber = [NSString stringWithFormat:@"%d",  [item.supportNumber intValue]+1];
                
                _reloadCell = [NSString stringWithFormat:@"cell-%@", newsId];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
                [_newsTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
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
    historyCtrl.squareSearch = YES;
    
    [self.navigationController pushViewController:historyCtrl animated:YES];
}

-(void)onTapBlank
{
    [super hideKeyboard];
}

- (void)onPublish
{
    if (_imgServerUrl == nil) {
        return;
    }
    
    publishMessageViewController *ctrl = [publishMessageViewController new];
    ctrl.messageType = @"";
    ctrl.imgServerUrl = _imgServerUrl;
    
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(int)findNewsIndex:(NSString*)newsId
{
    int index = -1;
    
    for (int i = 0; i < _newsArray.count; i++)
    {
        NewsItem *item = [_newsArray objectAtIndex:i];
        
        if ([item.newsId isEqualToString:newsId]) {
            index = i;
            break;
        }
    }
    
    return index;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        int index = [self findNewsIndex:_selectedNewsId];
        
        if (index != -1)
        {
            
            NewsItem *item = [_newsArray objectAtIndex:index];
            
            [[HttpService getInstance] deleteNotice:item.newsId andBlock:^(int retValue) {
                
                if (retValue == 200)
                {
                    if ([_newsArray count] > index)
                    {
                        [_newsArray removeObjectAtIndex:index];
                    }
                    
                    [_newsTable reloadData];
                }
                else
                {
                    [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"删除失败"];
                }
            }];
        }
        else
        {
            [LCProgressHUD showStatus:LCProgressHUDStatusError text:@"删除失败"];
        }
    }
}

-(void)needRefresh:(NSNotification*)notification {
    _needLoad = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"squareViewController dealloc");
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
