//
//  HttpService.m
//  YSTParentClient
//
//  Created by apple on 14-11-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "HttpService.h"
#import "utilityFunction.h"
#import "ProtoType.h"
#import "RCUserInfo.h"

static HttpService *instance = nil;

@interface HttpService()
-(NSDictionary*)readJsonContext:(NSData*)data;
-(NSMutableArray*)parseDeviceListJsonContext:(NSData*)data;
-(NSMutableArray*)parseStroyListJsonContext:(NSData*)data outBrief:(NSMutableDictionary*)dict;
-(NSMutableArray*)parseVodListJsonContext:(NSData*)data outBrief:(NSMutableDictionary*)dict;
-(NSMutableArray*)parseContactsJsonContext:(NSData*)data;
-(NSMutableArray*)parseShuttleJsonContext:(NSData*)data outBreif:(NSMutableDictionary*)dict;
-(NSMutableArray*)parseNoticeJsonContext:(NSData*)data outBreif:(NSMutableDictionary*)dict;
-(NSMutableArray*)parseHistoryNoticeJsonContext:(NSData*)data outBreif:(NSMutableDictionary*)dict;
-(NSDictionary*)parseGPSJsonContext:(NSData*)data;
-(void)parseImageJsonContext:(NSData*)data images:(NSMutableArray*)imagesArray;
-(void)getNewsImageUrl:(NewsItem*)item;
-(bool)uploadNewsImage:(NewsItem*)item postId:(NSString*)postid;
-(NSString*)getMessagePostId:(NSString*)msgType;
-(NSURLRequest*)makeUploadImageRequest:(NSURL*)url images:(NSMutableArray*)imageArray;
-(void)downloadAdvPicture:(NSString*)advId url:(NSString*)advUrl;
@end

@implementation HttpService

+(HttpService*)getInstance
{
    if (!instance) {
        instance = [HttpService new];
    }
    
    return instance;
}

-(UserBaseInfo*)userBaseInfo
{
    if (!_userBaseInfo) {
        _userBaseInfo = [UserBaseInfo new];
    }
    
    return _userBaseInfo;
}

-(UserExtentInfo*)userExtentInfo
{
    if (!_userExtentInfo) {
        _userExtentInfo = [UserExtentInfo new];
        _userExtentInfo.babyArray = [NSMutableArray new];
    }
    
    return _userExtentInfo;
}

-(NSData*)httpRequest:(NSString*)uri
{
    NSURL* url = [NSURL URLWithString:uri];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    NSError *error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error != nil) {
        NSLog(@"%@",[error description]);
    }
    else
    {
        NSLog(@"%@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
    }
    
    return result;
}

-(void)userRegister:(NSString*)userId psw:(NSString*)password nickName:(NSString*)nick andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_regUser.do?username=%@&password=%@", CLU_SERVER_IP, CLU_SERVER_PORT, userId, password];
        
        int retValue = -1;
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&nickname=%@", nick] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{block(retValue);});
    });
}

-(void)userLogin:(NSString*)userName psw:(NSString*)password andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *currentVesion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_userLoginCenter.do?username=%@&password=%@&appversion=%@&apptype=1", CLU_SERVER_IP, CLU_SERVER_PORT, userName, password, currentVesion];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                
                NSString *code = [jsonDic objectForKey:@"code"];
                
                retValue = [code intValue];
                
                if (retValue == 200) {
                    _userName = userName;
                    _userPassword = password;
                    _ystServerUrl = [jsonDic objectForKey:@"serverurl"];
                    _appVersion = [jsonDic objectForKey:@"appversion"];
                    _appUrl = [jsonDic objectForKey:@"appurl"];
                    _appUpdateDesc = [jsonDic objectForKey:@"appdes"];
                    _platformCode = [jsonDic objectForKey:@"areacode"];
                    _userId = [jsonDic objectForKey:@"userid"];
                    _rcId = [jsonDic objectForKey:@"rcid"];
                    _rcToken = [jsonDic objectForKey:@"tokenid"];
                    _timestamp = [jsonDic objectForKey:@"timestamp"];
                    _token = [jsonDic objectForKey:@"token"];
                    _vasUrl = [jsonDic objectForKey:@"vasurl"];
                    
                    [self downloadAdvPicture:[jsonDic objectForKey:@"adid"] url:[jsonDic objectForKey:@"adurl"]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"userPsw"];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{block(retValue);});
    });
}

-(void)downloadAdvPicture:(NSString*)advId url:(NSString*)advUrl
{
    if (advId == nil || advUrl == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *lastAdvVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"advVersion"];
        
        if (lastAdvVersion == nil || [lastAdvVersion compare:advId] != NSOrderedSame) {
            
            UIImage *advImg = [utilityFunction getImageByUrl:advUrl];
            
            if (advImg != nil)
            {
                NSData *picData = UIImageJPEGRepresentation(advImg, (CGFloat)1.0);
                [[NSUserDefaults standardUserDefaults] setObject:picData forKey:@"advImage"];
                [[NSUserDefaults standardUserDefaults] setObject:advId forKey:@"advVersion"];
            }
        }
    });
}

-(void)modifyPsw:(NSString*)oldPsw psw:(NSString*)newPsw andBlock:(statusBlock)block;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_changePSW.do?userid=%@&token=%@&timstamp=%@&password=%@&newpsw=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, _token, _timestamp, oldPsw, newPsw];
        
        int retValue = -1;
        
        NSData *data = [self httpRequest:uri];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)resetPsw:(NSString*)phone psw:(NSString*)newPsw andBlock:(statusBlock)block;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_findPSW.do?username=%@&password=%@", CLU_SERVER_IP, CLU_SERVER_PORT, phone, newPsw];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}


