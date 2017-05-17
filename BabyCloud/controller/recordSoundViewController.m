//
//  recordSoundViewController.m
//  YSTParentClient
//
//  Created by apple on 15/7/7.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "recordSoundViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import <QiniuSDK.h>
#import "QNUploadOption.h"
#import "HttpService.h"
#import "MBProgressHUD.h"

#define SCREEN_WIDTH 300
#define SCREEN_HEIGHT 300
#define NAVBAR_HEIGHT 20


#define TITLE_X (SCREEN_WIDTH/2-SCREEN_WIDTH/10)
#define TITLE_Y (NAVBAR_HEIGHT)
#define TITLE_WIDTH (SCREEN_WIDTH/5)
#define TITLE_HEIGHT NAVBAR_HEIGHT

#define RECORDBAR_X (SCREEN_WIDTH/2-SCREEN_WIDTH/4)
#define RECORDBAR_Y (TITLE_Y+TITLE_HEIGHT+NAVBAR_HEIGHT/2)
#define RECORDBAR_WIDTH (SCREEN_WIDTH/2)

#define TIME_X (SCREEN_WIDTH/2-SCREEN_WIDTH/11)
#define TIME_Y (RECORDBAR_Y+NAVBAR_HEIGHT)
#define TIME_WIDTH (SCREEN_WIDTH/4)
#define TIME_HEIGHT NAVBAR_HEIGHT

#define RECORDBUTTON_X (SCREEN_WIDTH/2-SCREEN_WIDTH/6)
#define RECORDBUTTON_Y (TIME_Y+TIME_HEIGHT+NAVBAR_HEIGHT/2)
#define RECORDBUTTON_WIDTH (SCREEN_WIDTH/3)
#define RECORDBUTTON_HEIGHT RECORDBUTTON_WIDTH

#define PLAYBUTTON_X (SCREEN_WIDTH/2-SCREEN_WIDTH/8)
#define PLAYBUTTON_Y (TIME_Y+2*TIME_HEIGHT)
#define PLAYBUTTON_WIDTH SCREEN_WIDTH/4
#define PLAYBUTTON_HEIGHT PLAYBUTTON_WIDTH

#define RECORE_BUTTON_TAG 1010
#define NEW_PLAY_BUTTON_TAG 1011
#define PAUSE_PLAY_BUTTON_TAG 1012
#define FINISH_BUTTON_TAG 1013
#define RECORDAGAIN_BUTTON_TAG 1014
#define PAUSE_BUTTON_TAG 1015

@interface recordSoundViewController ()<AVAudioRecorderDelegate>
@property(atomic) BOOL isRunning, uploadSuccess;
@property(nonatomic) NSString *fileUrl;
@end

@implementation recordSoundViewController
{
    UIView *canvasView;
    
    UILabel* recordTitleLabel;
    UISlider* progressView;
    UILabel* timeLabel;
    UIButton* recordButton;
    UILabel* recordLabel;
    
    NSTimer* timer;
    int recordTime;
    int playTime;
    int playDuration;
    int second;
    int minute;
    
    UIButton* playButton;
    UIButton* finishButton;
    UIButton* pauseButton;
    UIButton* recordAgainButton;
    
    UILabel* playLabel;
    UILabel* finishLabel;
    UILabel* pauseLabel;
    UILabel* recordAgainLabel;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    AVAudioSession * audioSession;
    
    NSURL* recordUrl;
    NSURL* mp3FilePath;
}

