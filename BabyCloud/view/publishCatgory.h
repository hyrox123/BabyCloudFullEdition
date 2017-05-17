//
//  publishCatgory.h
//  YSTParentClient
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^publicCatgorytBlock)();

@interface publishCatgory : UIView
+(void)showPublishCatgory:(UIView*)parent content:(NSString*)content images:(NSMutableArray*)imageArray serverUrl:(NSString*)url messageType:(NSString*)type andBlock:(publicCatgorytBlock)block;
+(void)hidePublishCatgory:(UIView*)parent;
@end
