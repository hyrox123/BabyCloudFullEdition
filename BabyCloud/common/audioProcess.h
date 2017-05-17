#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <Foundation/Foundation.h>

@interface audioProcess : NSObject{
    ALCcontext *mContext;
    ALCdevice *mDevice;
    ALuint outSourceID;
    
    NSMutableDictionary* soundDictionary;
    NSMutableArray* bufferStorageArray;
    
    ALuint buff;
    NSTimer* updataBufferTimer;
    NSCondition* ticketCondition;
    int frq;
}

@property (nonatomic) ALCcontext *mContext;
@property (nonatomic) ALCdevice *mDevice;
@property (nonatomic,retain)NSMutableDictionary* soundDictionary;
@property (nonatomic,retain)NSMutableArray* bufferStorageArray;

-(void)initOpenAL;
- (void)openAudioFromQueue:(short*)data dataSize:(UInt32)dataSize;
-(void)playSound;
- (void)playSound:(NSString*)soundKey;
//如果声音不循环，那么它将会自然停止。如果是循环的，你需要停止
-(void)stopSound; 
- (void)stopSound:(NSString*)soundKey;
- (void)setFrq:(int)num;

-(void)cleanUpOpenAL;
-(void)cleanUpOpenAL:(id)sender;
@end