- (UIImage*)closeButtonImageWithSize:(CGSize)size strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor shadow:(BOOL)hasShadow
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    float cx = size.width/2;
    float cy = size.height/2;
    
    float radius = size.width > size.height ? size.height/2 : size.height/2;
    radius -= 4;
    
    CGRect rectEllipse = CGRectMake(cx - radius, cy - radius, radius*2, radius*2);
    
    if (fillColor) {
        [fillColor setFill];
        CGContextFillEllipseInRect(context, rectEllipse);
    }
    
    if (strokeColor) {
        [strokeColor setStroke];
        CGContextSetLineWidth(context, 3.0);
        CGFloat lineLength  = radius/2.5;
        CGContextMoveToPoint(context, cx-lineLength, cy-lineLength);
        CGContextAddLineToPoint(context, cx+lineLength, cy+lineLength);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextMoveToPoint(context, cx+lineLength, cy-lineLength);
        CGContextAddLineToPoint(context, cx-lineLength, cy+lineLength);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    if (hasShadow) {
        CGContextSetShadow(context, CGSizeMake(3, 3), 2);
    }
    
    if (strokeColor) {
        CGContextStrokeEllipseInRect(context, rectEllipse);
    }
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)onBtnClose:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onClosePopView:)]) {
        [self.delegate onClosePopView:_fileUrl];
    }
}
- (void)initializeUI {
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    canvasView = [[UIView alloc] initWithFrame:CGRectMake((clientRect.size.width-300)/2, (clientRect.size.height-240)/2, 300, 240)];
    canvasView.layer.cornerRadius = 8;
    canvasView.backgroundColor = [UIColor whiteColor];
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [playButton setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    playButton.tag = NEW_PLAY_BUTTON_TAG;
    [playButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    playLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [playLabel setText:@"播放"];
    [playLabel setTextAlignment:NSTextAlignmentCenter];
    
    pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [pauseButton setImage:[UIImage imageNamed:@"suspend_button"] forState:UIControlStateNormal];
    pauseButton.tag = PAUSE_BUTTON_TAG;
    [pauseButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    pauseLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [pauseLabel setText:@"暂停"];
    [pauseLabel setTextAlignment:NSTextAlignmentCenter];
    
    finishButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X-PLAYBUTTON_WIDTH-10, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [finishButton setImage:[UIImage imageNamed:@"finish_button"] forState:UIControlStateNormal];
    finishButton.tag = FINISH_BUTTON_TAG;
    [finishButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X-PLAYBUTTON_WIDTH-10, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [finishLabel setText:@"完成"];
    [finishLabel setTextAlignment:NSTextAlignmentCenter];
    
    recordAgainButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X+PLAYBUTTON_WIDTH+10, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [recordAgainButton setImage:[UIImage imageNamed:@"record_again_button"] forState:UIControlStateNormal];
    recordAgainButton.tag = RECORDAGAIN_BUTTON_TAG;
    [recordAgainButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    recordAgainLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X+PLAYBUTTON_WIDTH+10, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [recordAgainLabel setText:@"重新录制"];
    [recordAgainLabel setTextAlignment:NSTextAlignmentCenter];
    
    recordTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_X, TITLE_Y, SCREEN_WIDTH, TITLE_HEIGHT)];
    [recordTitleLabel setText:@"录制语音"];
    
    progressView = [[UISlider alloc] initWithFrame:CGRectMake(RECORDBAR_X, RECORDBAR_Y, RECORDBAR_WIDTH, 20)];
    [progressView setThumbImage:[UIImage imageNamed:@"one"] forState:UIControlStateNormal];
    progressView.value = 0;
    progressView.userInteractionEnabled = NO;
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TIME_X, TIME_Y, TIME_WIDTH, TIME_HEIGHT)];
    [timeLabel setText:@"00:00"];
    [timeLabel setFont:[UIFont systemFontOfSize:20]];
    [timeLabel setTextColor:[UIColor blackColor]];
    
    recordButton = [[UIButton alloc] initWithFrame:CGRectMake(RECORDBUTTON_X, RECORDBUTTON_Y, RECORDBUTTON_WIDTH, RECORDBUTTON_HEIGHT)];
    recordButton.tag = RECORE_BUTTON_TAG;
    [recordButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setImage:[UIImage imageNamed:@"record_button"] forState:UIControlStateNormal];
    
    recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(RECORDBUTTON_X, RECORDBUTTON_Y+RECORDBUTTON_HEIGHT+5, RECORDBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [recordLabel setText:@"点击开始"];
    [recordLabel setTextAlignment:NSTextAlignmentCenter];
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    //存储录音文件
    recordUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"selfRecord.caf"]];
    
    //初始化
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:recordUrl settings:recordSetting error:nil];
    //开启音量检测
    audioRecorder.meteringEnabled = YES;
    audioRecorder.delegate = self;
    
    
    UIImage *btnImg = [self closeButtonImageWithSize:CGSizeMake(30, 30)
                                         strokeColor:[UIColor whiteColor]
                                           fillColor:[UIColor blackColor]
                                              shadow:NO];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage: btnImg forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(0, 0, 30, 30);
    closeButton.showsTouchWhenHighlighted = YES;
    closeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeButton addTarget:self action:@selector(onBtnClose:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(282+(clientRect.size.width-300)/2,
                                   (clientRect.size.height-240)/2-10,
                                   30,
                                   30);
    
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [canvasView addSubview:recordTitleLabel];
    [canvasView addSubview:progressView];
    [canvasView addSubview:timeLabel];
    [canvasView addSubview:recordButton];
    [canvasView addSubview:recordLabel];
    [self.view addSubview:canvasView];
    [self.view addSubview:closeButton];
    
    _isRunning = NO;
    _fileUrl = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeUI];
}

