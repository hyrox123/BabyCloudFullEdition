//
//  utilityFunction.m
//  YSTParentClient
//
//  Created by apple on 14-10-15.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "utilityFunction.h"
#import <CommonCrypto/CommonDigest.h>

@interface utilityFunction()

@end

@implementation utilityFunction

static utilityFunction *instance = nil;

+(utilityFunction*)getInstance
{
    if (!instance) {
        instance = [utilityFunction new];
    }
    
    return instance;
}

+(UIImage*) createImage:(int)r green:(int)g blue:(int)b alpha:(int)a width:(int)w height:(int)h
{
    Byte *rgbbuffer = (Byte*)malloc(w*h*4);
    
    for(int i=0;i<w*h*4;i+=4)
    {
        rgbbuffer[i] = b;
        rgbbuffer[i+1] = g;
        rgbbuffer[i+2] = r;
        rgbbuffer[i+3] = a;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(rgbbuffer,
                                                    w, h, 8,
                                                    w * 4,
                                                    colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef frame = CGBitmapContextCreateImage(newContext);
    UIImage* img = [UIImage imageWithCGImage:frame];
    CGImageRelease(frame);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    free(rgbbuffer);
    
    return img;
}

+(UIImage*) createImage:(Byte*)rgbbuffer width:(int)w height:(int)h
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(rgbbuffer,
                                                    w, h, 8,
                                                    w * 4,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    CGImageRef frame = CGBitmapContextCreateImage(newContext);
    UIImage* img = [UIImage imageWithCGImage:frame];
    CGImageRelease(frame);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    
    /*
     CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst;
     CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, rgbbuffer, w*h*4, kCFAllocatorNull);
     CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
     
     CGImageRef cgImage = CGImageCreate(w,
     h,
     8,
     32,
     w*4,
     colorSpace,
     bitmapInfo,
     provider,
     NULL,
     YES,
     kCGRenderingIntentDefault);
     CGColorSpaceRelease(colorSpace);
     UIImage* img = [[UIImage alloc] initWithCGImage:cgImage];
     CGImageRelease(cgImage);
     CGDataProviderRelease(provider);
     CFRelease(data);
     */
    return img;
}

+ (NSString*)GBK2UTF8:(char*)data
{
    NSData *_data = [NSData dataWithBytes:data length:strlen(data)];
    NSStringEncoding encoder = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *retValue = [[NSString alloc]initWithData:_data encoding:encoder];
    return retValue;
}

+ (UIImage*)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *dstImg = nil;
    
    if (nil != image) {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        dstImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return dstImg;
}

+(void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

+(NSString*)getUUID {
    NSString *identifer = [[NSUserDefaults standardUserDefaults]objectForKey:@"UUID"];
    
    if (identifer == nil) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidstring = CFUUIDCreateString(NULL, uuid);
        identifer = [NSString stringWithFormat:@"%@",uuidstring];
        [[NSUserDefaults standardUserDefaults] setObject:identifer forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        CFRelease(uuidstring);
        CFRelease(uuid);
    }
    
    return identifer;
}

+(NSString *)md5:(NSString *)str{
    
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    
    return md5Str;
}

+(UIImage*)getImageByUrl:(NSString*)url
{
    NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:imgData];
}

+(UIImage*)strethImageWith:(NSString*)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
}

+(NSTimeInterval)compareTime:(NSString*)str1 time2:(NSString*)str2 complex:(BOOL)opt
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!opt)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *firstDate = [dateFormatter dateFromString:str1];
    NSDate *secondDate = [dateFormatter dateFromString:str2];
    
    NSTimeInterval _fitstDate = [firstDate timeIntervalSince1970]*1;
    NSTimeInterval _secondDate = [secondDate timeIntervalSince1970]*1;
    
    return _fitstDate - _secondDate;
}

+(int)compareDay:(NSString*)str1 time2:(NSString*)str2 complex:(BOOL)opt
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!opt)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *sourceDate1 = [dateFormatter dateFromString:str1];
    NSDate *sourceDate2 = [dateFormatter dateFromString:str2];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps1 = [calendar components:unitFlags fromDate:sourceDate1];
    NSDateComponents *comps2 = [calendar components:unitFlags fromDate:sourceDate2];
    
    return comps1.day - comps2.day;
}

