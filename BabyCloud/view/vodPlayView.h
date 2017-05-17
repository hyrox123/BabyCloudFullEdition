//
//  vodPlayView.h
//  YSTParentClient
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol vodPlayViewDelegate <NSObject>
-(void)onPlay;
-(void)onResize:(int)dirction FrameRect:(CGRect)rect;
@end

@interface vodPlayView : UIView
@property(nonatomic) UIView *videoPannel, *controlPannel;
@property(nonatomic) UISlider *slider;
@property(nonatomic) UILabel *currentTime, *totalTime;
@property(nonatomic) UIButton *playBtn, *fullScreenBtn;
@property(nonatomic, weak) id<vodPlayViewDelegate> delegate;

-(void)reset;
@end
