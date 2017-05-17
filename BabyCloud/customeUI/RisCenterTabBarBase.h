//
//  RisCenterTabBarBase.h
//  BabyCloud
//
//  Created by apple on 15/7/24.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RisCenterTabBarBase : UITabBarController

-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;

-(UIButton*)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
