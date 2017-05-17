//
//  contactViewController.h
//  YSTParentClient
//
//  Created by apple on 15/5/15.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface contactViewController : UIViewController
@property(nonatomic, weak) NSMutableArray* contactArray, *classArray;
@property(nonatomic, weak) NSMutableDictionary *contactStatusDict;
@property(nonatomic) int organizationColum;
@end
