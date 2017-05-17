//
//  KeyBordVIew.m
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import "KeyBordVIew.h"
#import "utilityFunction.h"

@interface KeyBordVIew()<UITextFieldDelegate>
@property(nonatomic) UIImageView *backImageView;
@property(nonatomic) UIButton *voiceBtn;
@property(nonatomic) UIButton *imageBtn;
@property(nonatomic) UIButton *addBtn;
@property(nonatomic) UIButton *speakBtn;
@property(nonatomic) UITextField *textField;
@end

@implementation KeyBordVIew

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initialData];
    }
    
    return self;
}

-(UIButton *)buttonWith:(NSString *)noraml hightLight:(NSString *)hightLight action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:noraml] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)initialData
{
    self.backImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.backImageView.image = [utilityFunction strethImageWith:@"toolbar_bottom_bar.png"];
    [self addSubview:self.backImageView];
    
    self.voiceBtn = [self buttonWith:@"chat_bottom_voice_nor.png" hightLight:@"chat_bottom_voice_press.png" action:@selector(voiceBtnPress:)];
    [self.voiceBtn setFrame:CGRectMake(0,0, 33, 33)];
    [self.voiceBtn setCenter:CGPointMake(20, self.frame.size.height*0.5)];
    [self addSubview:self.voiceBtn];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-130, self.frame.size.height*0.7)];
    self.textField.returnKeyType = UIReturnKeySend;
    self.textField.center = CGPointMake((self.frame.size.width-50)/2, self.frame.size.height*0.5);
    self.textField.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.textField.placeholder = @"请输入内容...";
    self.textField.background = [UIImage imageNamed:@"chat_bottom_textfield.png"];
    self.textField.delegate = self;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:self.textField];
    
    self.imageBtn = [self buttonWith:@"chat_bottom_smile_nor.png" hightLight:@"chat_bottom_smile_press.png" action:@selector(imageBtnPress:)];
    [self.imageBtn setFrame:CGRectMake(0, 0, 33, 33)];
    [self.imageBtn setCenter:CGPointMake(self.frame.size.width-60, self.frame.size.height*0.5)];
    [self addSubview:self.imageBtn];
    
    self.addBtn = [self buttonWith:@"chat_bottom_up_nor.png" hightLight:@"chat_bottom_up_press.png" action:@selector(addBtnPress:)];
    [self.addBtn setFrame:CGRectMake(0, 0, 33, 33)];
    [self.addBtn setCenter:CGPointMake(self.frame.size.width-20, self.frame.size.height*0.5)];
    [self addSubview:self.addBtn];
    
    self.speakBtn = [self buttonWith:nil hightLight:nil action:@selector(speakBtnPress:)];
    [self.speakBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.speakBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakBtn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.speakBtn setTitleColor:[UIColor redColor] forState:(UIControlState)UIControlEventTouchDown];
    [self.speakBtn setBackgroundColor:[UIColor whiteColor]];
    [self.speakBtn setFrame:self.textField.frame];
    self.speakBtn.hidden = YES;
    [self addSubview:self.speakBtn];
}

-(void)touchDown:(UIButton *)voice
{
    if([self.delegate respondsToSelector:@selector(beginRecord)]){
        [self.delegate beginRecord];
    }
}

-(void)speakBtnPress:(UIButton *)voice
{
    if([self.delegate respondsToSelector:@selector(finishRecord)]){
        [self.delegate finishRecord];
    }
}

-(void)voiceBtnPress:(UIButton *)voice
{
    NSString *normal, *hightLight;
    
    if(self.speakBtn.hidden == YES)
    {
       self.speakBtn.hidden = NO;
       self.textField.hidden = YES;
        
       normal = @"chat_bottom_keyboard_nor.png";
       hightLight = @"chat_bottom_keyboard_press.png";
    }
    else
    {
        self.speakBtn.hidden = YES;
        self.textField.hidden = NO;
        
        normal = @"chat_bottom_voice_nor.png";
        hightLight = @"chat_bottom_voice_press.png";
    }
    
    [voice setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [voice setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
}

-(void)imageBtnPress:(UIButton *)image
{
    
    
}

-(void)addBtnPress:(UIButton *)image
{
    
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(KeyBordView:textFiledBegin:)]){
        [self.delegate KeyBordView:self textFiledBegin:textField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(KeyBordView:textFiledReturn:)]){
        [self.delegate KeyBordView:self textFiledReturn:textField];
    }
    
    return YES;
}

@end