-(void)queryUserBaseInfo:(userBaseInfoBlock)block;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_findUserInfo.do?userid=%@&token=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, _token];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            self.userBaseInfo.userName = [jsonDic objectForKey:@"username"];
            self.userBaseInfo.realName = [jsonDic objectForKey:@"realname"];
            self.userBaseInfo.nickName = [jsonDic objectForKey:@"nickname"];
            self.userBaseInfo.portrait = [jsonDic objectForKey:@"portrait"];
            self.userBaseInfo.sex = [jsonDic objectForKey:@"sex"];
            self.userBaseInfo.phone = [jsonDic objectForKey:@"phone"];
            self.userBaseInfo.email = [jsonDic objectForKey:@"email"];
            self.userBaseInfo.position = [jsonDic objectForKey:@"position"];
            self.userBaseInfo.score = [[jsonDic objectForKey:@"integral"] integerValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.userBaseInfo);
        });
    });
}

-(void)modifyUserBaseInfo:(UserBaseInfo*)userBaseInfo andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_updateUserInfo.do?userid=%@&username=%@&token=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, _userName, _token];
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        
        if (userBaseInfo.sex != nil && userBaseInfo.sex.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&sex=%@", userBaseInfo.sex] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (userBaseInfo.realName != nil && userBaseInfo.realName.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&realname=%@", userBaseInfo.realName] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (userBaseInfo.nickName != nil && userBaseInfo.nickName.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&nickname=%@", userBaseInfo.nickName] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (userBaseInfo.phone != nil && userBaseInfo.phone.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&phone=%@", userBaseInfo.phone] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (userBaseInfo.email != nil && userBaseInfo.email.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&email=%@", userBaseInfo.email] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (userBaseInfo.portrait != nil && userBaseInfo.portrait.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&portrait=%@", userBaseInfo.portrait] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (userBaseInfo.position != nil && userBaseInfo.position.length > 0) {
            [body appendData:[[NSString stringWithFormat:@"&position=%@", userBaseInfo.position] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        int retValue = -1;
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        if (retValue == 200) {
            
            if (userBaseInfo.sex != nil && userBaseInfo.sex.length > 0) {
                _userBaseInfo.sex = userBaseInfo.sex;
            }
            
            if (userBaseInfo.realName != nil && userBaseInfo.realName.length > 0) {
                _userBaseInfo.realName = userBaseInfo.realName;
            }
            
            if (userBaseInfo.nickName != nil && userBaseInfo.nickName.length > 0) {
                _userBaseInfo.nickName = userBaseInfo.nickName;
            }
            
            if (userBaseInfo.phone != nil && userBaseInfo.phone.length > 0) {
                _userBaseInfo.phone = userBaseInfo.phone;
            }
            
            if (userBaseInfo.email != nil && userBaseInfo.email.length > 0) {
                _userBaseInfo.email = userBaseInfo.email;
            }
            
            if (userBaseInfo.portrait != nil && userBaseInfo.portrait.length > 0) {
                _userBaseInfo.portrait = userBaseInfo.portrait;
            }
            
            if (userBaseInfo.position != nil && userBaseInfo.position.length > 0) {
                _userBaseInfo.position = userBaseInfo.position;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)queryUserExtentInfo:(userExtentInfoBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getUserInfo.do?userid=%@&token=%@&timestamp=%@&imei=%@", _ystServerUrl, _userId, _token, _timestamp, [utilityFunction getUUID]];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            self.userExtentInfo.schoolId = [jsonDic objectForKey:@"schoolid"];
            self.userExtentInfo.officialId = [jsonDic objectForKey:@"officialid"];
            self.userExtentInfo.schoolName = [jsonDic objectForKey:@"schoolname"];
            self.userExtentInfo.privilege = [jsonDic objectForKey:@"privilege"];
            self.userExtentInfo.messageServerUrl = [jsonDic objectForKey:@"msgsurl"];
            self.userExtentInfo.imgServerUrl = [jsonDic objectForKey:@"imgsurl"];
            
            [self.userExtentInfo.babyArray removeAllObjects];
            
            NSArray *babyArray = [jsonDic objectForKey:@"classlist"];
            
            @autoreleasepool {
                
                for (NSDictionary *babyDic in babyArray) {
                    BabyInfo *item = [BabyInfo new];
                    item.classId = [babyDic objectForKey:@"classid"];
                    item.className = [babyDic objectForKey:@"classname"];
                    item.studentId = [babyDic objectForKey:@"studentid"];
                    item.studentName = [babyDic objectForKey:@"studentname"];
                    item.enrollmentId = [babyDic objectForKey:@"number"];
                    item.registerDate = [babyDic objectForKey:@"registerdate"];
                    item.birthDay = [babyDic objectForKey:@"birthday"];
                    item.sex = [babyDic objectForKey:@"sex"];
                    item.gpsCardId = [babyDic objectForKey:@"gpscard"];
                    item.entranceCardId = [babyDic objectForKey:@"entrancecard"];
                    item.relation = [babyDic objectForKey:@"relation"];
                    item.invitionCode = [NSString stringWithFormat:@"%d", [[babyDic valueForKey:@"invitioncode"] integerValue]];
                    [self.userExtentInfo.babyArray addObject:item];
                }
            }
            
            if (babyArray.count > 0)
            {
                _currentClassId = ((BabyInfo*)self.userExtentInfo.babyArray[0]).classId;
            }
            else
            {
                _currentClassId = @"";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(retValue, self.userExtentInfo);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(retValue, nil);
            });
        }
    });
}

