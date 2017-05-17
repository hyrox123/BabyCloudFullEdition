//
//  MVNetSdk.h
//  MVNetSdk
//
//  Created by apple on 14-11-24.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVUserInfo : NSObject
@property(nonatomic) NSString *ip;
@property(nonatomic) NSString *uid;
@property(nonatomic) NSString *session;
@property(nonatomic) int port;
@end

@protocol MVNetSdkDelegate <NSObject>
@optional
-(void)onVideoPacket:(unsigned char*)data size:(int)size width:(int)width height:(int)height;
-(void)onAudioPacket:(unsigned char*)data size:(int)size;
-(void)onError:(int)errorId;
@end

@interface MVNetSdk : NSObject
@property(nonatomic,weak) id<MVNetSdkDelegate> delegate;

-(id)init;
-(bool)play:(MVUserInfo*)userInfo;
-(bool)stop;
-(bool)close;
@end
