//
//  ZBMessageInputView.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageTextView.h"

typedef enum
{
  ZBMessageInputViewStyleDefault, // ios7 样式
  ZBMessageInputViewStyleQuasiphysical
} ZBMessageInputViewStyle;

@protocol ZBMessageInputViewDelegate <NSObject>

@optional

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView;

/**
 *  点击+号按钮Action
 */
- (void)didSelectedMultipleMediaAction:(BOOL)changed;

/**
 *  发送第三方表情
 */
- (void)didSendFaceAction:(BOOL)sendFace;

/**
 *  收键盘
 */
- (void)shrinkKeyboardAction;


@end

@interface ZBMessageInputView : UIImageView

@property (nonatomic,weak) id<ZBMessageInputViewDelegate> delegate;

/**
 *  当前输入工具条的样式
 */
@property (nonatomic, assign) ZBMessageInputViewStyle messageInputViewStyle;

/**
 *  +号按钮
 */
@property (nonatomic, readonly) UIButton *multiMediaSendButton;

/**
 *  第三方表情按钮
 */
@property (nonatomic, readonly) UIButton *faceSendButton;

/**
 *  收键盘按钮
 */
@property (nonatomic, readonly) UIButton *shrinkKeyBoardButton;

@end