-(void)modifyBabyInfo:(BabyInfo*)babyInfo andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_updateChildInfo.do?userid=%@&token=%@&timestamp=%@", _ystServerUrl, _userId, _token, _timestamp];
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&studentid=%@", babyInfo.studentId] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (babyInfo.studentName != nil && babyInfo.studentName.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&studentname=%@",  babyInfo.studentName] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (babyInfo.sex != nil && babyInfo.sex.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&sex=%@", babyInfo.sex] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (babyInfo.birthDay != nil && babyInfo.birthDay.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&birthday=%@", babyInfo.birthDay] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (babyInfo.registerDate != nil && babyInfo.registerDate.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&registerdate=%@", babyInfo.registerDate] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (babyInfo.entranceCardId != nil && babyInfo.entranceCardId.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&entrancecard=%@", babyInfo.entranceCardId] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (babyInfo.gpsCardId != nil && babyInfo.gpsCardId.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&gpscard=%@", babyInfo.gpsCardId] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if (babyInfo.relation != nil && babyInfo.relation.length > 0)
        {
            [body appendData:[[NSString stringWithFormat:@"&relation=%@", babyInfo.relation] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        int retValue = -1;
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)queryContacts:(NSString*)classId andBlock:(arrayBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getClassUserList.do?userid=%@&token=%@&timestamp=%@&classid=%@", _ystServerUrl, _userId, _token, _timestamp, classId];
        
        int retValue = -1;
        NSMutableArray *resultArray = [NSMutableArray new];
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            
            NSArray *candidateArray = [jsonDic objectForKey:@"classuserlist"];
            
            @autoreleasepool {
                
                for (NSDictionary *candidateDic in candidateArray) {
                    CandidateItem *item = [CandidateItem new];
                    item.rcid = [candidateDic objectForKey:@"rcid"];
                    item.nickName = [candidateDic objectForKey:@"nickname"];
                    item.portrait = [candidateDic objectForKey:@"portrait"];
                    [resultArray addObject:item];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(resultArray);
        });
    });
}

-(void)queryContactsOneByOne:(NSString*)userType organizationId:(NSString*)organizationId andBlock:(arrayBlock)block
{
    
    NSString  *uri = [NSString stringWithFormat:@"%@/app_getClassUserGroupList.do?userid=%@&token=%@&timestamp=%@&type=%@&organizationid=%@", _ystServerUrl, _userId, _token, _timestamp, userType, organizationId];
    
    int retValue = -1;
    NSMutableArray *resultArray = [NSMutableArray new];
    NSData *data = [self httpRequest:uri];
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic != nil) {
        NSString *code = [jsonDic objectForKey:@"code"];
        retValue = [code intValue];
    }
    
    if (retValue == 200) {
        
        NSArray *candidateArray = [jsonDic objectForKey:@"classuserlist"];
        
        @autoreleasepool {
            
            for (NSDictionary *candidateDic in candidateArray) {
                CandidateItem *item = [CandidateItem new];
                item.rcid = [candidateDic objectForKey:@"rcid"];
                item.nickName = [candidateDic objectForKey:@"nickname"];
                item.realName = [candidateDic objectForKey:@"realname"];
                item.studentName = [candidateDic objectForKey:@"studentname"];
                item.schoolName = [candidateDic objectForKey:@"schoolname"];
                item.relation = [candidateDic objectForKey:@"relation"];
                item.userType = [candidateDic objectForKey:@"utype"];
                item.portrait = [candidateDic objectForKey:@"portrait"];
                item.position = [candidateDic objectForKey:@"position"];
                [resultArray addObject:item];
            }
        }
    }
    
    block(resultArray);
}

-(void)uploadUserPortrait:(stringBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPortrait"];
        NSString *uri = [NSString stringWithFormat:@"%@/upLoadHeadPortrait.do?userid=%@&token=%@&timestamp=%@&areacode=%@", _userExtentInfo.imgServerUrl, _userId, _token, _timestamp, _platformCode];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        
        NSString *boundary = [NSString stringWithFormat:@"--%@",@"AaB03x"];
        
        [request setURL:[NSURL URLWithString:uri]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"multipart/form-data; boundary=AaB03x" forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"userImg.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSString *portraitUrl = nil;
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                portraitUrl = [jsonDic objectForKey:@"imgurl"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(portraitUrl);
        });
    });
}

-(void)uploadImage:(NSData*)imgData destUrl:(NSString*)url block:(stringBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *uri = [NSString stringWithFormat:@"%@/%@&userid=%@", _userExtentInfo.imgServerUrl, url, _userId];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        
        NSString *boundary = [NSString stringWithFormat:@"--%@",@"AaB03x"];
        
        [request setURL:[NSURL URLWithString:uri]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"multipart/form-data; boundary=AaB03x" forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"userImg.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imgData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSString *imageUrl = nil;
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                imageUrl = [jsonDic objectForKey:@"path"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(imageUrl);
        });
    });
}

-(void)queryAuthorInfo:(NSString*)authorId andBlock:(authorBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getMsgAuthorInfo.do?userid=%@&token=%@&timestamp=%@&authorid=%@", _ystServerUrl, _userId, _token, _timestamp, authorId];
        
        int retValue = -1;
        
        CandidateItem *item = [CandidateItem new];
        item.nickName = @"";
        item.organization = @"";
        item.portrait = @"";
        
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            item.nickName = [jsonDic objectForKey:@"uname"];
            item.portrait = [jsonDic objectForKey:@"uportrait"];
            item.organization = [jsonDic objectForKey:@"ubelongname"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(item);
        });
    });
}

