//
//  storyPlayView.h
//  YSTParentClient
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol stroyPlayViewDelegate <NSObject>
-(void)onPre;
-(void)onPlay;
-(void)onNext;
@end

@interface storyPlayView : UIView
@property(nonatomic) UIImageView *coverPannel;
@property(nonatomic) UISlider *slider;
@property(nonatomic) UILabel *currentTime, *totalTime;
@property(nonatomic) UIButton *playBtn;
@property(nonatomic, weak) id<stroyPlayViewDelegate> delegate;

-(void)reset;
@end
