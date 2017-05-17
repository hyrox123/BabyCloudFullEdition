//
//  videoView.m
//  YSTParentClient
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "videoView.h"
#import "utilityFunction.h"

@interface videoView()<UIScrollViewDelegate>
@property(nonatomic) UIScrollView *scrollView;
@property(nonatomic) UIButton *voiceBtn;
@property(nonatomic) BOOL direction;

-(void)onSingleTapVideo;
-(void)onDoubleTapVideo;
@end

@implementation videoView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0.9294f green:0.9216f blue:0.8157f alpha:1.0f];
        
        UIView *pannel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-65)];
        pannel.backgroundColor = [UIColor blackColor];
        
        int picWidth = frame.size.width;
        int picHeight = picWidth*288/352;
        int pos = (frame.size.height-picHeight)/2-65;
        
        _scrollView =  [[UIScrollView alloc] initWithFrame:CGRectMake(0, pos, picWidth, picHeight)];
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.maximumZoomScale = 3.0f;
        _scrollView.contentSize = CGSizeMake(picWidth, picHeight);
        _scrollView.decelerationRate = 1.0f;
        _scrollView.zoomScale = 1.0f;
        _scrollView.delegate = self;
        
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        _videoPannel = [[OpenGLView20 alloc] initWithFrame:CGRectMake(0, 0, picWidth, picHeight)];
        _videoPannel.backgroundColor = [UIColor blackColor];
        _videoPannel.userInteractionEnabled = YES;
        _videoPannel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [_scrollView addSubview:_videoPannel];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTapVideo)];
        singleTapGesture.numberOfTapsRequired = 1;
        singleTapGesture.numberOfTouchesRequired  = 1;
        [_videoPannel addGestureRecognizer:singleTapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTapVideo)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired  = 1;
        [_videoPannel addGestureRecognizer:doubleTapGesture];
        
        UILabel *flowLable = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, self.videoPannel.frame.origin.y+self.videoPannel.frame.size.height-20, 60, 15)];
        flowLable.font = [UIFont systemFontOfSize:11];
        flowLable.textColor = [UIColor whiteColor];
        flowLable.text = @"";
        flowLable.tag = 0x200;
        
        _tipLable = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-200)/2, (self.frame.size.height/2)-65, 200, 20)];
        _tipLable.font = [UIFont boldSystemFontOfSize:14];
        _tipLable.textColor = [UIColor whiteColor];
        _tipLable.textAlignment = NSTextAlignmentCenter;
        _tipLable.text = @"";
        
        UIToolbar *btomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.size.height-115, frame.size.width, 50)];
        [btomBar setBackgroundImage:[UIImage imageNamed:@"shu.png"] forToolbarPosition:0 barMetrics:0];
        
        UIBarButtonItem *snapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paizhao_1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBtnSnap)];
        snapButton.tintColor = [UIColor whiteColor];
        
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"shengyin_1.png"] forState:UIControlStateNormal];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"jingyin_1.png"] forState:UIControlStateSelected];
        [_voiceBtn addTarget:self action:@selector(onBtnVoice) forControlEvents:UIControlEventTouchDown];
        _voiceBtn.showsTouchWhenHighlighted = YES;
        _voiceBtn.frame = CGRectMake(0, 0, 29, 49);
        UIBarButtonItem *voiceButton = [[UIBarButtonItem alloc] initWithCustomView:_voiceBtn];
        
        UIBarButtonItem *flsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"quanping_1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBtnFullScreen)];
        flsButton.tintColor = [UIColor whiteColor];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array2 = [[NSArray alloc]initWithObjects:flexibleSpace,snapButton,flexibleSpace,voiceButton,flexibleSpace,flsButton,flexibleSpace, nil];
        [btomBar setItems:array2];
        
        btomBar.tag = 0x1002;
        _direction = NO;
        
        [self addSubview:pannel];
        [self addSubview:_scrollView];
        [self addSubview:_tipLable];
        [self addSubview:flowLable];
        [self addSubview:btomBar];
    }
    
    return self;
}

- (void)onBtnSnap
{
    if ([_delegate respondsToSelector:@selector(onSnap)]) {
        [_delegate onSnap];
    }
}

- (void)onBtnVoice
{
    _voiceBtn.selected = !_voiceBtn.selected;
    
    if ([_delegate respondsToSelector:@selector(onVoice)]) {
        [_delegate onVoice];
    }
}

- (void)onBtnFullScreen
{
    _scrollView.zoomScale = 1.0f;
    
    if ([_delegate respondsToSelector:@selector(onFullScreen)]) {
        [_delegate onFullScreen];
    }
}

-(void)setDataFlow:(int)size
{
    UILabel *flowLable = (UILabel*)[self viewWithTag:0x200];
    flowLable.text = [NSString stringWithFormat:@"%dKBPS", size];
}

-(void)refreshLayout
{
    _direction = !_direction;
    
    if ([_delegate respondsToSelector:@selector(onRefreshLayout:)]) {
        [_delegate onRefreshLayout:_direction];
    }
    
    UILabel *flowLabel = (UILabel*)[self viewWithTag:0x200];
    UIToolbar *btomBar = (UIToolbar*)[self viewWithTag:0x1002];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    
    if (_direction) {
        _scrollView.transform = CGAffineTransformMakeRotation(M_PI/2);
        _tipLable.transform = CGAffineTransformMakeRotation(M_PI/2);
        flowLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
        btomBar.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        _scrollView.frame = self.frame;
        _tipLable.frame = CGRectMake((self.frame.size.height-200)/2, (self.frame.size.width/2)-10, 15, 200);
        flowLabel.frame = CGRectMake(self.frame.size.width-50, self.frame.size.height-100, 20, 80);
        btomBar.frame = CGRectMake(0, (self.frame.size.height-self.frame.size.width)/2, 49, self.frame.size.width);
        
        btomBar.hidden = YES;
    }
    else
    {
        _scrollView.transform = CGAffineTransformMakeRotation(M_PI*2);
        _tipLable.transform = CGAffineTransformMakeRotation(M_PI*2);
        flowLabel.transform = CGAffineTransformMakeRotation(M_PI*2);
        btomBar.transform = CGAffineTransformMakeRotation(M_PI*2);
        
        int picWidth = self.frame.size.width;
        int picHeight = picWidth*288/352;
        int pos = (self.frame.size.height-picHeight)/2-65;
        
        _scrollView.frame = CGRectMake(0, pos, picWidth, picHeight);
        _tipLable.frame = CGRectMake((self.frame.size.width-200)/2, (self.frame.size.height/2)-65, 200, 15);
        flowLabel.frame = CGRectMake(self.frame.size.width-60, _scrollView.frame.origin.y+_scrollView.frame.size.height-20, 60, 15);
        
        btomBar.frame = CGRectMake(0, self.frame.size.height-115, self.frame.size.width, 50);
        btomBar.hidden = NO;
    }
    
    [UIView commitAnimations];
    
    [self.videoPannel resizeWindow];
}

-(void)onSingleTapVideo
{
    if (_direction)
    {
        UIToolbar *btomBar = (UIToolbar*)[self viewWithTag:0x1002];
        btomBar.hidden = !btomBar.hidden;
    }
}

-(void)onDoubleTapVideo
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    _scrollView.zoomScale = 1.0f;
    [UIView commitAnimations];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return (UIView*)_videoPannel;
}


@end