-(void)queryDeviceList:(arrayBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *targetStr = @"";
        
        for (int i = 0; i < [_userExtentInfo.babyArray count]; i++)
        {
            if (targetStr.length == 0)
            {
                targetStr = [NSString stringWithFormat:@"%@", ((BabyInfo*)[_userExtentInfo.babyArray objectAtIndex:i]).classId];
            }
            else
            {
                targetStr = [targetStr stringByAppendingString:[NSString stringWithFormat:@",%@", ((BabyInfo*)[_userExtentInfo.babyArray objectAtIndex:i]).classId]];
            }
        }
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getCameraList.do?userid=%@&token=%@&timestamp=%@&classid=%@&privilege=%@", _ystServerUrl, _userId, _token, _timestamp, targetStr, _userExtentInfo.privilege];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block([self parseDeviceListJsonContext:[self httpRequest:uri]]);
        });
    });
}

-(void)queryStoryList:(int)type page:(int)page andBlock:(pageInfoBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_resourceVoice.do?userid=%@&type=%d&page=%d&areacode=%@&token=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, type, page, _platformCode, _token];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableArray *storyArray = [self parseStroyListJsonContext:[self httpRequest:uri] outBrief:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(storyArray, dict);
        });
    });
}

-(void)queryVodList:(int)type page:(int)page andBlock:(pageInfoBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_resourceVideo.do?userid=%@&type=%d&page=%d&areacode=%@&token=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, type, page, _platformCode, _token];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableArray *vodArray = [self parseVodListJsonContext:[self httpRequest:uri] outBrief:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(vodArray, dict);
        });
    });
}

-(void)queryGPS:(dictBlock)block;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getGpsInfo.do?userid=%@&token=%@&timestamp=%@", _ystServerUrl, _userId, _token, _timestamp];
        
        NSDictionary *dict = [self parseGPSJsonContext:[self httpRequest:uri]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(dict);
        });
    });
}

-(void)queryShuttle:(NSString*)entranceCardId fromPage:(int)page andBlock:(pageInfoBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
        NSString *uri = [NSString stringWithFormat:@"%@/app_getEntranceInfo.do?userid=%@&token=%@&timestamp=%@&entrancecard=%@&currentpage=%d", _ystServerUrl, _userId, _token, _timestamp, entranceCardId, page];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableArray *resultArray = [self parseShuttleJsonContext:[self httpRequest:uri] outBreif:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(resultArray, dict);
        });
    });
}

-(void)queryNotice:(int)page noticeType:(NSString*)type andBlock:(pageInfoBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *targetStr = @"systemmessage";
        NSMutableArray *resultArray = nil;
        NSMutableDictionary *dict = nil;
        
        if (_userExtentInfo.officialId != nil && _userExtentInfo.officialId.length > 0) {
            targetStr = [targetStr stringByAppendingString:[NSString stringWithFormat:@",%@", _userExtentInfo.officialId]];
        }
        
        if (_userExtentInfo.schoolId != nil && _userExtentInfo.schoolId.length > 0) {
            targetStr = [targetStr stringByAppendingString:[NSString stringWithFormat:@",%@", _userExtentInfo.schoolId]];
        }
        
        if (_currentClassId != nil && _currentClassId.length > 0) {
            targetStr = [targetStr stringByAppendingString:[NSString stringWithFormat:@",%@", _currentClassId]];
        }
        
        if (targetStr.length > 0) {
            NSString *uri = [NSString stringWithFormat:@"%@/app_getMessageList.do?userid=%@&token=%@&timestamp=%@&pagenum=%d&mgtype=%@&targetid=%@", _userExtentInfo.messageServerUrl, _userId, _token, _timestamp, page, type, targetStr];
            
            dict = [NSMutableDictionary new];
            resultArray = [self parseNoticeJsonContext:[self httpRequest:uri] outBreif:dict];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(resultArray, dict);
        });
    });
}

-(void)queryHistoryNotice:(NSString*)authorId page:(int)pageNumber andBlock:(pageInfoBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getHisMessageList.do?userid=%@&token=%@&timestamp=%@&authorid=%@&pagenum=%d", _userExtentInfo.messageServerUrl, _userId, _token, _timestamp, authorId, pageNumber];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableArray *resultArray = [self parseHistoryNoticeJsonContext:[self httpRequest:uri] outBreif:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(resultArray, dict);
        });
    });
}

