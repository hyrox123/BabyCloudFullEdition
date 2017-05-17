//
//  MSFMediaPlayer.h
//  YSTParentClient
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^progressBlock)(int percentage, CGFloat elapsedTime,
                              CGFloat timeRemaining, NSError *error, BOOL finished);


@interface MSFMediaPlayer : NSObject
-(void)startStreamingRemoteMediaFromURL:(NSString *)url parentView:(UIView*)parent andBlock:(progressBlock)block;
-(void)pause:(BOOL)state;
-(void)stop;
-(void)drag:(UISlider*)sender;
-(void)resize:(CGRect)rect;
@end