- (void)transformCAFToMP3 {
    mp3FilePath = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"myselfRecord.mp3"]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([[recordUrl absoluteString] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[mp3FilePath absoluteString] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
        /*
         NSLog(@"MP3生成成功: %@",audioFileSavePath);
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mp3转化成功！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
         [alert show];
         */
        
        //[self uploadFile:[NSData dataWithContentsOfFile:[mp3FilePath absoluteString]]];
    }
}

- (void)clickOnButton:(UIButton*)sender {
    
    if (_isRunning) {
        return;
    }
    
    _isRunning = YES;
    
    audioSession = [AVAudioSession sharedInstance];//得到AVAudioSession单例对象
    switch (sender.tag) {
        case RECORE_BUTTON_TAG:{
            if (![audioRecorder isRecording]) {
                [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音
                [audioSession setActive:YES error:nil];//启动音频会话管理,此时会阻断后台音乐的播放.
                
                [audioRecorder prepareToRecord];
                [audioRecorder peakPowerForChannel:0.0];
                [audioRecorder record];
                recordTime = 0;
                
                [self recordTimeStart];
                [recordButton setImage:[UIImage imageNamed:@"recording_button"] forState:UIControlStateNormal];
                [recordLabel setText:@"点击结束"];
            }
            else{
                [audioRecorder stop];                          //录音停止
                [audioSession setActive:NO error:nil];         //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
                [timer invalidate];                            //timer失效
                [timeLabel setText:@"00:00"];                  //时间显示复位
                [progressView setValue:0 animated:YES];        //进度条复位
                
                [recordButton removeFromSuperview];
                [recordLabel removeFromSuperview];
                [canvasView addSubview:playButton];
                [canvasView addSubview:finishButton];
                [canvasView addSubview:recordAgainButton];
                [canvasView addSubview:playLabel];
                [canvasView addSubview:finishLabel];
                [canvasView addSubview:recordAgainLabel];
            }
        }
            break;
        case NEW_PLAY_BUTTON_TAG:{
            
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:YES error:nil];
            
            if (recordUrl != nil){
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordUrl error:nil];
                
                [audioPlayer prepareToPlay];
                audioPlayer.volume = 1;
                [audioPlayer play];
                
                [playButton removeFromSuperview];
                [playLabel removeFromSuperview];
                [canvasView addSubview:pauseButton];
                [canvasView addSubview:pauseLabel];
                
                playDuration = (int)audioPlayer.duration;
                NSLog(@"音频时长为：%i",playDuration);
                playTime = 0;
                [self audioPlayTimeStart];
            }
        }
            break;
        case PAUSE_PLAY_BUTTON_TAG:{
            [audioSession setActive:YES error:nil];
            
            [audioPlayer play];
            
            [playButton removeFromSuperview];
            [playLabel removeFromSuperview];
            [canvasView addSubview:pauseButton];
            [canvasView addSubview:pauseLabel];
        }
            break;
        case PAUSE_BUTTON_TAG:{
            [audioPlayer pause];
            [audioSession setActive:NO error:nil];
            
            playButton.tag = PAUSE_PLAY_BUTTON_TAG;
            [pauseButton removeFromSuperview];
            [pauseLabel removeFromSuperview];
            [canvasView addSubview:playButton];
            [canvasView addSubview:playLabel];
        }
            break;
        case FINISH_BUTTON_TAG:{
            [self uploadFile];
        }
            break;
        case RECORDAGAIN_BUTTON_TAG:{
            [audioPlayer stop];
            [audioRecorder stop];
            [audioSession setActive:NO error:nil];
            
            [timer invalidate];
            progressView.value = 0;
            [timeLabel setText:@"00:00"];
            recordTime = 0;
            playTime = 0;
            
            [playButton removeFromSuperview];
            [pauseButton removeFromSuperview];
            [finishButton removeFromSuperview];
            [recordAgainButton removeFromSuperview];
            [playLabel removeFromSuperview];
            [pauseLabel removeFromSuperview];
            [finishLabel removeFromSuperview];
            [recordAgainLabel removeFromSuperview];
            
            [canvasView addSubview:recordButton];
            [canvasView addSubview:recordLabel];
            [recordButton setImage:[UIImage imageNamed:@"record_button"] forState:UIControlStateNormal];
            [recordLabel setText:@"点击开始"];
            
            playButton.tag = NEW_PLAY_BUTTON_TAG;
        }
            break;
        default:
            break;
    }
    
    _isRunning = NO;
}

