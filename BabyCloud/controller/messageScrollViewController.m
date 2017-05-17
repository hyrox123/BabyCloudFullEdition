//
//  messageScrollViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "messageScrollViewController.h"
#import "UIImageView+WebCache.h"
#import "SDPieLoopProgressView.h"

@interface messageScrollViewController ()<UIScrollViewDelegate>
@property(nonatomic) UIScrollView  *scrollView;
@property(nonatomic) UIPageControl *pageCtrl;
@property(nonatomic) NSMutableArray *viewArray;
@end

@implementation messageScrollViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height)];
    self.scrollView.contentSize = CGSizeMake([self.imageArray count]*clientRect.size.width, clientRect.size.height);
    
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.viewArray = [NSMutableArray new];
    
    for (int i = 0; i < [self.imageArray count]; i++)
    {
        UIScrollView *subScroll  = [[UIScrollView alloc] initWithFrame:CGRectMake(i*clientRect.size.width, 0, clientRect.size.width, clientRect.size.height)];
        
        subScroll.contentSize = CGSizeMake(clientRect.size.width, clientRect.size.height);
        subScroll.minimumZoomScale = 1.0f;
        subScroll.maximumZoomScale = 3.0f;
        subScroll.decelerationRate = 1.0f;
        subScroll.zoomScale = 1.0f;
        subScroll.userInteractionEnabled = YES;
        subScroll.delegate = self;
        subScroll.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        subScroll.tag = 0x200+i;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, clientRect.size.width, clientRect.size.height)];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 0x100;
        
        if (_imageIsUrl == NO)
        {
            imageView.image = [self.imageArray objectAtIndex:i];
        }
        else
        {
            __block SDPieLoopProgressView *activityIndicator = nil;
            __weak UIImageView *weakImageView = imageView;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[self.imageArray objectAtIndex:i]]
                         placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"morentupian1@2x" ofType:@"png"]]
                                  options:SDWebImageProgressiveDownload
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     if (!activityIndicator) {
                                         activityIndicator = [SDPieLoopProgressView progressView];
                                         activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-80)/2, (weakImageView.frame.size.height-80)/2, 80, 80);
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
        
        [self.viewArray addObject:imageView];
        [subScroll addSubview:imageView];
        [self.scrollView addSubview:subScroll];
    }
    
    CGRect targetRect = CGRectMake(_currentIndex*clientRect.size.width, 0, clientRect.size.width, clientRect.size.height);
    [self.scrollView scrollRectToVisible:targetRect animated:NO];
    
    self.pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, clientRect.size.height - 50, clientRect.size.width, 20)];
    self.pageCtrl.numberOfPages = [self.imageArray count];
    self.pageCtrl.currentPage = _currentIndex;
    [self.view addSubview:self.pageCtrl];
    
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setFrame:CGRectMake(10, 15, 60, 25)];
    
    saveBtn.showsTouchWhenHighlighted = YES;
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    saveBtn.titleLabel.textColor = [UIColor whiteColor];
    saveBtn.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [saveBtn setTitle: @"保存" forState: UIControlStateNormal];
    
    [saveBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setFrame:CGRectMake(clientRect.size.width-70, 15, 60, 25)];
    
    deleteBtn.showsTouchWhenHighlighted = YES;
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    deleteBtn.titleLabel.textColor = [UIColor whiteColor];
    deleteBtn.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [deleteBtn setTitle: @"删除" forState: UIControlStateNormal];
    
    [deleteBtn addTarget:self action:@selector(onDelete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired  = 1;
    [_scrollView addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired  = 1;
    [_scrollView addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    if (_imageIsUrl == YES)
    {
        deleteBtn.hidden = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    _currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageCtrl.currentPage = _currentIndex;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    for (UIView *subview in scrollView.subviews) {
        return subview;
    }
    
    return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
}

- (void)onSingleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDoubleTap
{
    UIScrollView *subScroll = (UIScrollView*)[_scrollView viewWithTag:_currentIndex+0x200];
    
    if (!subScroll)
    {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    
    if (subScroll.zoomScale == 1.0f)
    {
        subScroll.zoomScale = 2.0f;
    }
    else
    {
        subScroll.zoomScale = 1.0f;
    }
    
    [UIView commitAnimations];
}

- (void)onDelete
{
    for (int i = 0; i < [self.viewArray count]; i++)
    {
        UIImageView *imageV = [self.viewArray objectAtIndex:i];
        [imageV removeFromSuperview];
    }
    
    [self.viewArray removeAllObjects];
    [self.imageArray removeObjectAtIndex:_currentIndex];
    
    if ([self.imageArray count] == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    for (int i = 0; i < [self.imageArray count]; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [self.imageArray objectAtIndex:i];
        
        [self.viewArray addObject:imageView];
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake([self.imageArray count]*self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    _currentIndex = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    CGRect targetRect = CGRectMake(_currentIndex*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView scrollRectToVisible:targetRect animated:NO];
    
    self.pageCtrl.numberOfPages = [self.imageArray count];
    self.pageCtrl.currentPage = _currentIndex;
}

- (void)onSave
{
    UIScrollView *subScroll = (UIScrollView*)[_scrollView viewWithTag:_currentIndex+0x200];
    UIImageView *imageV = (UIImageView*)[subScroll viewWithTag:0x100];
    UIImageWriteToSavedPhotosAlbum(imageV.image, nil, nil, nil);
    
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"照片已经保存到本地相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertV show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"messageScrollViewController dealloc");
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
