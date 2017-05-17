//
//  ProtoType.h
//  YSTParentClient
//
//  Created by apple on 15/3/27.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface XDeviceNode : NSObject
@property(nonatomic) NSString *deviceName;
@property(nonatomic) NSString *deviceId;
@property(nonatomic) NSString *streamServerIP;
@property(nonatomic) NSString *streamServerPort;
@property(nonatomic) NSString *validWatchTime;
@property(nonatomic) BOOL  offline;
@end

@interface MediaItem : NSObject
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *url;
@property(nonatomic) NSString *pic;
@property(nonatomic) NSString *desc;
@end

@interface UserBaseInfo : NSObject
@property(nonatomic) NSString *userName;
@property(nonatomic) NSString *realName;
@property(nonatomic) NSString *nickName;
@property(nonatomic) NSString *portrait;
@property(nonatomic) NSString *sex;
@property(nonatomic) NSString *phone;
@property(nonatomic) NSString *email;
@property(nonatomic) NSString *position;
@property(nonatomic) int score;
@end

@interface UserExtentInfo : NSObject
@property(nonatomic) NSString *officialId;
@property(nonatomic) NSString *schoolId;
@property(nonatomic) NSString *schoolName;
@property(nonatomic) NSString *messageServerUrl;
@property(nonatomic) NSString *imgServerUrl;
@property(nonatomic) NSString *privilege;
@property(nonatomic) NSMutableArray *babyArray;
@end

@interface BabyInfo : NSObject
@property(nonatomic) NSString *classId;
@property(nonatomic) NSString *className;
@property(nonatomic) NSString *studentId;
@property(nonatomic) NSString *studentName;
@property(nonatomic) NSString *invitionCode;
@property(nonatomic) NSString *enrollmentId;
@property(nonatomic) NSString *sex;
@property(nonatomic) NSString *registerDate;
@property(nonatomic) NSString *birthDay;
@property(nonatomic) NSString *entranceCardId;
@property(nonatomic) NSString *gpsCardId;
@property(nonatomic) NSString *relation;
@end

@interface CandidateItem : NSObject
@property(nonatomic) NSString *rcid;
@property(nonatomic) NSString *nickName;
@property(nonatomic) NSString *realName;
@property(nonatomic) NSString *studentName;
@property(nonatomic) NSString *schoolName;
@property(nonatomic) NSString *relation;
@property(nonatomic) NSString *userType;
@property(nonatomic) NSString *portrait;
@property(nonatomic) NSString *organization;
@property(nonatomic) NSString *position;
@property(nonatomic) BOOL checked;
@end

@interface NewsItem : NSObject
@property(nonatomic) NSString *serverUrl;
@property(nonatomic) NSString *updateTime;
@property(nonatomic) NSString *newsId;
@property(nonatomic) NSString *authorId;
@property(nonatomic) NSString *authorName;
@property(nonatomic) NSString *authorPortrait;
@property(nonatomic) NSString *organization;
@property(nonatomic) NSString *textContent;
@property(nonatomic) NSString *picHashCode;
@property(nonatomic) NSString *targetId;
@property(nonatomic) NSString *targetType;
@property(nonatomic) NSString *supportNumber;
@property(nonatomic) NSMutableArray *imageArray;
@property(nonatomic) NSMutableArray *commentArray;
@end

@interface ShuttleItem : NSObject
@property(nonatomic) NSString *updateTime;
@property(nonatomic) NSString *shuttleId;
@property(nonatomic) NSMutableArray *recordArray;
@property(nonatomic) NSMutableArray *imageArray;
@end

@interface SignInItem : NSObject
@property(nonatomic) NSString *studentId;
@property(nonatomic) NSString *studentName;
@property(nonatomic) NSString *portrait;
@property(nonatomic) NSString *state;
@end

@interface commentItem : NSObject
@property(nonatomic) NSString *commentId;
@property(nonatomic) NSString *authorId;
@property(nonatomic) NSString *authorName;
@property(nonatomic) NSString *content;
@property(nonatomic) NSString *updateTime;
@end

@interface ClassInfo : NSObject
@property(nonatomic) NSString *schooId;
@property(nonatomic) NSString *classId;
@property(nonatomic) NSString *schoolName;
@property(nonatomic) NSString *className;
@property(nonatomic) NSString *areaCode;
@end

@interface ProtoType : NSObject
@end
