//
//  newsDetailViewController.h
//  YSTParentClient
//
//  Created by apple on 15/5/4.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCommentViewController.h"

@class NewsItem;

@interface newsDetailViewController : MessageCommentViewController
@property(nonatomic,weak) NewsItem *item;
@end
