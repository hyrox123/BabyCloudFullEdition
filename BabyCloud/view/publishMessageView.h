//
//  publishMessageView.h
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@protocol publishMessageViewDelegate <NSObject>
-(void)onLocalPic;
-(void)onCameraPic;
-(void)onTapImage:(int)index;
@optional
-(void)onTemplet;
@end

@interface publishMessageView : UIView
@property(nonatomic) NSMutableArray *imageArray;
@property(nonatomic) UITextView *textMessageView;
@property(nonatomic) UILabel *placeholderLabel;
@property(nonatomic, weak) id<publishMessageViewDelegate>delegate;

-(void)refreshLayout;

@end
