//
//  infomationHeaderView.h
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKCircleButton.h"

@protocol InfomationHeaderDelegate <NSObject>
@optional
-(void)onBtnClickLocal;
-(void)onBtnClickCamera;
@end

@interface infomationHeaderView : UIView

@property(nonatomic) UIView *userInfoView;
@property(nonatomic) DKCircleButton *userLogo;
@property(nonatomic) UILabel *userName;
@property(nonatomic) UILabel *userDesc;
@property(nonatomic) UILabel *userScore;
@property(nonatomic, weak) id<InfomationHeaderDelegate> delegate;

-(void)refresh;
@end
