//
//  vodPlayView.m
//  YSTParentClient
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "vodPlayView.h"
#import "utilityFunction.h"

@interface vodPlayView()
@property(nonatomic) BOOL fullScreenState;

-(void)onSingleTapVideo;
-(void)onBtnPlay;
-(void)onBtnFullScreen;
@end

@implementation vodPlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0.5922f green:0.8078f blue:0.4078f alpha:1.0f];
        
        int picWidth = frame.size.width;
        int picHeight = picWidth*288/352;
        int pos = (frame.size.height-picHeight)/2-65;
        
        _videoPannel = [[UIView alloc] initWithFrame:CGRectMake(0, pos, picWidth, picHeight)];
        _videoPannel.backgroundColor = [UIColor blackColor];
        _videoPannel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTapVideo)];
        singleTapGesture.numberOfTapsRequired = 1;
        singleTapGesture.numberOfTouchesRequired  = 1;
        [_videoPannel addGestureRecognizer:singleTapGesture];
        
        _controlPannel = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-120, frame.size.width, 60)];
        [_controlPannel setBackgroundColor:[UIColor colorWithRed:0.5922f green:0.8078f blue:0.4078f alpha:1.0f]];
        
        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
        [_playBtn setImage:[UIImage imageNamed:@"btn_bofang.png"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"btn_downbofang.png"] forState:UIControlStateHighlighted];
        [_playBtn setImage:[UIImage imageNamed:@"btn_zanting.png"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(onBtnPlay) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.selected = YES;
        
        _fullScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-40, 15, 40, 40)];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"btn_quanping-.png"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"btn_down_quanping--.png"] forState:UIControlStateHighlighted];
        [_fullScreenBtn addTarget:self action:@selector(onBtnFullScreen) forControlEvents:UIControlEventTouchUpInside];
 
        _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 35, 12)];
        _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(115, 30, 35, 12)];
        _currentTime.font = [UIFont systemFontOfSize:12];
        _totalTime.font = [UIFont systemFontOfSize:12];
        _currentTime.text = @"00:00";
        _totalTime.text = @"00:00";
        
        _currentTime.textColor = [UIColor whiteColor];
        _totalTime.textColor = [UIColor whiteColor];
        
        UILabel *seg = [[UILabel alloc] initWithFrame:CGRectMake(105, 30, 5, 12)];
        seg.text = @"/";
        seg.textColor = [UIColor whiteColor];
        
        UIImage *track1 = [UIImage imageNamed:@"slider_track1.png"];
        UIImage *track2 = [UIImage imageNamed:@"slider_track2.png"];
        
        track1 = [track1 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        track2 = [track2 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
        [_slider setBackgroundColor:[UIColor whiteColor]];
        [_slider setThumbImage:[UIImage imageNamed:@"jinduyuan-.png"] forState:UIControlStateHighlighted];
        [_slider setThumbImage:[UIImage imageNamed:@"jinduyuan-.png"] forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:track1 forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:track2 forState:UIControlStateNormal];
        
        [_controlPannel addSubview:_slider];
        [_controlPannel addSubview:_playBtn];
        [_controlPannel addSubview:_currentTime];
        [_controlPannel addSubview:seg];
        [_controlPannel addSubview:_totalTime];
        [_controlPannel addSubview:_fullScreenBtn];
        
        UIView *pannel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-120)];
        [pannel setBackgroundColor:[UIColor blackColor]];
        
        [self addSubview:pannel];
        [self addSubview:_videoPannel];
        [self addSubview:_controlPannel];
    }
    
    return self;
}

- (void)onBtnPlay
{
    _playBtn.selected = !_playBtn.selected;
    
    if ([_delegate respondsToSelector:@selector(onPlay)]) {
        [_delegate onPlay];
    }
}

- (void)onBtnFullScreen
{
    _fullScreenState = !_fullScreenState;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];

    if(_fullScreenState)
    {
        if ([_delegate respondsToSelector:@selector(onResize:FrameRect:)]) {
            [_delegate onResize:_fullScreenState FrameRect:CGRectMake(0, 0, self.frame.size.height, self.frame.size.width)];
        }
        
        _videoPannel.transform = CGAffineTransformMakeRotation(M_PI/2);
        _controlPannel.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        _videoPannel.frame = self.frame;
        _controlPannel.frame = CGRectMake(0, 0, 60, self.frame.size.height);
        _slider.frame = CGRectMake(0, 0, self.frame.size.height, 10);
        _fullScreenBtn.frame = CGRectMake(self.frame.size.height-40, 15, 40, 40);
        
        _controlPannel.hidden = YES;
    }
    else
    {
        int picWidth = self.frame.size.width;
        int picHeight = picWidth*288/352;
        int pos = (self.frame.size.height-picHeight)/2-65;
        
        if ([_delegate respondsToSelector:@selector(onResize:FrameRect:)]) {
            [_delegate onResize:_fullScreenState FrameRect:CGRectMake(0, 0, picWidth, picHeight)];
        }
        
        _videoPannel.transform = CGAffineTransformMakeRotation(M_PI*2);
        _controlPannel.transform = CGAffineTransformMakeRotation(M_PI*2);
        
        _videoPannel.frame = CGRectMake(0, pos, picWidth, picHeight);
        _controlPannel.frame = CGRectMake(0, self.frame.size.height-120, self.frame.size.width, 60);
        _slider.frame = CGRectMake(0, 0, self.frame.size.width, 10);
        _fullScreenBtn.frame = CGRectMake(self.frame.size.width-40, 15, 40, 40);
        
        _controlPannel.hidden = NO;
    }
    
    [UIView commitAnimations];
}

-(void)reset
{
    _playBtn.selected = NO;
    _currentTime.text = @"00:00";
    _totalTime.text = @"00:00";
    _slider.value = 0;
}

-(void)onSingleTapVideo
{
    if (_fullScreenState)
    {
      _controlPannel.hidden = !_controlPannel.hidden;
    }
}

@end
