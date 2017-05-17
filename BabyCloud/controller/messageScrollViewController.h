//
//  messageScrollViewController.h
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface messageScrollViewController : UIViewController
@property(nonatomic) NSMutableArray *imageArray;
@property(nonatomic) int currentIndex;
@property(nonatomic) BOOL imageIsUrl;
@end