-(void)deleteNotice:(NSString*)noticeId andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_deleteMessage.do?userid=%@&token=%@&timestamp=%@&mgid=%@", _userExtentInfo.messageServerUrl, _userId, _token, _timestamp, noticeId];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)forbiddenConversation:(NSString*)rcId  validTime:(int)time  andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_forbiddenConversation.do?userid=%@&token=%@&timestamp=%@&targetid=%@&validtime=%d", _ystServerUrl, _userId, _token, _timestamp, rcId, time];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)publishNewsMessage:(NewsItem*)item messageType:(NSString*)type andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *postId = [self getMessagePostId:type];
        
        int retValue = -1;
        
        if (postId != nil) {
            
            if ([self uploadNewsImage:item postId:postId] == true)
            {
                NSString *uri = [NSString stringWithFormat:@"%@/app_publishMessage.do", _userExtentInfo.messageServerUrl];
                
                NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
                [request setHTTPMethod:@"POST"];
                [request setURL:[NSURL URLWithString:uri]];
                
                NSMutableData *body = [NSMutableData data];
                [body appendData:[[NSString stringWithFormat:@"&userid=%@", _userId] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"&token=%@", _token] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"&timestamp=%@", _timestamp] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"&mgid=%@", postId] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"&mgcontent=%@", item.textContent] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"&imgkey=%@", item.picHashCode] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"&targetid=%@", item.targetId] dataUsingEncoding:NSUTF8StringEncoding]];
                [request setHTTPBody:body];
                
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                
                if (data != nil) {
                    
                    NSDictionary *jsonDic = [self readJsonContext:data];
                    
                    if (jsonDic != nil) {
                        NSString *code = [jsonDic objectForKey:@"code"];
                        retValue = [code intValue];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)publishComment:(NSString*)newsId content:(NSString*)content andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_publishComment.do", _userExtentInfo.messageServerUrl];
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&userid=%@", _userId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&token=%@", _token] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&timestamp=%@", _timestamp] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&mgid=%@", newsId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&content=%@", content] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        int retValue = -1;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)supportNotice:(NSString*)newsId authorId:(NSString*)authorId andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_praiseMessage.do?userid=%@&token=%@&timestamp=%@&mgid=%@&authorid=%@", _userExtentInfo.messageServerUrl, _userId, _token, _timestamp, newsId, authorId];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(NSDictionary*)readJsonContext:(NSData*)data
{
    if (data == nil) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    
    if (error != nil) {
        NSLog(@"%@",[error description]);
        return nil;
    }
    
    return jsonDic;
}


-(NSMutableArray*)parseDeviceListJsonContext:(NSData*)data
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    NSMutableArray *deviceListArray = nil;
    
    if ([code intValue] == 200)
    {
        deviceListArray = [NSMutableArray new];
        
        NSArray *cameraArray = [jsonDic objectForKey:@"cameralist"];
        
        @autoreleasepool {
            for (NSDictionary *cameraDic in cameraArray)
            {
                XDeviceNode *node = [XDeviceNode new];
                node.deviceName = [cameraDic objectForKey:@"devicename"];
                node.deviceId = [cameraDic objectForKey:@"deviceid"];
                node.streamServerIP = [cameraDic objectForKey:@"deviceip"];
                node.streamServerPort = [cameraDic objectForKey:@"deviceport"];
                node.validWatchTime = [cameraDic objectForKey:@"validtime"];
                node.offline = [[cameraDic objectForKey:@"status"] integerValue];
                [deviceListArray addObject:node];
            }
        }
    }
    
    return deviceListArray;
}

-(NSMutableArray*)parseStroyListJsonContext:(NSData*)data outBrief:(NSMutableDictionary *)dict
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    NSMutableArray *storyArray = nil;
    
    if ([code intValue] == 200)
    {
        storyArray = [NSMutableArray new];
        
        [dict setValue:[jsonDic objectForKey:@"totalPage"] forKey:@"totalPage"];
        [dict setValue:[jsonDic objectForKey:@"currentPage"] forKey:@"currentPage"];
        
        NSArray *musicArray = [jsonDic objectForKey:@"musics"];
        
        @autoreleasepool {
            
            for (NSDictionary *musicDic in musicArray)
            {
                MediaItem *item = [MediaItem new];
                item.name = [musicDic objectForKey:@"name"];
                item.url = [musicDic objectForKey:@"url"];
                item.pic = [musicDic objectForKey:@"pic"];
                item.desc = [musicDic objectForKey:@"desc"];
                [storyArray addObject:item];
            }
        }
    }
    
    return storyArray;
}

-(NSMutableArray*)parseVodListJsonContext:(NSData*)data outBrief:(NSMutableDictionary*)dict
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    NSMutableArray *vodListArray = nil;
    
    if ([code intValue] == 200)
    {
        vodListArray = [NSMutableArray new];
        
        [dict setValue:[jsonDic objectForKey:@"totalPage"] forKey:@"totalPage"];
        [dict setValue:[jsonDic objectForKey:@"currentPage"] forKey:@"currentPage"];
        
        NSArray *vodArray = [jsonDic objectForKey:@"vods"];
        
        @autoreleasepool {
            
            for (NSDictionary *musicDic in vodArray)
            {
                MediaItem *item = [MediaItem new];
                item.name = [musicDic objectForKey:@"name"];
                item.url = [musicDic objectForKey:@"url"];
                item.pic = [musicDic objectForKey:@"pic"];
                item.desc = [musicDic objectForKey:@"desc"];
                [vodListArray addObject:item];
            }
        }
    }
    
    return vodListArray;
}

-(NSMutableArray*)parseContactsJsonContext:(NSData*)data
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSMutableArray *resultArray = nil;
    NSString *code = [jsonDic objectForKey:@"code"];
    
    if ([code intValue] == 200) {
        
        resultArray = [NSMutableArray new];
        NSArray *contactsArray = [jsonDic objectForKey:@"contacts"];
        
        @autoreleasepool {
            
            for (NSDictionary *contactDic in contactsArray)
            {
                CandidateItem *item = [CandidateItem new];
                
                item.rcid = [contactDic objectForKey:@"rcid"];
                item.nickName = [contactDic objectForKey:@"nickName"];
                item.portrait = [contactDic objectForKey:@"photo"];
                [resultArray addObject:item];
            }
        }
    }
    
    return resultArray;
}

-(NSDictionary*)parseGPSJsonContext:(NSData *)data
{
    return [self readJsonContext:data];
}