+(NSMutableDictionary*)getChineseDate:(NSString*)str complex:(BOOL)opt
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!opt)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *sourceDate = [dateFormatter dateFromString:str];
    NSDate *now = [NSDate date];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:now];
    NSDateComponents *compsSource = [calendar components:unitFlags fromDate:sourceDate];
    
    NSString *result = @"";
    
    if ([compsNow month] == [compsSource month])
    {
        int distance = [compsNow day] - [compsSource day];
        
        if (distance == 0)
        {
            result = @"今天";
        }
        else if(distance == 1)
        {
            result = @"昨天";
        }
        else
        {
            result = [NSString stringWithFormat:@"%d月%d日", [compsSource month], [compsSource day]];
        }
    }
    else
    {
        result = [NSString stringWithFormat:@"%d月%d日", [compsSource month], [compsSource day]];
    }
    
    NSString *chineseMoth = @"", *day = [NSString stringWithFormat:@"%02d", [compsSource day]];
    
    switch ([compsSource month]) {
            
        case 1:
            chineseMoth = @"一月";
            break;
            
        case 2:
            chineseMoth = @"二月";
            break;
            
        case 3:
            chineseMoth = @"三月";
            break;
            
        case 4:
            chineseMoth = @"四月";
            break;
            
        case 5:
            chineseMoth = @"五月";
            break;
            
        case 6:
            chineseMoth = @"六月";
            break;
            
        case 7:
            chineseMoth = @"七月";
            break;
            
        case 8:
            chineseMoth = @"八月";
            break;
            
        case 9:
            chineseMoth = @"九月";
            break;
            
        case 10:
            chineseMoth = @"十月";
            break;
            
        case 11:
            chineseMoth = @"十一月";
            break;
            
        case 12:
            chineseMoth = @"十二月";
            break;
            
        default:
            break;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:result forKey:@"dateTime"];
    [dic setValue:chineseMoth forKey:@"month"];
    [dic setValue:day forKey:@"day"];
    
    return dic;
}

+(NSString*)getTraditionalDate:(NSString*)str complex:(BOOL)opt
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!opt)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *sourceDate = [dateFormatter dateFromString:str];
    NSDate *now = [NSDate date];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:now];
    NSDateComponents *compsSource = [calendar components:unitFlags fromDate:sourceDate];
    
    NSString *result = @"";
    
    if ([compsNow month] == [compsSource month])
    {
        int distance = [compsNow day] - [compsSource day];
        
        if (distance == 0)
        {
            if (([compsNow hour] - [compsSource hour]) > 0)
            {
                result = [NSString stringWithFormat:@"%d小时前", [compsNow hour] - [compsSource hour]];
            }
            else
            {
                result = [NSString stringWithFormat:@"%d分钟前", [compsNow minute] - [compsSource minute]];
            }
        }
        else if(distance == 1)
        {
            result = @"昨天";
        }
        else if(distance == 2)
        {
            result = @"前天";
        }
        else
        {
            result = [NSString stringWithFormat:@"%d天前", distance];
        }
    }
    else
    {
        result = [NSString stringWithFormat:@"%d月%d日", [compsSource month], [compsSource day]];
    }
    
    return result;
}

+(NSString*)getErrorString:(int)code
{
    NSString *tip = nil;
    
    switch (code) {
        case 301:
            tip = @"认证码不能为空";
            break;
            
        case 302:
            tip = @"认证码和终端不匹配";
            break;
            
        case 403:
            tip = @"密码错误,请重新输入";
            break;
         
        case 408:
            tip = @"账号已被冻结";
            break;
            
        case 409:
            tip = @"不能重复送花";
            break;
            
        case 500:
            tip = @"请求被拒绝";
            break;
            
        case 503:
            tip = @"用户不存在";
            break;
            
        case 506:
            tip = @"用户已存在,不能重复注册";
            break;
            
        default:
            tip = @"服务器无响应";
            break;
    }
    
    NSString *tipMessage = [NSString stringWithFormat:@"%@\n错误码:[%d]", tip, code];
    return tipMessage;
}

void getTime(char *pBuf)
{
    struct tm *current;
    time_t now = time(0);
    current = localtime(&now);
    sprintf(pBuf, "%04d-%02d-%02d %02d:%02d", current->tm_year, current->tm_mon, current->tm_mday, current->tm_hour, current->tm_min);
}

+(bool)timeExpire:(NSString*)source
{
    char beginTime[40] = {0};
    char endTime[40] = {0};
    char realnumber[40] = {0};
    
    const char *str = [source UTF8String];
    
    char *pos = strstr(str, "-");
    
    if(pos == NULL)
    {
        return true;
    }
    
    memcpy(beginTime, str, pos - str);
    memcpy(endTime, pos+1, strlen(pos)-1);
    
    getTime(realnumber);
    pos = strstr(realnumber, " ");
    pos++;
    
    if ((strcmp(pos, beginTime) > 0) && (strcmp(pos, endTime) < 0) )
    {
        return false;
    }
    else
    {
        return true;
    }
}

+(UIImage*)saveView2Img:(UIView*)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(NSString *)getTimeNow
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    
    return timeNow;
}

+(UIImage*)getGrayImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    
    return grayImage;
}

@end

