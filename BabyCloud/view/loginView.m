//
//  loginView.m
//  YSTParentClient
//
//  Created by apple on 14-10-10.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "loginView.h"
#import "HttpService.h"
#import "MLPAutoCompleteTextField.h"

@interface loginView()<UITextFieldDelegate>
- (void)onBtnLogin;
- (void)onTapRegisterLable;
- (void)onTapLostPswLable;
@end

@implementation loginView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
        imgView1.image = [UIImage imageNamed:@"yonghu.png"];
        
        _userNameField = [[MLPAutoCompleteTextField alloc] initWithFrame:CGRectMake(80, 35, 180, 30)];
        _userNameField.backgroundColor = [UIColor clearColor];
        _userNameField.placeholder = @"请输入用户名/手机号";
        _userNameField.returnKeyType = UIReturnKeyDone;
        _userNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userNameField.delegate = self;
        
        UIView *horizontalMark1 = [[UIView alloc] initWithFrame:CGRectMake(10, 70, frame.size.width-20, 0.5)];
        horizontalMark1.backgroundColor = [UIColor lightGrayColor];
        
        UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 90, 30, 30)];
        imgView2.image = [UIImage imageNamed:@"mima.png"];
        
        _pswField = [[UITextField alloc] initWithFrame:CGRectMake(80, 95, 180, 30)];
        _pswField.backgroundColor = [UIColor clearColor];
        _pswField.placeholder = @"请输入密码";
        _pswField.returnKeyType = UIReturnKeyDone;
        _pswField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pswField.secureTextEntry = YES;
        _pswField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pswField.delegate = self;
        
        UIView *horizontalMark2 = [[UIView alloc] initWithFrame:CGRectMake(10, 130, frame.size.width-20, 0.5)];
        horizontalMark2.backgroundColor = [UIColor lightGrayColor];
        
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(5, 160, frame.size.width-10, 35);
        _confirmBtn.showsTouchWhenHighlighted = YES;
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        _confirmBtn.titleLabel.textColor = [UIColor whiteColor];
        _confirmBtn.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
        [_confirmBtn setTitle: @"登   录" forState: UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(onBtnLogin) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lostPswLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 205, 80, 20)];
        
        lostPswLable.font = [UIFont systemFontOfSize:14];
        lostPswLable.textColor = [UIColor lightGrayColor];
        lostPswLable.text = @"忘记密码?";
        lostPswLable.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapLostPswLable)];
        [lostPswLable addGestureRecognizer:singleTapGesture1];
        
        UILabel *registerLable = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-80, 205, 80, 20)];
        
        registerLable.font = [UIFont systemFontOfSize:14];
        registerLable.textColor = [UIColor lightGrayColor];
        registerLable.text = @"注册账号";
        registerLable.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapRegisterLable)];
        [registerLable addGestureRecognizer:singleTapGesture2];
                
        [self addSubview:imgView1];
        [self addSubview:_userNameField];
        [self addSubview:horizontalMark1];
        [self addSubview:imgView2];
        [self addSubview:_pswField];
        [self addSubview:horizontalMark2];
        [self addSubview:_confirmBtn];
        [self addSubview:lostPswLable];
        [self addSubview:registerLable];
    }
    
    return self;
}

- (void)onBtnLogin
{
    if ([_delegate respondsToSelector:@selector(onPressLoginBtn:passWd:)] == YES)
    {
        [_delegate onPressLoginBtn:_userNameField.text passWd:self.pswField.text];
    }
}

- (void)onTapRegisterLable
{
    if ([_delegate respondsToSelector:@selector(onPressRegisterLable)] == YES)
    {
        [_delegate onPressRegisterLable];
    }
}

- (void)onTapLostPswLable
{
    if ([_delegate respondsToSelector:@selector(onPressLostPswLable)] == YES)
    {
        [_delegate onPressLostPswLable];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
