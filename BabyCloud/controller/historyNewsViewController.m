//
//  historyNewsViewController.m
//  YSTParentClient
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "historyNewsViewController.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "MJRefresh.h"
#import "MobClick.h"
#import "HistoryRecordTableViewCell.h"
#import "newsDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "SDTransparentPieProgressView.h"

@interface historyNewsViewController ()<UITableViewDataSource, UITableViewDelegate, HistoryRecordTableViewCellDelegate>
@property(nonatomic) UITableView *newsTable;
@property(nonatomic) UILabel *describLabel;
@property(nonatomic) NSMutableArray *newsArray;
@property(nonatomic) NSString *imgServerUrl;
@property(nonatomic) int totalPage, currentPage, score;
@property(nonatomic) bool isLoading;

-(void)setupRefresh;
-(void)headerRereshing;
-(void)footerRereshing;
@end

@implementation historyNewsViewController


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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"足迹";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    self.newsTable.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_newsTable];
    
    _describLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, clientRect.size.width, 20)];
    [self.view addSubview:_describLabel];
    
    _describLabel.font = [UIFont boldSystemFontOfSize:16];
    _describLabel.textColor = [UIColor lightGrayColor];
    _describLabel.textAlignment = NSTextAlignmentCenter;
    
    _newsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    _newsTable.delegate = self;
    _newsTable.dataSource = self;
    
    [utilityFunction setExtraCellLineHidden:_newsTable];
    
    _currentPage = 0, _totalPage = 0, _score = 0;
    [_newsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newsTableCell"];
    [self setupRefresh];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_newsTable addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"historyNoticeTable"];
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
        _describLabel.text = @"";
      
        [[HttpService getInstance] queryHistoryNotice:_authorId publicState:_squareSearch page:1 andBlock:^(NSMutableArray *noticeArray, NSDictionary *dict) {
            
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
                _score = [[dict objectForKey:@"score"] intValue];
                [_newsTable reloadData];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _describLabel.text = @"用户还没有发表过内容:(~";
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
        [[HttpService getInstance] queryHistoryNotice:_authorId publicState:_squareSearch page:_currentPage+1 andBlock:^(NSMutableArray *noticeArray, NSDictionary *dict) {
            
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
        
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 200)];
        [cell.contentView addSubview:headerView];
        
        headerView.layer.contents = (__bridge id)([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"userDefaultPannel@2x" ofType:@"png"]].CGImage);
        
        UIImageView *portriatImgV = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(tableView.frame)-60)/2, 50, 60, 60)];
        
        [headerView addSubview:portriatImgV];
        
        portriatImgV.layer.cornerRadius = 30;
        portriatImgV.layer.masksToBounds = YES;
        
        if (_portrait) {
            
            NSString *portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, _portrait];
            
            __block SDTransparentPieProgressView *activityIndicator = nil;
            __weak UIImageView *weakImageView = portriatImgV;
            [portriatImgV sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
                            placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contactTXL@2x" ofType:@"png"]]
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
            portriatImgV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contactTXL@2x" ofType:@"png"]];
        }
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, CGRectGetWidth(tableView.frame), 20)];
        [headerView addSubview:nameLabel];
        
        nameLabel.text = _authorName;
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *starV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)/2-60, 150, 20, 20)];
        [headerView addSubview:starV];
        
        starV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star@2x" ofType:@"png"]];
        
        UILabel *sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)/2-38, 152, 30, 20)];
        [headerView addSubview:sumLabel];
        
        sumLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.newsArray.count];
        sumLabel.font = [UIFont systemFontOfSize:16];
        sumLabel.textColor = [UIColor whiteColor];
        
        UIImageView *scoreV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)/2+40, 152, 20, 20)];
        [headerView addSubview:scoreV];
        
        scoreV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"flowerRed@2x" ofType:@"png"]];
        
        UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)/2+68, 152, 30, 20)];
        [headerView addSubview:scoreLabel];
        
        scoreLabel.font = [UIFont systemFontOfSize:16];
        scoreLabel.textColor = [UIColor whiteColor];
        scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
        
        return cell;
    }
    else
    {
        NSMutableArray *recordArray = [self.newsArray objectAtIndex:indexPath.row-1];
        
        NewsItem *item = recordArray[0];
        NSString * identifier = [NSString stringWithFormat:@"cell-%@", item.newsId];
        HistoryRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            
            cell = [[HistoryRecordTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:identifier
                    records:recordArray];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.row = (int)(indexPath.row-1);
        }
        
        return cell;
    }
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 200;
    }
    
    NSMutableArray *recordArray = [self.newsArray objectAtIndex:indexPath.row-1];
    return [HistoryRecordTableViewCell calculateCellHeight:recordArray];
}

- (void)onTapSection:(int)row index:(int)index
{
    newsDetailViewController *newsDetailCtrl = [newsDetailViewController new];
    NSMutableArray *recordArray = self.newsArray[row];
    newsDetailCtrl.item = recordArray[index];
    
    [self.navigationController pushViewController:newsDetailCtrl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"historyNewsViewController dealloc");
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
