//
//  shuttleViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "shuttleViewController.h"
#import "NTStatusTableViewCell.h"
#import "HttpService.h"
#import "bindCardViewController.h"
#import "utilityFunction.h"
#import "messageTipView.h"
#import "MJRefresh.h"
#import "MobClick.h"
#import "ProtoType.h"
#import "messageScrollViewController.h"

@interface shuttleViewController()<shuttleViewCellDelegate>
@property(nonatomic) UITableView *pickUpList;
@property(nonatomic) UIView *optionView;
@property(nonatomic) NSMutableArray *shuttleArray;
@property(nonatomic) int totalPage, currentPage;
@property(nonatomic) bool isLoading;


-(void)onBtnOption;
-(void)setupRefresh;
-(void)headerRereshing;
-(void)footerRereshing;
@end

@implementation shuttleViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shuttleSectionNew"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.pickUpList reloadData];
}

- (NSMutableArray*)shuttleArray{
    
    if (_shuttleArray == nil) {
        _shuttleArray = [NSMutableArray new];
    }
    
    return _shuttleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"入离园信息";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ka"] style:UIBarButtonItemStylePlain target:self action:@selector(onBindCard)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    _pickUpList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    
    _pickUpList.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_pickUpList];
    
    _pickUpList.separatorStyle = UITableViewCellSelectionStyleNone;
    [_pickUpList setDelegate:self];
    [_pickUpList setDataSource:self];
    
    [utilityFunction setExtraCellLineHidden:_pickUpList];
    
    _currentPage = 0, _totalPage = 0;
    [_pickUpList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"shuttleTableCell"];
    
    [self setupRefresh];
    
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_pickUpList addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"shuttleTable"];
    [_pickUpList headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_pickUpList addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _pickUpList.headerPullToRefreshText = @"下拉可以刷新了";
    _pickUpList.headerReleaseToRefreshText = @"松开马上刷新了";
    _pickUpList.headerRefreshingText = @"正在查找新的入离园记录";
    
    _pickUpList.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _pickUpList.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _pickUpList.footerRefreshingText = @"正在查找历史入离园记录";
}

- (void)headerRereshing
{
    if (_isLoading == NO && _totalPage == 0)
    {
        _isLoading = YES;
        [messageTipView removeTipView:self.view];
        
        [[HttpService getInstance] queryShuttle:_entranceCardId fromPage:0 andBlock:^(NSMutableArray *messageArray, NSDictionary *dict) {
            _isLoading = NO;
            
            [_pickUpList headerEndRefreshing];
            [_pickUpList footerEndRefreshing];
            
            if (messageArray != nil && [messageArray count] > 0)
            {
                [_shuttleArray removeAllObjects];
                [_shuttleArray addObjectsFromArray:messageArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                
                [_pickUpList reloadData];
            }
            else
            {
                NSString *tipMessage = nil;
                
                if (!messageArray) {
                    tipMessage = @"请求数据超时~";
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
        [_pickUpList headerEndRefreshing];
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
        [_pickUpList footerEndRefreshing];
    }
    else
    {
        _isLoading = YES;
        
        [[HttpService getInstance] queryShuttle:_entranceCardId fromPage:_currentPage+1 andBlock:^(NSMutableArray *messageArray, NSDictionary *dict) {
            
            _isLoading = NO;
            
            [_pickUpList headerEndRefreshing];
            [_pickUpList footerEndRefreshing];
            
            if (messageArray != nil && [messageArray count] > 0)
            {
                [_shuttleArray addObjectsFromArray:messageArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                
                [_pickUpList reloadData];
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.shuttleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShuttleItem *item = [self.shuttleArray objectAtIndex:[indexPath row]];
    NSString * identifier = [NSString stringWithFormat:@"cell-%@", item.shuttleId];
    
    NTStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        ShuttleItem *item = [_shuttleArray objectAtIndex:[indexPath row]];
        cell = [[NTStatusTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:identifier
                shuttleItem:item];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    return cell;
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShuttleItem *item = [_shuttleArray objectAtIndex:[indexPath row]];
    return [NTStatusTableViewCell calculateCellHeight:item];
}

-(void)onBindCard
{
    if ([HttpService getInstance].userExtentInfo.babyArray.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"您还没有孩子,不能绑定入离园卡"
                                                      delegate:self
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    bindCardViewController *bindCtrl = [bindCardViewController new];
    bindCtrl.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:bindCtrl animated:YES];
}

- (void)onBtnOption
{
    _optionView.hidden = !_optionView.hidden;
}

-(void)onTapImage:(NSString*)shttleId index:(int)index
{
    int idx = [self findShuttleIndex:shttleId];
    
    if (idx != -1)
    {
        NewsItem *item = [_shuttleArray objectAtIndex:idx];
        
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

-(int)findShuttleIndex:(NSString*)shuttleId
{
    int index = -1;
    
    for (int i = 0; i < _shuttleArray.count; i++)
    {
        ShuttleItem *item = [_shuttleArray objectAtIndex:i];
        
        if ([item.shuttleId isEqualToString:shuttleId]) {
            index = i;
            break;
        }
    }
    
    return index;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"shuttleViewController dealloc");
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
