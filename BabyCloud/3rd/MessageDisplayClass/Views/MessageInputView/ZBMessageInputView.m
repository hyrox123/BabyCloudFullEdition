//
//  ZBMessageInputView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageInputView.h"
#import "NSString+Message.h"

@interface ZBMessageInputView()<UITextViewDelegate>

@property (nonatomic, readwrite) UIButton *multiMediaSendButton;

@property (nonatomic, readwrite) UIButton *faceSendButton;

@property (nonatomic, copy) NSString *inputedText;

@property (nonatomic, readwrite) UIButton *shrinkKeyBoardButton;

@property (nonatomic, readwrite) UIButton *markButton;

@end

@implementation ZBMessageInputView

- (void)dealloc{
    
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    
    _shrinkKeyBoardButton = nil;
}

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
            
        case 0:
        {
            if ([self.delegate respondsToSelector:@selector(shrinkKeyboardAction)]) {
                [self.delegate shrinkKeyboardAction];
            }
        }
            break;
            
        case 1:
        {
            self.multiMediaSendButton.selected = NO;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"表情被点击");
            }else{
                NSLog(@"表情没被点击");
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
        }
            break;
            
        case 2:
        {
            self.faceSendButton.selected = NO;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"分享被点击");
            }else{
                NSLog(@"分享没被点击");
            }

            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
                [self.delegate didSelectedMultipleMediaAction:sender.selected];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 添加控件
- (void)setupMessageInputViewBarWithStyle:(ZBMessageInputViewStyle )style{
    // 配置输入工具条的样式和布局
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 按钮长,宽
    CGFloat buttonSize = [ZBMessageInputView textViewLineHeight];
    
    
    
    self.shrinkKeyBoardButton = [self createButtonWithImage:[UIImage imageNamed:@"ToolViewShrink_ios7"]
                                                 HLImage:nil];
    
    [self.shrinkKeyBoardButton setImage:[UIImage imageNamed:@"ToolViewShrink_ios7"]
                            forState:UIControlStateSelected];
    [self.shrinkKeyBoardButton addTarget:self
                               action:@selector(messageStyleButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    self.shrinkKeyBoardButton.tag = 0;
    
    [self addSubview:self.shrinkKeyBoardButton];
    self.shrinkKeyBoardButton.frame = CGRectMake(horizontalPadding,verticalPadding,buttonSize,buttonSize);
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
    self.multiMediaSendButton = [self createButtonWithImage:[UIImage imageNamed:@"TypeSelectorBtn_Black_ios7"]
                                                    HLImage:nil];
    [self.multiMediaSendButton addTarget:self
                                  action:@selector(messageStyleButtonClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
    self.multiMediaSendButton.tag = 2;
    [self addSubview:self.multiMediaSendButton];
    self.multiMediaSendButton.frame = CGRectMake(self.frame.size.width - horizontalPadding - buttonSize,
                                                 verticalPadding,
                                                 buttonSize,
                                                 buttonSize);
    
    // 发送表情
    self.faceSendButton = [self createButtonWithImage:[UIImage imageNamed:@"ToolViewEmotion_ios7"]
                                              HLImage:nil];
    [self.faceSendButton setImage:[UIImage imageNamed:@"ToolViewKeyboard_ios7"]
                         forState:UIControlStateSelected];
    [self.faceSendButton addTarget:self
                            action:@selector(messageStyleButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    self.faceSendButton.tag = 1;
    [self addSubview:self.faceSendButton];
    self.faceSendButton.frame = CGRectMake(self.frame.size.width - 2*buttonSize- horizontalPadding -5,verticalPadding,buttonSize,buttonSize);    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - layout subViews UI
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [ZBMessageInputView textViewLineHeight], [ZBMessageInputView textViewLineHeight])];
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    return button;
}
#pragma end

#pragma mark - Message input view

+ (CGFloat)textViewLineHeight{
    return 36.0f ;// 字体大小为16
}

+ (CGFloat)maxHeight{
    return ([ZBMessageInputView maxLines] + 1.0f) * [ZBMessageInputView textViewLineHeight];
}

+ (CGFloat)maxLines{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}
#pragma end

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
   
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7 )
    {
        _messageInputViewStyle = ZBMessageInputViewStyleDefault;
        self.image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                            resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        _messageInputViewStyle = ZBMessageInputViewStyleQuasiphysical;
        self.image = [[UIImage imageNamed:@"input-bar-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)
                                                                                  resizingMode:UIImageResizingModeStretch];
        
    }
    
    
    [self setupMessageInputViewBarWithStyle:_messageInputViewStyle];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
