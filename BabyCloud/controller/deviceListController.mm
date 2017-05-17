//
//  deviceListController.m
//  YSTParentClient
//
//  Created by apple on 14-10-14.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "deviceListController.h"
#import "videoViewController.h"
#import "MBProgressHUD.h"
#import "utilityFunction.h"
#import "messageTipView.h"
#import "ProtoType.h"
#import "MJRefresh.h"

@interface deviceListController ()
@property(nonatomic) UITableView *devicelst;
@property(nonatomic) NSMutableArray *deviceArray;
@property(nonatomic) BOOL isLoading;

-(void)setupRefresh;
-(void)headerRereshing;
@end

@implementation deviceListController

- (NSMutableArray*)deviceArray
{
    if (_deviceArray == nil) {
        _deviceArray = [NSMutableArray new];
    }
    
    return _deviceArray;
}

- (void)viewDidAppear:(BOOL)animated
{
    
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"视频浏览";
    self.navigationItem.titleView = titleLable;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _devicelst = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65) style:UITableViewStylePlain];
    
    _devicelst.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_devicelst];
    
    [_devicelst setDelegate:self];
    [_devicelst setDataSource:self];
    [utilityFunction setExtraCellLineHidden:_devicelst];
    
#if 0
    [_devicelst registerClass:[UITableViewCell class] forCellReuseIdentifier:@"deviceTableCell"];
    [self setupRefresh];
#else
    XDeviceNode *node = [XDeviceNode new];
    node.streamURL = @"http://219.232.160.141:5080/hls/c64024e7cd451ac19613345704f985fa.m3u8";
    node.deviceName = @"深圳卫视";
    
    [self.deviceArray addObject:node];
#endif
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_devicelst addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"deviceTable"];
    [_devicelst headerBeginRefreshing];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _devicelst.headerPullToRefreshText = @"下拉可以刷新了";
    _devicelst.headerReleaseToRefreshText = @"松开马上刷新了";
    _devicelst.headerRefreshingText = @"正在查找新的设备列表";
}

- (void)headerRereshing
{
    if (_isLoading == NO)
    {
        _isLoading = YES;
         [messageTipView removeTipView:self.view];
        
        [[HttpService getInstance] queryDeviceList:^(NSMutableArray *deviceArray) {
            
            _isLoading = NO;
            [_devicelst headerEndRefreshing];
            
            if (deviceArray != nil && [deviceArray count] > 0)
            {
                [self.deviceArray removeAllObjects];
                [self.deviceArray addObjectsFromArray:deviceArray];
                [self.devicelst reloadData];
            }
            else
            {
                [messageTipView showTipView:self.view style:0 tip:@"没有可用设备~"];
            }
        }];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceTableCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"deviceTableCell"];
    }
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 30, 33)];
    UILabel *deviceNameLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 250, 20)];
    UILabel *availbelTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 250, 15)];
    
    [cell.contentView addSubview:imageV];
    [cell.contentView addSubview:deviceNameLable];
    [cell.contentView addSubview:availbelTimeLable];
    
    deviceNameLable.font = [UIFont boldSystemFontOfSize:16];
    availbelTimeLable.font = [UIFont systemFontOfSize:12];
    availbelTimeLable.textColor = [UIColor lightGrayColor];
    
    XDeviceNode *node = [self.deviceArray objectAtIndex:[indexPath row]];
    
    if (node.validWatchTime.length > 0) {
        availbelTimeLable.text = [NSString stringWithFormat:@"开放时间:(%@)", node.validWatchTime];
    }
    else
    {
        availbelTimeLable.text = @"开放时间:(全天)";
    }

    deviceNameLable.text = node.deviceName;
    imageV.image = [UIImage imageNamed:@"shexiangtou_2_.png"];
    deviceNameLable.textColor = [UIColor blackColor];
    
    NSRange possibleRange;
    possibleRange.location = 5;
    possibleRange.length = availbelTimeLable.text.length - 5;
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:availbelTimeLable.text];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.3686f green:0.4275f blue:0.8275f alpha:1.0f] range:possibleRange];
    
    availbelTimeLable.attributedText = attString;

    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XDeviceNode *node = [self.deviceArray objectAtIndex:indexPath.row];
        
    NSArray *validWatchTimeArray = [node.validWatchTime componentsSeparatedByString:@","];
    
    if (validWatchTimeArray == nil) {
        if (node.validWatchTime != nil) {
            validWatchTimeArray = [NSArray arrayWithObject:node.validWatchTime];
        }
    }
    
    bool valideWatchTime = false;
    
    if (validWatchTimeArray == nil) {
        valideWatchTime = true;
    }
    
    for (int i = 0; i < [validWatchTimeArray count]; i++) {
        NSString *periodTime = [validWatchTimeArray objectAtIndex:i];
        
        if (![utilityFunction timeExpire:periodTime] || [periodTime isEqualToString:@"0"]
            || [periodTime isEqualToString:@""] ) {
            valideWatchTime = true;
            break;
        }
    }
    
    if (valideWatchTime)
    {
        videoViewController *videoCtrl = [videoViewController new];
        videoCtrl.selectedNode = node;
        
        [self.navigationController pushViewController:videoCtrl animated:YES];
    }
    else
    {
        NSString *valideTimeDesc = @"";
        
        for (int i = 0; i < [validWatchTimeArray count]; i++) {
            NSString *periodTime = [validWatchTimeArray objectAtIndex:i];
            
            valideTimeDesc = [valideTimeDesc stringByAppendingString:periodTime];
            valideTimeDesc = [valideTimeDesc stringByAppendingString:@" "];
        }
        
        
        NSString *tip = [NSString stringWithFormat:@"此时间段你没有权限观看视频,只有以下时间段才可以观看视频\n%@", valideTimeDesc];
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:tip delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_devicelst setDelegate:nil];
    [_devicelst setDataSource:nil];
    
    NSLog(@"deviceListController dealloc");
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
