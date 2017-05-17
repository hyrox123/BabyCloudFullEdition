//
//  userInfoView.m
//  YSTParentClient
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "userInfoView.h"

@implementation userInfoView

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
        
        self.portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-35, 30, 70, 70)];
        self.infoList = [[UITableView alloc] initWithFrame:CGRectMake(10, 120, frame.size.width-20, 150)];
        
        [self addSubview:_portraitView];
        [self addSubview:_infoList];
    }
    
    return self;
}

@end
