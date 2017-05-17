//
//  locationViewController.m
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "locationViewController.h"
#import "HttpService.h"
#import "BMapKit.h"
#import "MBProgressHUD.h"
#import "ProtoType.h"
#import "mobClick.h"

@interface locationViewController()<BMKLocationServiceDelegate,BMKMapViewDelegate,CLLocationManagerDelegate>

@property(nonatomic) BMKMapView* mapView;
@property(nonatomic) BMKLocationService *locationService;
@property(nonatomic) BMKPointAnnotation *annotation;
@property(nonatomic) NSTimer *queryTimer;
@property(nonatomic) CLLocationCoordinate2D coor;
@property(nonatomic) BOOL isQuerying, firstRun;

@property(nonatomic) CLLocationManager* locationMgr;
@property(nonatomic) CLGeocoder* clGeocoder;// iso 5.0及5.0以上SDK版本使


-(void)excuteQuery;
@end

@implementation locationViewController

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

}

- (void)viewDidDisappear:(BOOL)animated
{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"宝宝定位";
    
    self.navigationItem.titleView = titleLable;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height-65)];
    [self.view addSubview:_mapView];
    
    _mapView.delegate = self;
    
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    //初始化BMKLocationService
    _locationService = [[BMKLocationService alloc] init];
    _locationService.delegate = self;

    //启动LocationService
    [_locationService startUserLocationService];
    
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    
    //设置地图类型
    [_mapView setMapType:BMKMapTypeStandard];

    _annotation = [[BMKPointAnnotation alloc] init];
    _annotation.title = [HttpService getInstance].userBaseInfo.nickName;
   
    _firstRun = YES;
    
#if 0
        _queryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(excuteQuery) userInfo:nil repeats:YES];
        
        [self excuteQuery];
#endif
    
#if 1 
    
    self.locationMgr = [[CLLocationManager alloc] init];
    
    //设置代理
    self.locationMgr.delegate = self;
    
    // 设置定位精度
    // kCLLocationAccuracyNearestTenMeters:精度10米
    // kCLLocationAccuracyHundredMeters:精度100 米
    // kCLLocationAccuracyKilometer:精度1000 米
    // kCLLocationAccuracyThreeKilometers:精度3000米
    // kCLLocationAccuracyBest:设备使用电池供电时候最高的精度
    // kCLLocationAccuracyBestForNavigation:导航情况下最高精度，一般要有外接电源时才能使用
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    
    // distanceFilter是距离过滤器，为了减少对定位装置的轮询次数，位置的改变不会每次都去通知委托，而是在移动了足够的距离时才通知委托程序
    // 它的单位是米，这里设置为至少移动1000再通知委托处理更新;
    self.locationMgr.distanceFilter = 1000.0f;
    
    //开始定位
    [self.locationMgr startUpdatingLocation];

#endif
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation;
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]])
    {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = NO;
        return newAnnotationView;
    }
    
    return nil;
}


- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

- (void)onBack
{
#if 0
    [_queryTimer invalidate];
#endif
    
    _locationService.delegate = nil;
    _mapView.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)excuteQuery
{
    if (!_isQuerying)
    {
        _isQuerying = YES;
    }
}


// iso 6.0以上SDK版本使用，包括6.0。
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *cl = [locations objectAtIndex:0];
    NSLog(@"纬度--%f",cl.coordinate.latitude);
    NSLog(@"经度--%f",cl.coordinate.longitude);
}


//获取定位失败回调方法
#pragma mark - location Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location error!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{   
    NSLog(@"locationViewController dealloc");
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