- (void)recordTimeStart {
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimeTick) userInfo:nil repeats:YES];
}

- (void)recordTimeTick {
    recordTime += 1;
    [progressView setValue:(float)recordTime/30.0 animated:YES];
    if (recordTime == 30) {
        recordTime = 0;
        [audioRecorder stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [timer invalidate];
        [timeLabel setText:@"00:00"];
        [progressView setValue:0.0 animated:YES];
        
        [recordButton removeFromSuperview];
        [recordLabel removeFromSuperview];
        [canvasView addSubview:playButton];
        [canvasView addSubview:finishButton];
        [canvasView addSubview:recordAgainButton];
        [canvasView addSubview:playLabel];
        [canvasView addSubview:finishLabel];
        [canvasView addSubview:recordAgainLabel];
        return;
    }
    [self updateAudioRecordTime];
}

- (void)updateAudioRecordTime {
    minute = recordTime/60.0;
    second = recordTime-minute*60;
    
    [timeLabel setText:[NSString stringWithFormat:@"%02d:%02d",minute,second]];
}

- (void)audioPlayTimeStart {
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playTimeTick) userInfo:nil repeats:YES];
}

- (void)playTimeTick {
    if (playDuration == playTime) {
        playTime = 0;
        [audioPlayer stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        [pauseButton removeFromSuperview];
        [pauseLabel removeFromSuperview];
        [canvasView addSubview:playButton];
        [canvasView addSubview:playLabel];
        
        playButton.tag = NEW_PLAY_BUTTON_TAG;
        
        [timeLabel setText:@"00:00"];
        [timer invalidate];
        progressView.value = 0;
        return;
    }
    if (![audioPlayer isPlaying]) {
        return;
    }
    playTime += 1;
    [progressView setValue:(float)playTime/(float)playDuration animated:YES];
    [self updateAudioPlayTime];
}

- (void)updateAudioPlayTime {
    minute = playTime/60.0;
    second = playTime-minute*60;
    
    [timeLabel setText:[NSString stringWithFormat:@"%02d:%02d",minute,second]];
}

//AVAudioRecorderDelegate方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [audioSession setActive:NO error:nil];
    
    playTime = 0;
    
    [pauseButton removeFromSuperview];
    [pauseLabel removeFromSuperview];
    [canvasView addSubview:playButton];
    [canvasView addSubview:playLabel];
    
    playButton.tag = NEW_PLAY_BUTTON_TAG;
    
    [timeLabel setText:@"00:00"];
    [timer invalidate];
    progressView.value = 0;
}

- (void)uploadFile
{
    _uploadSuccess = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"上传中...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self transformCAFToMP3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSData *data = [NSData dataWithContentsOfFile:[mp3FilePath absoluteString]];
            
            [[HttpService getInstance] querQiniuToken:^(NSString *token) {
                
                if (token == nil)
                {
                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                                   message:@"获取token失败"
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil];
                    
                    [alert show];
                }
                else
                {
                    
                    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"audio/mpeg" progressHandler:^(NSString *key, float percent){
                        
                        NSLog(@"percentage:%f", percent);
                        
                    } params:nil checkCrc:YES cancellationSignal:nil];
                    
                    
                    QNUploadManager *upManager = [[QNUploadManager alloc] init];
                
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd_hh-mm-ss"];
                    NSString *fileName = [NSString stringWithFormat:@"%@.mp3", [dateFormatter stringFromDate:[NSDate date]]];
                    
                    [upManager putData:data key:fileName token:token
                              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                  
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  
                                  NSLog(@"info %@", info);
                                  NSLog(@"resp %@", resp);
                                  
                                  NSString *messageTip = nil;
                                  
                                  if (resp == nil)
                                  {
                                      messageTip = @"上传失败";
                                  }
                                  else
                                  {
                                      _uploadSuccess = YES;
                                      _fileUrl = [resp objectForKey:@"fileurl"];
                                      messageTip = @"上传成功";
                                  }
                                  
                                  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                                                 message:messageTip
                                                                                delegate:self
                                                                       cancelButtonTitle:@"确定"
                                                                       otherButtonTitles:nil];
                                  
                                  [alert show];
                                  
                              } option:opt];
                }
            }];
            
        });
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_uploadSuccess) {
        if ([self.delegate respondsToSelector:@selector(onClosePopView:)]) {
            [self.delegate onClosePopView:_fileUrl];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"recordSoundViewController dealloc");
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
