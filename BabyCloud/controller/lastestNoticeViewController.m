//
//  lastestNoticeViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "lastestNoticeViewController.h"
#import "publishMessageViewController.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "messageTipView.h"
#import "MJRefresh.h"
#import "MobClick.h"
#import "XAbstractTableViewCell.h"
#import "newsDetailViewController.h"

@interface lastestNoticeViewController()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic) UITableView *newsTable;
@property(nonatomic) NSMutableArray *newsArray;
@property(nonatomic) NSString *imgServerUrl;
@property(nonatomic) int totalPage, currentPage;
@property(nonatomic) bool isLoading, needLoad;

-(void)onPublish;
-(void)setupRefresh;
-(void)headerRereshing;
-(void)footerRereshing;
@end

@implementation lastestNoticeViewController

- (void)viewDidAppear:(BOOL)animated
{
    if (_needLoad)
    {
        _needLoad = NO;
        _currentPage = 0, _totalPage = 0;
        [_newsTable headerBeginRefreshing];
    }
}

- (NSMutableArray*)newsArray
{
    if (_newsArray == nil) {
        _newsArray = [NSMutableArray new];
    }
    
    return _newsArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@-XXTZSubjectUnRead", [HttpService getInstance].userId]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"消息通知";
    
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"]
        || [[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"]
        || [[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"4"])
    {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"jiahao_"] style:UIBarButtonItemStylePlain target:self action:@selector(onPublish)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    _newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    self.newsTable.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_newsTable];
    
    _newsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    _newsTable.delegate = self;
    _newsTable.dataSource = self;
    
    [utilityFunction setExtraCellLineHidden:_newsTable];
    
    _needLoad = NO;
    _currentPage = 0, _totalPage = 0;
    [_newsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newsTableCell"];
    [self setupRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needRefresh:)
                                                 name:@"refreshNews"
                                               object:nil];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_newsTable addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"lastNoticeTable"];
    [_newsTable headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_newsTable addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _newsTable.headerPullToRefreshText = @"下拉可以刷新了";
    _newsTable.headerReleaseToRefreshText = @"松开马上刷新了";
    _newsTable.headerRefreshingText = @"正在查找新的消息";
    
    _newsTable.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _newsTable.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _newsTable.footerRefreshingText = @"正在查找历史消息";
}


- (void)headerRereshing
{
    if (_isLoading == NO && _totalPage == 0)
    {
        _isLoading = YES;
        [messageTipView removeTipView:self.view];
        
        [[HttpService getInstance] queryNotice:1 noticeType:@"XXTZ" andBlock:^(NSMutableArray *noticeArray, NSDictionary *dict) {
            
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
  
                [_newsTable reloadData];
            }
            else
            {
                NSString *tipMessage = nil;
                
                if (!noticeArray) {
                    NSString *statusCode = [dict objectForKey:@"errorCode"];
                    
                    if ([statusCode isEqualToString:@"500"]) {
                        tipMessage = @"请求数据出错~";
                    }
                    else
                    {
                        tipMessage = @"请求数据超时~";
                    }
                }
                else
                {
                    tipMessage = @"没有可用的内容~";
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [messageTipView showTipView:self.view style:0 tip:tipMessage];
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
        [[HttpService getInstance] queryNotice:_currentPage+1 noticeType:@"XXTZ" andBlock:^(NSMutableArray *noticeArray, NSDictionary *dict) {
            
            _isLoading = NO;
            _imgServerUrl = [dict objectForKey:@"imgServerUrl"];
            [_newsTable headerEndRefreshing];
            [_newsTable footerEndRefreshing];
            
            if (noticeArray != nil && [noticeArray count] > 0)
            {
                [_newsArray addObjectsFromArray:noticeArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                
                [_newsTable reloadData];
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsItem *item = [self.newsArray objectAtIndex:[indexPath row]];
    NSString * identifier = [NSString stringWithFormat:@"cell-%@", item.newsId];
    XAbstractTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
    if (cell == nil) {
        cell = [[XAbstractTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:identifier
                NewsItem:item];
    }
    
    return cell;
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    newsDetailViewController *newsDetailCtrl = [newsDetailViewController new];
    newsDetailCtrl.item = [self.newsArray objectAtIndex:[indexPath row]];
        
    [self.navigationController pushViewController:newsDetailCtrl animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"])
    {
         return UITableViewCellEditingStyleDelete;
    }
    else if([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"])
    {
        NewsItem *item = [self.newsArray objectAtIndex:[indexPath row]];
        
        if ([item.authorId isEqualToString:[HttpService getInstance].userId])
        {
             return UITableViewCellEditingStyleDelete;
        }
        else
        {
            return UITableViewCellEditingStyleNone;
        }
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NewsItem *item = [self.newsArray objectAtIndex:[indexPath row]];
        
        [[HttpService getInstance] deleteNotice:item.newsId andBlock:^(int retValue) {
            
            if (retValue == 200)
            {
                if ([_newsArray count] > [indexPath row])
                {
                    [_newsArray removeObjectAtIndex:[indexPath row]];
                }
 
                [_newsTable reloadData];
            }
            else
            {
                NSString *messageTip = @"删除失败";
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message: messageTip delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertV show];
            }
        }];
    }
}

- (void)onPublish
{
    if (_imgServerUrl == nil) {
        return;
    }
    
    publishMessageViewController *ctrl = [publishMessageViewController new];
    ctrl.imgServerUrl = _imgServerUrl;
    ctrl.messageType = @"XXTZ";
    
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(void)needRefresh:(NSNotification*)notification {
    _needLoad = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"lastestNoticeViewController dealloc");
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
