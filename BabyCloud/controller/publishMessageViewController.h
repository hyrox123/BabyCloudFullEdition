//
//  publishMessageViewController.h
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDisplayViewController.h"

@interface publishMessageViewController : MessageDisplayViewController
@property(nonatomic) NSString *messageType, *imgServerUrl;
@end
