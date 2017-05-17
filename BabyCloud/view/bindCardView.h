//
//  bindCardView.h
//  YSTParentClient
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol bindCardViewDelegate <NSObject>
-(void)onBack;
-(void)onNext;
@end

@interface bindCardView : UIView
@property(nonatomic) UITableView *infoTable;
@property(nonatomic,weak) id<bindCardViewDelegate>delegate;
@end
