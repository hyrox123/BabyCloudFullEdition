//
//  videoView.h
//  YSTParentClient
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView20.h"

@protocol videoViewDelegate <NSObject>
-(void)onSnap;
-(void)onVoice;
-(void)onFullScreen;
-(void)onRefreshLayout:(int)dirction;
@end

@interface videoView : UIView

@property(nonatomic, weak) id<videoViewDelegate>delegate;
@property(nonatomic) OpenGLView20 *videoPannel;
@property(nonatomic) UILabel *tipLable;

-(void) setDataFlow:(int)size;
-(void) refreshLayout;

@end
