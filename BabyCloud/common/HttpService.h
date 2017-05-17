//
//  HttpService.h
//  YSTParentClient
//
//  Created by apple on 14-11-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CLU_SERVER_IP  @"182.92.167.214"
#define CLU_SERVER_PORT 8088

//#define CLU_SERVER_IP  @"192.168.2.64"
//#define CLU_SERVER_PORT 8080

@class NewsItem;
@class UserBaseInfo;
@class UserExtentInfo;
@class BabyInfo;
@class CandidateItem;
@class ClassInfo;
@class RCUserInfo;

@protocol rcNotificationDelegate <NSObject>
@optional
-(void)onRecivNotification:(NSString*)message;
@end

typedef void(^statusBlock)(int);
typedef void(^userBaseInfoBlock)(UserBaseInfo*);
typedef void(^userExtentInfoBlock)(int, UserExtentInfo*);
typedef void(^arrayBlock)(NSMutableArray*);
typedef void(^stringBlock)(NSString*);
typedef void(^authorBlock)(CandidateItem*);
typedef void(^dictBlock)(NSDictionary*);
typedef void(^pageInfoBlock)(NSMutableArray*, NSDictionary*);
typedef void(^rcBlock)(RCUserInfo*);
typedef void(^statusStringBlock)(int, NSString*);

@interface HttpService : NSObject
@property(nonatomic, weak) id<rcNotificationDelegate> rcDelegate;
@property(nonatomic) NSString *userName, *userPassword, *userId, *timestamp, *token, *ystServerUrl, *platformCode, *appVersion, *appUrl, *appUpdateDesc, *rcId, *rcToken, *vasUrl, *currentClassId;
@property(nonatomic) UserBaseInfo *userBaseInfo;
@property(nonatomic) UserExtentInfo *userExtentInfo;
@property(nonatomic) bool isConnectedIM;

+(HttpService*)getInstance;
-(void)userRegister:(NSString*)userId psw:(NSString*)password nickName:(NSString*)nick andBlock:(statusBlock)block;
-(void)userLogin:(NSString*)userId psw:(NSString*)password andBlock:(statusBlock)block;
-(void)resetPsw:(NSString*)phone psw:(NSString*)newPsw andBlock:(statusBlock)block;
-(void)modifyPsw:(NSString*)oldPsw psw:(NSString*)newPsw andBlock:(statusBlock)block;
-(void)queryUserBaseInfo:(userBaseInfoBlock)block;
-(void)modifyUserBaseInfo:(UserBaseInfo*)userBaseInfo andBlock:(statusBlock)block;
-(void)queryUserExtentInfo:(userExtentInfoBlock)block;
-(void)modifyBabyInfo:(BabyInfo*)babyInfo andBlock:(statusBlock)block;
-(void)queryContacts:(NSString*)classId andBlock:(arrayBlock)block;
-(void)queryContactsOneByOne:(NSString*)userType organizationId:(NSString*)organizationId andBlock:(arrayBlock)block;
-(void)queryAuthorInfo:(NSString*)authorId andBlock:(authorBlock)block;
-(void)queryStoryList:(int)type page:(int)page andBlock:(pageInfoBlock)block;
-(void)queryVodList:(int)type page:(int)page andBlock:(pageInfoBlock)block;
-(void)queryDeviceList:(arrayBlock)block;
-(void)uploadUserPortrait:(stringBlock)block;
-(void)uploadImage:(NSData*)imgData destUrl:(NSString*)url block:(stringBlock)block;
-(void)queryGPS:(dictBlock)block;
-(void)queryShuttle:(NSString*)entranceCardId fromPage:(int)page andBlock:(pageInfoBlock)block;
-(void)forbiddenConversation:(NSString*)rcId validTime:(int)time andBlock:(statusBlock)block;
-(void)dispatchRCNotification:(NSString*)message;
-(void)queryNotice:(int)page noticeType:(NSString*)type andBlock:(pageInfoBlock)block;
-(void)queryHistoryNotice:(NSString*)authorId page:(int)pageNumber andBlock:(pageInfoBlock)block;
-(void)deleteNotice:(NSString*)noticeId andBlock:(statusBlock)block;
-(void)publishNewsMessage:(NewsItem*)item messageType:(NSString*)type andBlock:(statusBlock)block;
-(void)publishComment:(NSString*)newsId content:(NSString*)content andBlock:(statusBlock)block;
-(void)supportNotice:(NSString*)newsId authorId:(NSString*)authorId andBlock:(statusBlock)block;
-(void)queryShuttleStatistics:(NSString*)classId validDate:(NSString*)date andBlock:(arrayBlock)block;
-(void)reportIllegal:(NSString*)newsId reason:(NSString*)reason andBlock:(statusBlock)block;
-(void)queryUserInfoByRcid:(NSString*)rcId andBlock:(rcBlock)block;
-(void)addStudent:(BabyInfo*)info andBlock:(statusStringBlock)block;
-(void)deleteStudent:(NSString*)studentId andBlock:(statusBlock)block;
-(void)searchClass:(NSString*)invitCode invitPhone:(NSString*)phone andBlock:(arrayBlock)block;
-(void)addClass:(ClassInfo*)info studentId:(NSString*)studentId andBlock:(statusBlock)block;
-(void)querQiniuToken:(stringBlock)block;
@end