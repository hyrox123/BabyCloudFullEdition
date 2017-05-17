//
//  configureView.h
//  YSTParentClient
//
//  Created by apple on 14-10-16.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "infomationHeaderView.h"

@protocol configureViewDelegate <NSObject>
-(void)onLogout;
@end

@interface configureView : UIView
@property(nonatomic) infomationHeaderView *canvasView;
@property(nonatomic) UITableView *functionList;
@property(nonatomic, weak) id<configureViewDelegate> delegate;
@end
