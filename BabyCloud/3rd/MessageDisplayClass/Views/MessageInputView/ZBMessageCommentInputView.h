//
//  ZBMessageCommentInputView.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageTextView.h"

typedef enum
{
  ZBMessageCommentInputViewStyleDefault, // ios7 样式
  ZBMessageCommentInputViewStyleQuasiphysical
} ZBMessageCommentInputViewStyle;

@protocol ZBMessageCommentInputViewDelegate <NSObject>

@required

/**
 *  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入框输入时候
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView;

@optional

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView;


/**
 *  发送第三方表情
 */
- (void)didSendFaceAction:(BOOL)sendFace;


@end

@interface ZBMessageCommentInputView : UIImageView

@property (nonatomic,weak) id<ZBMessageCommentInputViewDelegate> delegate;

/**
 *  用于输入文本消息的输入框
 */
@property (nonatomic, readonly) ZBMessageTextView *messageInputTextView;

/**
 *  当前输入工具条的样式
 */
@property (nonatomic, assign) ZBMessageCommentInputViewStyle messageInputViewStyle;


/**
 *  第三方表情按钮
 */
@property (nonatomic, readonly) UIButton *faceSendButton;

#pragma mark methods
/**
 *  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  获取输入框内容字体行高
 *
 *  @return 返回行高
 */
+ (CGFloat)textViewLineHeight;

/**
 *  获取最大行数
 *
 *  @return 返回最大行数
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;

#pragma end

@end