-(NSMutableArray*)parseShuttleJsonContext:(NSData*)data outBreif:(NSMutableDictionary*)dict
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    NSMutableArray *resultArray = nil;
    
    if ([code intValue] == 200) {
        
        NSString *totalPage = [jsonDic objectForKey:@"page_count"];
        NSString *currentPage = [jsonDic objectForKey:@"page_no"];
        
        [dict removeAllObjects];
        [dict setValue:totalPage forKey:@"totalpage"];
        [dict setValue:currentPage forKey:@"currentpage"];
        
        resultArray = [NSMutableArray new];
        
        NSArray *noticeArray = [jsonDic objectForKey:@"data"];
        NSString *lastUpdateTime = @"2015-2-1 00:00:00", *currentUpdateTime = @"";
        ShuttleItem *item = nil;
        
        @autoreleasepool {
            
            for (NSDictionary *noticeDic in noticeArray)
            {
                currentUpdateTime = [noticeDic objectForKey:@"date"];
                
                if ([utilityFunction compareDay:currentUpdateTime time2:lastUpdateTime complex:YES] != 0
                    || item == nil)
                {
                    item = [ShuttleItem new];
                    item.updateTime = currentUpdateTime;
                    item.shuttleId = [noticeDic objectForKey:@"id"];
                    item.recordArray = [NSMutableArray new];
                    item.imageArray = [NSMutableArray new];
                    [resultArray addObject:item];
                }
                
                NSString *detail = [noticeDic objectForKey:@"detail"];
                
                if (detail) {
                    [item.recordArray addObject: detail];
                    lastUpdateTime = currentUpdateTime;
                }
                
                NSString *image = [noticeDic objectForKey:@"imgpath"];
                
                if (image) {
                    [item.imageArray addObject: image];
                }
            }
        }
    }
    
    return resultArray;
}

-(NSMutableArray*)parseNoticeJsonContext:(NSData*)data outBreif:(NSMutableDictionary*)dict
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    NSMutableArray *resultArray = nil;
    
    if ([code intValue] == 200) {
        
        NSString *imageServerUrl = [jsonDic objectForKey:@"imgsurl"];
        NSString *totalPage = [jsonDic objectForKey:@"pagecount"];
        NSString *currentPage = [jsonDic objectForKey:@"pagenum"];
        
        [dict removeAllObjects];
        [dict setValue:totalPage forKey:@"totalPage"];
        [dict setValue:currentPage forKey:@"currentPage"];
        [dict setValue:imageServerUrl forKey:@"imgServerUrl"];
        
        resultArray = [NSMutableArray new];
        
        NSArray *noticeArray = [jsonDic objectForKey:@"messagelist"];
        NewsItem *item = nil;
        
        @autoreleasepool {
            
            for (NSDictionary *noticeDic in noticeArray)
            {
                item = [NewsItem new];
                item.authorId = [noticeDic objectForKey:@"authorid"];
                item.authorName = [noticeDic objectForKey:@"uname"];
                item.organization = [noticeDic objectForKey:@"ubelongname"];
                item.authorPortrait = [noticeDic objectForKey:@"uportrait"];
                item.newsId = [noticeDic objectForKey:@"mgid"];
                item.updateTime = [noticeDic objectForKey:@"mgtime"];
                item.textContent = [noticeDic objectForKey:@"mgcontent"];
                item.picHashCode = [noticeDic objectForKey:@"imgkey"];
                item.supportNumber = [noticeDic objectForKey:@"praisecount"];
                item.serverUrl = imageServerUrl;
                item.commentArray = [NSMutableArray new];
                
                NSArray *commentsArray = [noticeDic objectForKey:@"commentlist"];
                
                for (NSDictionary *commentDic in commentsArray)
                {
                    commentItem *cmtItem = [commentItem new];
                    cmtItem.commentId = [commentDic objectForKey:@"commentid"];
                    cmtItem.authorId = [commentDic objectForKey:@"authorid"];
                    cmtItem.authorName = [commentDic objectForKey:@"uname"];
                    cmtItem.content = [commentDic objectForKey:@"content"];
                    cmtItem.updateTime = [commentDic objectForKey:@"cmmtime"];
                    [item.commentArray addObject:cmtItem];
                }
                
                [self getNewsImageUrl:item];
                [resultArray addObject:item];
            }
        }
    }
    
    return resultArray;
}

