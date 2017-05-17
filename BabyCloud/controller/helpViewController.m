//
//  helpViewController.m
//  WeChatDemo
//
//  Created by apple on 14-9-22.
//  Copyright (c) 2014年 ioschen. All rights reserved.
//

#import "helpViewController.h"
#import "loginViewController.h"

@interface helpViewController()
@property(nonatomic) UIScrollView  *scrollView;
@property(nonatomic) UIPageControl *pageCtrl;
@property(nonatomic) UIButton *dismissBtn;

-(void)dismissGuideView;
@end

@implementation helpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:clientRect];
    self.scrollView.contentSize = CGSizeMake(3*clientRect.size.width, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.scrollView];
    
    self.pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, clientRect.size.height - 50, clientRect.size.width, 20)];
    self.pageCtrl.numberOfPages = 3;
    self.pageCtrl.currentPage = 0;
    [self.view addSubview:self.pageCtrl];
    
    for (int i = 0; i < 3; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * clientRect.size.width, 0, clientRect.size.width, clientRect.size.height)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        NSString *fileName = [NSString stringWithFormat:@"guide%d@2x", i];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
        [self.scrollView addSubview:imageView];
    }
    
    self.dismissBtn = [[UIButton alloc] init];
    [self.dismissBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_click@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.dismissBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_click_on@2x" ofType:@"png"]] forState:UIControlStateHighlighted];
    [self.view addSubview:self.dismissBtn];
    
    self.dismissBtn.frame = CGRectMake(clientRect.size.width/5, clientRect.size.height/3, 90, 30);
    [self.dismissBtn addTarget:self action:@selector(dismissGuideView) forControlEvents:UIControlEventTouchDown];
    self.dismissBtn.hidden = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page == 2) {
        self.dismissBtn.hidden = NO;
    }
    else
    {
        self.dismissBtn.hidden = YES;
    }
    
    self.pageCtrl.currentPage = page;
}

-(void) dismissGuideView
{
    [self.navigationController pushViewController:[loginViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"helpViewController dealloc");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
