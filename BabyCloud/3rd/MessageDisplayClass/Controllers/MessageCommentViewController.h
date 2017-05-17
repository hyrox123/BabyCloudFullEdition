//
//  MessageCommentViewController.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageCommentInputView.h"
#import "ZBMessageShareMenuView.h"
#import "ZBMessageManagerFaceView.h"
#import "ZBMessage.h"

typedef NS_ENUM(NSInteger,ZBMessageCommentViewState) {
    ZBMessageCommentViewStateShowFace,
    ZBMessageCommentViewStateShowShare,
    ZBMessageCommentViewStateShowNone,
};

typedef void(^sendMessageBlock)(NSString*);

@interface MessageCommentViewController : UIViewController<ZBMessageCommentInputViewDelegate,ZBMessageManagerFaceViewDelegate>

@property (nonatomic,strong) ZBMessageCommentInputView *messageToolView;

@property (nonatomic,strong) ZBMessageManagerFaceView *faceView;

@property (nonatomic,assign) CGFloat previousTextViewContentHeight;

- (void)sendMessage:(ZBMessage *)message;

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageCommentViewState)state;

- (void)showKeyboard:(NSString*)newsId type:(int)commentType andBlock:(sendMessageBlock)block;
- (void)hideKeyboard;

@end