-(NSMutableArray*)parseHistoryNoticeJsonContext:(NSData*)data outBreif:(NSMutableDictionary*)dict
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return nil;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    NSMutableArray *resultArray = nil;
    
    if ([code intValue] == 200) {
        
        NSString *imageServerUrl = [jsonDic objectForKey:@"imgsurl"];
        NSString *totalPage = [jsonDic objectForKey:@"pagecount"];
        NSString *currentPage = [jsonDic objectForKey:@"pagenum"];
        
        [dict removeAllObjects];
        [dict setValue:totalPage forKey:@"totalPage"];
        [dict setValue:currentPage forKey:@"currentPage"];
        [dict setValue:imageServerUrl forKey:@"imgServerUrl"];
        
        resultArray = [NSMutableArray new];
        
        NSString *lastUpdateTime = @"2015-1-1 00:00:00";
        NSArray *noticeArray = [jsonDic objectForKey:@"messagelist"];
        NSMutableArray *sameDayRecord = nil;
        NewsItem *item = nil;
        
        @autoreleasepool {
            
            for (NSDictionary *noticeDic in noticeArray)
            {
                item = [NewsItem new];
                item.authorId = [noticeDic objectForKey:@"authorid"];
                item.authorName = [noticeDic objectForKey:@"uname"];
                item.organization = [noticeDic objectForKey:@"ubelongname"];
                item.authorPortrait = [noticeDic objectForKey:@"uportrait"];
                item.newsId = [noticeDic objectForKey:@"mgid"];
                item.updateTime = [noticeDic objectForKey:@"mgtime"];
                item.textContent = [noticeDic objectForKey:@"mgcontent"];
                item.picHashCode = [noticeDic objectForKey:@"imgkey"];
                item.supportNumber = [noticeDic objectForKey:@"praisecount"];
                item.serverUrl = imageServerUrl;
                item.commentArray = [NSMutableArray new];
                
                NSArray *commentsArray = [noticeDic objectForKey:@"commentlist"];
                
                for (NSDictionary *commentDic in commentsArray)
                {
                    commentItem *cmtItem = [commentItem new];
                    cmtItem.commentId = [commentDic objectForKey:@"commentid"];
                    cmtItem.authorId = [commentDic objectForKey:@"authorid"];
                    cmtItem.authorName = [commentDic objectForKey:@"uname"];
                    cmtItem.content = [commentDic objectForKey:@"content"];
                    cmtItem.updateTime = [commentDic objectForKey:@"cmmtime"];
                    [item.commentArray addObject:cmtItem];
                }
                
                [self getNewsImageUrl:item];
                
                if ([utilityFunction compareDay:item.updateTime time2:lastUpdateTime complex:YES] != 0)
                {
                    sameDayRecord = [NSMutableArray new];
                    [resultArray addObject:sameDayRecord];
                    lastUpdateTime = item.updateTime;
                }
                
                [sameDayRecord addObject:item];
            }
        }
    }
    
    return resultArray;
}

-(void)parseImageJsonContext:(NSData*)data images:(NSMutableArray*)imagesArray
{
    NSDictionary *jsonDic = [self readJsonContext:data];
    
    if (jsonDic == nil) {
        return;
    }
    
    NSString *code = [jsonDic objectForKey:@"code"];
    
    if ([code intValue] == 200) {
        
        NSArray *fullImagesArray = [jsonDic objectForKey:@"imgurllist"];
        
        for (NSDictionary *imgUrl in fullImagesArray)
        {
            [imagesArray addObject:[imgUrl objectForKey:@"imgurl"]];
        }
    }
}

-(void)dispatchRCNotification:(NSString*)message
{
    if ([self.rcDelegate respondsToSelector:@selector(onRecivNotification:)]) {
        [self.rcDelegate onRecivNotification:message];
    }
}

-(NSString*)getMessagePostId:(NSString*)msgType
{
    NSString *uri = [NSString stringWithFormat:@"%@/app_getMessageID.do?userid=%@&token=%@&timestamp=%@&mgtype=%@", _userExtentInfo.messageServerUrl, _userId, _token, _timestamp, msgType];
    
    NSData *data = [self httpRequest:uri];
    NSString *postId = nil;
    
    if (data != nil) {
        
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            postId = [jsonDic objectForKey:@"mgid"];
        }
    }
    
    return postId;
}

-(void)getNewsImageUrl:(NewsItem*)item
{
    if(item.picHashCode.length == 0){
        return;
    }
    
    NSString *uri = [NSString stringWithFormat:@"%@/getMessageKey.do?imgkey=%@", item.serverUrl, item.picHashCode];
    
    item.imageArray = [NSMutableArray new];
    [self parseImageJsonContext:[self httpRequest:uri] images:item.imageArray];
}

-(bool)uploadNewsImage:(NewsItem*)item postId:(NSString*)postid
{
    if ([item.imageArray count] == 0) {
        return true;
    }
    
    NSString *uri = [NSString stringWithFormat:@"%@/publishMessage.do?areacode=%@&userid=%@&token=%@&timestamp=%@&mgid=%@", item.serverUrl, _platformCode, _userId, _token, _timestamp, postid];
    
    NSURLRequest *request = [self makeUploadImageRequest:[NSURL URLWithString:uri] images:item.imageArray];
    
    if (request == nil)
    {
        return false;
    }
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (data == nil)
    {
        return  false;
    }
    
    NSDictionary *jsonDic = [self readJsonContext:data];
    NSString *code = [jsonDic objectForKey:@"code"];
    
    if ([code integerValue] == 200)
    {
        item.picHashCode = [jsonDic objectForKey:@"imgkey"];
        return true;
    }
    
    return false;
}

