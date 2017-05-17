//
//  storyPlayView.m
//  YSTParentClient
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "storyPlayView.h"
#import "utilityFunction.h"

@interface storyPlayView()
-(void)onBtnPre;
-(void)onBtnPlay;
-(void)onBtnNext;
@end

@implementation storyPlayView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0.5922f green:0.8078f blue:0.4078f alpha:1.0f];
        
        UIView *pannel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-65)];
        pannel.backgroundColor =  [UIColor colorWithRed:0.9294f green:0.9216f blue:0.8157f alpha:1.0f];
        
        _coverPannel = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-300)/2, (frame.size.height-480)/2+10, 300, 280)];
 
        UIButton* preBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2-110, frame.size.height-125, 40, 40)];
        [preBtn setImage:[UIImage imageNamed:@"shang.png"] forState:UIControlStateNormal];
        [preBtn setImage:[UIImage imageNamed:@"shang_down.png"] forState:UIControlStateHighlighted];
        [preBtn addTarget:self action:@selector(onBtnPre) forControlEvents:UIControlEventTouchUpInside];
        
        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2-50, frame.size.height-135, 100, 60)];
        [_playBtn setImage:[UIImage imageNamed:@"bofang_.png"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"bofang_down_.png"] forState:UIControlStateHighlighted];
        [_playBtn setImage:[UIImage imageNamed:@"zanting_.png"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(onBtnPlay) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.selected = YES;
        
        UIButton* nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2+65, frame.size.height-125, 40, 40)];
        [nextBtn setImage:[UIImage imageNamed:@"xia_.png"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"xia_down.png"] forState:UIControlStateHighlighted];
        [nextBtn addTarget:self action:@selector(onBtnNext) forControlEvents:UIControlEventTouchUpInside];
        
        _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-140, frame.size.height-150, 40, 12)];
        _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2+110, frame.size.height-150, 40, 12)];
        _currentTime.font = [UIFont systemFontOfSize:12];
        _totalTime.font = [UIFont systemFontOfSize:12];
        _currentTime.text = @"00:00";
        _totalTime.text = @"00:00";
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(frame.size.width/2-100, frame.size.height-150, 200, 12)];
        [_slider setThumbImage:[UIImage imageNamed:@"jinduyuan-.png"] forState:UIControlStateHighlighted];
        [_slider setThumbImage:[UIImage imageNamed:@"jinduyuan-.png"] forState:UIControlStateNormal];
        
        [self addSubview:pannel];
        [self addSubview:_coverPannel];
        [self addSubview:preBtn];
        [self addSubview:_playBtn];
        [self addSubview:nextBtn];
        [self addSubview:_currentTime];
        [self addSubview:_slider];
        [self addSubview:_totalTime];
    }
    
    return self;
}

- (void)onBtnPre
{
    if ([_delegate respondsToSelector:@selector(onPre)]) {
        [_delegate onPre];
    }
}

- (void)onBtnPlay
{
    _playBtn.selected = !_playBtn.selected;
    
    if ([_delegate respondsToSelector:@selector(onPlay)]) {
        [_delegate onPlay];
    }
}

- (void)onBtnNext
{
    if ([_delegate respondsToSelector:@selector(onNext)]) {
        [_delegate onNext];
    }
}

-(void)reset
{
    _playBtn.selected = YES;
    _currentTime.text = @"00:00";
    _totalTime.text = @"00:00";
    _slider.value = 0;
}

@end
