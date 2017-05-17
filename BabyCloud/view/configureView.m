//
//  configureView.m
//  YSTParentClient
//
//  Created by apple on 14-10-16.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "configureView.h"

@interface configureView()
-(void)onBtnLogout;
@end

@implementation configureView

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
        UIView *pannel = [[UIView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height-108)];
        pannel.backgroundColor = [UIColor whiteColor];
        
        self.canvasView = [[infomationHeaderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        
        self.functionList = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, 185) style:UITableViewStylePlain];
        
        self.functionList.backgroundColor = [UIColor clearColor];
        
        UIButton* logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        logoutBtn.frame = CGRectMake(5, 275, frame.size.width-10, 35);
        logoutBtn.showsTouchWhenHighlighted = YES;
        logoutBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        logoutBtn.titleLabel.textColor = [UIColor whiteColor];
        logoutBtn.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
        [logoutBtn setTitle: @"注  销" forState: UIControlStateNormal];
        [logoutBtn addTarget:self action:@selector(onBtnLogout) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:pannel];
        [self addSubview:self.canvasView];
        [self addSubview:self.functionList];
        [self addSubview:logoutBtn];
    }
    
    return self;
}

-(void)onBtnLogout
{
    if ([self.delegate respondsToSelector:@selector(onLogout)]) {
        [self.delegate onLogout];
    }
}

@end
