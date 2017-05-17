//
//  storyListViewController.h
//  YSTParentClient
//
//  Created by apple on 14-10-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface storyListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) int storyCatagory;
@end
