//
//  storyListViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "HttpService.h"
#import "ProtoType.h"
#import "storyListViewController.h"
#import "storyPlayViewController.h"
#import "utilityFunction.h"
#import "messageTipView.h"
#import "MJRefresh.h"
#import "mobClick.h"

@interface storyListViewController()<UIScrollViewDelegate>
@property(nonatomic) UITableView *storyList;
@property(nonatomic) bool isLoading;
@property(nonatomic) NSMutableArray *storyArray;
@property(nonatomic) int currentPage, totalPage;

-(void)setupRefresh;
-(void)headerRereshing;
-(void)footerRereshing;
@end

@implementation storyListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"睡前故事列表"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"睡前故事列表"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.storyList reloadData];
}

- (NSMutableArray*)storyArray
{
    if (_storyArray == nil) {
        _storyArray = [NSMutableArray new];
    }
    
    return _storyArray;
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
    self.navigationItem.titleView = titleLable;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _storyList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    
    _storyList.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_storyList];
    
    _storyList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_storyList setDelegate:self];
    [_storyList setDataSource:self];
    
    [utilityFunction setExtraCellLineHidden:_storyList];
    
    switch (_storyCatagory) {
        case 0:
        {
            titleLable.text = @"格林童话";
        }
            break;
            
        case 1:
        {
            titleLable.text = @"安徒生童话";
        }
            break;
            
        case 2:
        {
            titleLable.text = @"寓言故事";
        }
            break;
            
        case 3:
        {
            titleLable.text = @"神话故事";
        }
            break;
            
        default:
            break;
    }
    
    _currentPage = 0, _totalPage = 0;
    [_storyList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"storyTableCell"];
    [self setupRefresh];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_storyList addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"storyTable"];
    [_storyList headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_storyList addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _storyList.headerPullToRefreshText = @"下拉可以刷新了";
    _storyList.headerReleaseToRefreshText = @"松开马上刷新了";
    _storyList.headerRefreshingText = @"正在查找新的故事";
    
    _storyList.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _storyList.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _storyList.footerRefreshingText = @"正在查找更多的故事";
}

- (void)headerRereshing
{
    if (_isLoading == NO && _totalPage == 0)
    {
        _isLoading = YES;
        [messageTipView removeTipView:self.view];
        
        [[HttpService getInstance] queryStoryList:_storyCatagory page:1 andBlock:^(NSMutableArray *storyArray, NSDictionary *dict) {
            
            _isLoading = NO;
            
            [_storyList headerEndRefreshing];
            [_storyList footerEndRefreshing];
            
            if (storyArray != nil && [storyArray count] > 0)
            {
                [self.storyArray removeAllObjects];
                [self.storyArray addObjectsFromArray:storyArray];
                _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                [_storyList reloadData];
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
        [_storyList headerEndRefreshing];
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
        [_storyList footerEndRefreshing];
    }
    else
    {
        _isLoading = YES;
         [[HttpService getInstance] queryStoryList:_storyCatagory page:_currentPage+1 andBlock:^(NSMutableArray *storyArray, NSDictionary *dict) {
             
             _isLoading = NO;
             
             [_storyList headerEndRefreshing];
             [_storyList footerEndRefreshing];
             
             if (storyArray != nil && [storyArray count] > 0)
             {
                 [self.storyArray addObjectsFromArray:storyArray];
                 _currentPage = [[dict objectForKey:@"currentPage"] intValue];
                 _totalPage = [[dict objectForKey:@"totalPage"] intValue];
                 [_storyList reloadData];
             }
         }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.storyArray count];
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
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 13, 24, 24)];
    [cell.contentView addSubview:imageV];
    imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icn_morengushi@2x" ofType:@"png"]];
    
    UILabel *descLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 16, 200, 20)];
    [cell.contentView addSubview:descLable];
    descLable.font = [UIFont systemFontOfSize:16];
    MediaItem *item = [self.storyArray objectAtIndex:[indexPath row]];
    descLable.text = item.name;
    
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

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    storyPlayViewController *storyCtrl = [storyPlayViewController new];
    storyCtrl.playIndex = [indexPath row];
    storyCtrl.storyArray = self.storyArray;
    
    [self.navigationController pushViewController:storyCtrl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_storyList setDelegate:nil];
    [_storyList setDataSource:nil];

    NSLog(@"storyListViewController dealloc");
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
