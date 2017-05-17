//
//  infomationHeaderView.m
//  YSTParentClient
//
//  Created by apple on 14-10-11.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "infomationHeaderView.h"
#import "HttpService.h"
#import "utilityFunction.h"

@interface infomationHeaderView()
-(void)onClick;
@end

@implementation infomationHeaderView

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
        self.backgroundColor = [UIColor colorWithRed:0.9294f green:0.9294f blue:0.9294f alpha:1.0f];
        
        self.userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        self.userInfoView.backgroundColor = [UIColor colorWithRed:0.2431f green:0.4196f blue:0.0353f alpha:1.0f];
        
        self.userLogo = [[DKCircleButton alloc] initWithFrame:CGRectMake(18, 5, 50, 50)];
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 150, 20)];
        self.userDesc = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 150, 15)];
        self.userScore = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-80, 10, 80, 15)];
        
        [self.userLogo addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage* babyImag = [UIImage imageNamed:@"tubiao_renwudenglu.png"];
        NSString *babyName = [HttpService getInstance].nickName;
        
        if (babyName.length == 0) {
            babyName = [HttpService getInstance].babyName;
        }
        
        if (babyName.length == 0) {
            babyName = @"未知姓名";
        }
        
        NSString *schoolName = [HttpService getInstance].schoolName;
        
        if (schoolName.length == 0) {
            schoolName = @"未知幼儿园";
        }
        
        NSString *score = [NSString stringWithFormat:@"用户积分:%@", [HttpService getInstance].score];
        
        [self.userLogo setImage:babyImag forState:UIControlStateNormal];
        [self.userName setFont:[UIFont boldSystemFontOfSize: 18.0]];
        [self.userDesc setFont:[UIFont systemFontOfSize: 11.0]];
        [self.userScore setFont:[UIFont systemFontOfSize: 11.0]];
        [self.userName setTextColor:[UIColor whiteColor]];
        [self.userDesc setTextColor:[UIColor whiteColor]];
        [self.userScore setTextColor:[UIColor whiteColor]];
        
        self.userName.text = babyName;
        self.userDesc.text = schoolName;
        self.userScore.text = score;
        
        [self addSubview:self.userInfoView];
        [self addSubview:self.userLogo];
        [self addSubview:self.userName];
        [self addSubview:self.userDesc];
        [self addSubview:self.userScore];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [utilityFunction getImageByUrl:[HttpService getInstance].portraitUrl];
        
            if (image != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.userLogo setImage:image forState:UIControlStateNormal];
                });
            }
        });
    }
    
    return self;
}

-(void)onClick
{
    
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:nil
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
    if (buttonIndex == 1) {
        
        if ([self.delegate respondsToSelector:@selector(onBtnClickCamera)]) {
            [self.delegate onBtnClickCamera];
        }
    }
    
    if (buttonIndex == 2) {
        
        if ([self.delegate respondsToSelector:@selector(onBtnClickLocal)]) {
            [self.delegate onBtnClickLocal];
        }
    }
}


-(void)refresh
{
    UIImage *babyImag = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPortrait"]];
    
    if (babyImag == nil) {
        babyImag = [UIImage imageNamed:@"tubiao_renwudenglu.png"];
    }
    
    [self.userLogo setImage:babyImag forState:UIControlStateNormal];
}

@end