- (NSData*)generateFormData:(NSMutableArray*)imageArray
{
    NSString *boundary = [NSString stringWithFormat:@"--%@",@"jasonUpload"];
    NSMutableData* body = [[NSMutableData alloc] init];
    
    for (int i = 0; i < [imageArray count]; i++)
    {
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *param = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%d\"; filename=\"uploadImg.jpg\"\r\n", i+1];
        
        [body appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *picData = UIImageJPEGRepresentation([imageArray objectAtIndex:i], 0.8);
        [body appendData:[NSData dataWithData:picData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

- (NSURLRequest*)makeUploadImageRequest:(NSURL*)url images:(NSMutableArray*)imageArray
{
    if (!url)
    {
        return nil;
    }
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:30.0];
    if (!request)
    {
        return nil;
    }
    
    [request setHTTPMethod:@"POST"];
    NSString *header_type = @"multipart/form-data; boundary=jasonUpload";
    [request addValue: header_type forHTTPHeaderField: @"Content-Type"];
    
    NSData *postData = [self generateFormData:imageArray];
    [request addValue:[NSString stringWithFormat:@"%ld", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

-(void)queryShuttleStatistics:(NSString*)classId validDate:(NSString*)date andBlock:(arrayBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_getStuEntrance.do?userid=%@&token=%@&timestamp=%@&classid=%@&date=%@", _ystServerUrl, _userId, _token, _timestamp, classId, date];
        
        int retValue = -1;
        NSMutableArray *resultArray = [NSMutableArray new];
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            
            NSArray *candidateArray = [jsonDic objectForKey:@"studentlist"];
            
            @autoreleasepool {
                
                for (NSDictionary *candidateDic in candidateArray) {
                    SignInItem *item = [SignInItem new];
                    item.studentId = [candidateDic objectForKey:@"studentid"];
                    item.studentName = [candidateDic objectForKey:@"studentname"];
                    item.portrait = [candidateDic objectForKey:@"portrait"];
                    item.state = [candidateDic objectForKey:@"state"];
                    [resultArray addObject:item];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(resultArray);
        });
    });
}

-(void)reportIllegal:(NSString*)newsId reason:(NSString*)reason andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_tipMessage.do?userid=%@&token=%@&timestamp=%@&mgid=%@", _userExtentInfo.messageServerUrl, _userId, _token, _timestamp, newsId];
        
        int retValue = -1;
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&reason=%@", reason] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)searchClass:(NSString*)invitCode invitPhone:(NSString*)phone andBlock:(arrayBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_findInviteClassList.do?userid=%@&token=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, _token];
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&invitioncode=%@", invitCode] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&invitionphone=%@", phone] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSMutableArray *resultArray = [NSMutableArray new];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                
                NSString *code = [jsonDic objectForKey:@"code"];
                
                if ([code intValue] == 200) {
                    
                    NSArray *candidateArray = [jsonDic objectForKey:@"classlist"];
                    
                    @autoreleasepool {
                        
                        for (NSDictionary *candidateDic in candidateArray) {
                            ClassInfo *item = [ClassInfo new];
                            item.classId = [candidateDic objectForKey:@"classid"];
                            item.className = [candidateDic objectForKey:@"classname"];
                            item.schooId = [candidateDic objectForKey:@"schoolid"];
                            item.schoolName = [candidateDic objectForKey:@"schoolname"];
                            item.areaCode = [candidateDic objectForKey:@"areacode"];
                            [resultArray addObject:item];
                        }
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(resultArray);
        });
    });
}

-(void)addStudent:(BabyInfo*)info andBlock:(statusStringBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_addStudentInfo.do?userid=%@&token=%@&timestamp=%@", _ystServerUrl, _userId, _token, _timestamp];
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&studentname=%@", info.studentName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&sex=%@", info.sex] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&birthday=%@", info.birthDay] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&relation=%@", info.relation] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        int retValue = -1;
        NSString *studentId = @"";
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
                studentId = [jsonDic objectForKey:@"studentid"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue, studentId);
        });
    });
}

-(void)deleteStudent:(NSString*)studentId andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_delStudentInfo.do?userid=%@&token=%@&timestamp=%@&studentid=%@", _ystServerUrl, _userId, _token, _timestamp, studentId];
                
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)addClass:(ClassInfo*)info studentId:(NSString*)studentId andBlock:(statusBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"%@/app_addInviteUserInfo.do?userid=%@&token=%@&timestamp=%@", _ystServerUrl, _userId, _token, _timestamp];
        
        int retValue = -1;
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:uri]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"&classid=%@", info.classId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&schoolid=%@", info.schooId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&areacode=%@", info.areaCode] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"&studentid=%@", studentId] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        if (data != nil) {
            
            NSDictionary *jsonDic = [self readJsonContext:data];
            
            if (jsonDic != nil) {
                NSString *code = [jsonDic objectForKey:@"code"];
                retValue = [code intValue];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(retValue);
        });
    });
}

-(void)queryUserInfoByRcid:(NSString*)rcId andBlock:(rcBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_findUserInfo.do?userid=%@&token=%@&rcid=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, _token, rcId];
        
        int retValue = -1;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        RCUserInfo *userInfo = nil;
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            
            NSString *portraitUrl = nil, *displayName = nil;
            
            NSString *tmpPortrait = [jsonDic objectForKey:@"portrait"];
            NSString *tmpRealName = [jsonDic objectForKey:@"realname"];
            NSString *tmpNickName = [jsonDic objectForKey:@"nickname"];
            NSString *tmpUserName = [jsonDic objectForKey:@"username"];
            
            if (tmpPortrait != nil) {
                portraitUrl = [NSString stringWithFormat:@"%@%@", _userExtentInfo.imgServerUrl, tmpPortrait];
            }
            
            if (tmpRealName != nil && [tmpRealName length] > 0)
            {
                displayName = tmpRealName;
            }
            else if(tmpNickName != nil && [tmpNickName length] > 0)
            {
                displayName = tmpNickName;
            }
            else
            {
                displayName = tmpUserName;
            }
            
            userInfo = [[RCUserInfo alloc] initWithUserId:rcId name:displayName portrait:portraitUrl];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(userInfo);
        });
    });
}

-(void)querQiniuToken:(stringBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/clu/app_getQiNiuToken.do?userid=%@&token=%@", CLU_SERVER_IP, CLU_SERVER_PORT, _userId, _token];
        
        int retValue = -1;
        NSString *qiniuToken = nil;
        NSData *data = [self httpRequest:uri];
        NSDictionary *jsonDic = [self readJsonContext:data];
        
        if (jsonDic != nil) {
            NSString *code = [jsonDic objectForKey:@"code"];
            retValue = [code intValue];
        }
        
        if (retValue == 200) {
            qiniuToken =  [jsonDic objectForKey:@"qiniutoken"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(qiniuToken);
        });
    });
}

@end