//
//  userInfoViewController.h
//  YSTParentClient
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CandidateItem;

@interface userInfoViewController : UIViewController
@property(nonatomic) CandidateItem *personInfo;
@property(nonatomic) BOOL solidStyle;
@end
