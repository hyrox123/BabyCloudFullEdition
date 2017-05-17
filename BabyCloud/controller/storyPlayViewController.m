//
//  storyPlayViewController.m
//  YSTParentClient
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "storyPlayViewController.h"
#import "storyPlayView.h"
#import "HttpService.h"
#import "MSFMediaPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "UIImageView+WebCache.h"
#import "ProtoType.h"
#import "utilityFunction.h"
#import "SDPieLoopProgressView.h"
#import "mobClick.h"

@interface storyPlayViewController()<stroyPlayViewDelegate>
@property(nonatomic) storyPlayView *canvasView;
@property(nonatomic) MSFMediaPlayer *audioPlayer;

-(void)playMusic:(NSString*)url;
-(void)backOrForwardAudio:(UISlider*)sender;
-(void)refreshAlbum;
@end

@implementation storyPlayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"睡前故事播放"];
    [MobClick beginEvent:@"SQGS"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"睡前故事播放"];
    [MobClick endEvent:@"SQGS"];
    
    [_audioPlayer stop];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)configPlayingInfo
{
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    _canvasView = [[storyPlayView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_canvasView];
    _canvasView.delegate = self;
    
    MediaItem *music = (MediaItem*)[self.storyArray objectAtIndex:_playIndex];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor blackColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = music.name;
    self.navigationItem.titleView = titleLable;
    
    [_canvasView.slider addTarget:self action:@selector(backOrForwardAudio:) forControlEvents:UIControlEventValueChanged];
    
    if (music.pic != nil && music.pic.length > 0) {
        
        __block SDPieLoopProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = _canvasView.coverPannel;
        [_canvasView.coverPannel sd_setImageWithURL:[NSURL URLWithString:music.pic]
                                   placeholderImage:[UIImage imageNamed:@"bg_xiangqing"]
                                            options:SDWebImageProgressiveDownload
                                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                               if (!activityIndicator) {
                                                   activityIndicator = [SDPieLoopProgressView progressView];
                                                   activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-60)/2, (weakImageView.frame.size.height-60)/2, 60, 60);
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
    else
    {
        _canvasView.coverPannel.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg_xiangqing@2x" ofType:@"png"]];
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    _audioPlayer = [MSFMediaPlayer new];
    [self playMusic:music.url];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
            {
                _canvasView.playBtn.selected = NO;
                [_audioPlayer pause:YES];
            }
                break;
                
            case UIEventSubtypeRemoteControlPlay:
            {
                _canvasView.playBtn.selected = YES;
                [_audioPlayer pause:NO];
            }
                break;
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
            }
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self onPre];
            }
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self onNext];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)onPre
{
    if (_playIndex > 0)
    {
        [_audioPlayer stop];
        [_canvasView reset];
        
        _playIndex--;
        
        MediaItem *music = (MediaItem*)[self.storyArray objectAtIndex:_playIndex];
        
        CGRect clientRect = [UIScreen mainScreen].bounds;
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
        titleLable.font = [UIFont boldSystemFontOfSize:20];
        titleLable.textColor = [UIColor blackColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.text = music.name;
        self.navigationItem.titleView = titleLable;
        
        if (music.pic != nil && music.pic.length > 0) {
            
            __block SDPieLoopProgressView *activityIndicator = nil;
            __weak UIImageView *weakImageView = _canvasView.coverPannel;
            [_canvasView.coverPannel sd_setImageWithURL:[NSURL URLWithString:music.pic]
                                       placeholderImage:[UIImage imageNamed:@"bg_xiangqing"]
                                                options:SDWebImageProgressiveDownload
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                   if (!activityIndicator) {
                                                       activityIndicator = [SDPieLoopProgressView progressView];
                                                       activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-60)/2, (weakImageView.frame.size.height-60)/2, 60, 60);
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
        else
        {
            _canvasView.coverPannel.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg_xiangqing@2x" ofType:@"png"]];
        }
        
        [self playMusic:music.url];
    }
}

-(void)onPlay
{
    if (_canvasView.playBtn.selected == NO)
    {
        [_audioPlayer pause:YES];
    }
    else
    {
        [_audioPlayer pause:NO];
    }
}

-(void)refreshAlbum
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        MediaItem *music = (MediaItem*)[self.storyArray objectAtIndex:_playIndex];
        
        UIImage *coverImage = nil;
        
        if(music.pic != nil)
        {
            coverImage = [utilityFunction getImageByUrl:music.pic];
        }
        
        if (coverImage == nil)
        {
            coverImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg_xiangqing@2x" ofType:@"png"]];
        }
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: coverImage];
        
        [songInfo setObject:music.name forKey:MPMediaItemPropertyTitle ];
        [songInfo setObject:@"幼视通" forKey:MPMediaItemPropertyArtist ];
        [songInfo setObject:@"" forKey:MPMediaItemPropertyAlbumTitle ];
        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

-(void)onNext
{
    if (_playIndex < [self.storyArray count]-1)
    {
        [_audioPlayer stop];
        [_canvasView reset];
        
        _playIndex++;
        
        MediaItem *music = (MediaItem*)[self.storyArray objectAtIndex:_playIndex];
        
        CGRect clientRect = [UIScreen mainScreen].bounds;
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
        titleLable.font = [UIFont boldSystemFontOfSize:20];
        titleLable.textColor = [UIColor blackColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.text = music.name;
        self.navigationItem.titleView = titleLable;
        
        if (music.pic != nil && music.pic.length > 0) {
            
            __block SDPieLoopProgressView *activityIndicator = nil;
            __weak UIImageView *weakImageView = _canvasView.coverPannel;
            [_canvasView.coverPannel sd_setImageWithURL:[NSURL URLWithString:music.pic]
                                       placeholderImage:[UIImage imageNamed:@"bg_xiangqing"]
                                                options:SDWebImageProgressiveDownload
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                   if (!activityIndicator) {
                                                       activityIndicator = [SDPieLoopProgressView progressView];
                                                       activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-60)/2, (weakImageView.frame.size.height-60)/2, 60, 60);
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
        else
        {
            _canvasView.coverPannel.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg_xiangqing@2x" ofType:@"png"]];
        }
        
        [self playMusic:music.url];
    }
}

-(void)playMusic:(NSString*)url
{
    @autoreleasepool
    {
        [_audioPlayer startStreamingRemoteMediaFromURL:url parentView:nil andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
            
            if (!error) {
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"mm:ss"];
                
                NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
                _canvasView.currentTime.text = [formatter stringFromDate:elapsedTimeDate];
                
                NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
                _canvasView.totalTime.text = [formatter stringFromDate:timeRemainingDate];
                _canvasView.slider.value = percentage * 0.01;
                
            }
            else {
                
                NSLog(@"There has been an error playing the remote file: %@", [error description]);
            }
            
            if (finished) {
                [_audioPlayer stop];
                [_canvasView reset];
                _canvasView.playBtn.selected = NO;
            }
        }];
        
        [self refreshAlbum];
    }
}

-(void)backOrForwardAudio:(UISlider *)sender {
    
    [_audioPlayer pause:YES];
    [_audioPlayer drag:sender];
    [_audioPlayer pause:NO];
}

-(void)dealloc
{
    NSLog(@"storyPlayViewController dealloc");
}

@end



