//
//  vodListViewController.m
//  YSTParentClient
//
//  Created by apple on 14-12-9.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "vodListViewController.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "utilityFunction.h"
#import "messageTipView.h"
#import "vodTableViewCell.h"
#import "vodPlayViewController.h"
#import "MJRefresh.h"
#import "mobClick.h"

@interface vodListViewController()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) UITableView *vodList;
@property(nonatomic) BOOL isLoading;
@property(nonatomic) NSMutableArray *vodArray;
@property(nonatomic) int currentPage, totalPage;

-(void)setupRefresh;
-(void)headerRereshing;
-(void)footerRereshing;
@end

@implementation vodListViewController

- (NSMutableArray*)vodArray
{
    if (_vodArray == nil) {
        _vodArray = [NSMutableArray new];
    }
    
    return _vodArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.vodList reloadData];
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
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLable;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _vodList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    
    _vodList.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_vodList];
    
    _vodList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_vodList setDelegate:self];
    [_vodList setDataSource:self];
    
    [utilityFunction setExtraCellLineHidden:_vodList];
    
    switch (_vodCatagory) {
        case 0:
        {
            titleLable.text = @"家长学堂";
        }
            break;
            
        case 1:
        {
            titleLable.text = @"宝贝动画";
        }
            break;
            
        case 2:
        {
            titleLable.text = @"搞笑拍拍";
        }
            break;
            
        case 3:
        {
            titleLable.text = @"启蒙教育";
        }
            break;
            
        default:
            break;
    }
    
    _currentPage = 0, _totalPage = 0;
    
    [_vodList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"vodTableCell"];
    [self setupRefresh];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_vodList addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"vodTable"];
    [_vodList headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_vodList addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _vodList.headerPullToRefreshText = @"下拉可以刷新了";
    _vodList.headerReleaseToRefreshText = @"松开马上刷新了";
    _vodList.headerRefreshingText = @"正在查找新的故事";
    
    _vodList.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _vodList.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _vodList.footerRefreshingText = @"正在查找更多的故事";
}

- (void)headerRereshing
{
    if (_isLoading == NO && _totalPage == 0)
    {
        _isLoading = YES;
        [messageTipView removeTipView:self.view];
        
        [[HttpService getInstance] queryVodList:_vodCatagory page:1 andBlock:^(NSMutableArray *vodArray, NSDictionary *dict) {
            
            _isLoading = NO;
            [_vodList headerEndRefreshing];
            [_vodList footerEndRefreshing];
            
            if (vodArray != nil && [vodArray count] > 0)
            {
                [self.vodArray removeAllObjects];
                [self.vodArray addObjectsFromArray:vodArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                [_vodList reloadData];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [messageTipView showTipView:self.view style:0 tip:@"没有可用的内容~"];
                });
            }
        }];
    }
    else
    {
        [_vodList headerEndRefreshing];
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
        [_vodList footerEndRefreshing];
    }
    else
    {
        _isLoading = YES;
        [[HttpService getInstance] queryVodList:_vodCatagory page:_currentPage+1 andBlock:^(NSMutableArray *vodArray, NSDictionary *dict) {
            
            _isLoading = NO;
            [_vodList headerEndRefreshing];
            [_vodList footerEndRefreshing];
            
            if (vodArray != nil && [vodArray count] > 0)
            {
                [self.vodArray addObjectsFromArray:vodArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                [_vodList reloadData];
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.vodArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaItem *item = [self.vodArray objectAtIndex:[indexPath row]];
    VodTableViewCell *cell = [[VodTableViewCell alloc]
                              initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:@"vodTableCell1"
                              mediaItem:item];
    
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.width/3+20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    MediaItem *item = [self.vodArray objectAtIndex:[indexPath row]];
    vodPlayViewController *vodPlayCtrl = [[vodPlayViewController alloc] init];
    vodPlayCtrl.videoId = item.mediaId;
    
    [self.navigationController pushViewController:vodPlayCtrl animated:YES];
}

- (void)dealloc
{
    NSLog(@"vodListViewController dealloc");
}

@end
