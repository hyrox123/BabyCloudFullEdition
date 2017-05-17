//
//  MSFMediaPlayer.m
//  YSTParentClient
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "MSFMediaPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

@interface NSTimer(Blocks)
+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
@end

@interface NSTimer(Control)
-(void)pauseTimer;
-(void)resumeTimer;
@end

@interface MSFMediaPlayer()
@property(nonatomic) BOOL rotationState;
@property(nonatomic) AVPlayer *player;
@property(nonatomic) AVPlayerLayer *playerLayer;
@property(nonatomic) NSTimer *timer;
@property(nonatomic) UIView *parentView;
@end

@implementation MSFMediaPlayer

-(void)startStreamingRemoteMediaFromURL:(NSString *)url parentView:(UIView*)parent andBlock:(progressBlock)block
{
    
    NSError *error = nil;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];

    _parentView = parent;
    _player = [AVPlayer playerWithPlayerItem:item];
    
    if (_parentView != nil) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = parent.layer.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [_parentView.layer addSublayer:_playerLayer];
    }
    
    [_player play];
    
    if (!error) {
        
        __block int percentage = 0;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            
            if ((CMTimeGetSeconds(_player.currentItem.duration) - CMTimeGetSeconds(_player.currentItem.currentTime)) != 0) {
                
                percentage = (int)((CMTimeGetSeconds(_player.currentItem.currentTime) * 100)/CMTimeGetSeconds(_player.currentItem.duration));
                int timeRemaining = CMTimeGetSeconds(_player.currentItem.duration) - CMTimeGetSeconds(_player.currentItem.currentTime);
                
                if (block) {
                    block(percentage, CMTimeGetSeconds(_player.currentItem.currentTime), timeRemaining, error, NO);
                }
            }
            else
            {
                
                int timeRemaining = CMTimeGetSeconds(_player.currentItem.duration) - CMTimeGetSeconds(_player.currentItem.currentTime);
                
                if (block) {
                    block(100, CMTimeGetSeconds(_player.currentItem.currentTime), timeRemaining, error, YES);
                }
                
                [_timer invalidate];
            }
        } repeats:YES];
    }
    else
    {
        if (block) {
            block(0, 0, 0, error, YES);
        }
    }
}

-(void)pause:(BOOL)state
{
    if (!_player) {
        return;
    }
    
    if (state) {
        [_player pause];
        [_timer pauseTimer];
    }
    else
    {
        [_player play];
        [_timer resumeTimer];
    }
}

-(void)stop
{
    if (_player) {
        [_player replaceCurrentItemWithPlayerItem:nil];
        _playerLayer = nil;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)drag:(UISlider*)sender
{
    if (!sender) {
        return;
    }
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    Float64 playerSection = CMTimeGetSeconds(_player.currentItem.duration) * sender.value;
    [_player seekToTime:CMTimeMakeWithSeconds(playerSection, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)resize:(CGRect)rect
{
    _playerLayer.frame = rect;
}

@end

@implementation NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    
    void (^block)() = [inBlock copy];
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    
    void (^block)() = [inBlock copy];
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(void)executeSimpleBlock:(NSTimer *)inTimer {
    
    if ([inTimer userInfo]) {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}

@end

@implementation NSTimer (Control)

static NSString *const NSTimerPauseDate = @"NSTimerPauseDate";
static NSString *const NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

-(void)pauseTimer {
    
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPreviousFireDate), self.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.fireDate = [NSDate distantFuture];
}

-(void)resumeTimer {
    
    NSDate *pauseDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPreviousFireDate);
    
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    self.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
}

@end

