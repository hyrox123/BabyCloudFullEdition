//
//  bindCardView.m
//  YSTParentClient
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "bindCardView.h"

@implementation bindCardView

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
        
        UIToolbar *navBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        [navBar setBackgroundImage:[UIImage imageNamed:@"shu.png"] forToolbarPosition:0 barMetrics:0];
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBtnBack)];
        leftButton.imageInsets = UIEdgeInsetsMake(10, 0, -10, 0);
        leftButton.tintColor = [UIColor whiteColor];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *titleButton = [[UIBarButtonItem alloc]initWithTitle:@"绑定卡" style:UIBarButtonItemStylePlain target:nil action:nil];
        titleButton.tintColor = [UIColor whiteColor];
        
        [titleButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:UIControlStateNormal];
        
        NSArray *array = [[NSArray alloc]initWithObjects:leftButton,flexibleSpace,titleButton, flexibleSpace, nil];
        [navBar setItems:array];
        
        self.infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, 250) style:UITableViewStylePlain];
        
        self.infoTable.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:navBar];
        [self addSubview:self.infoTable];
        
        
        UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNext.frame = CGRectMake(10, 360, frame.size.width-20, 35);
        btnNext.showsTouchWhenHighlighted = YES;
        btnNext.titleLabel.font = [UIFont systemFontOfSize:16];
        btnNext.titleLabel.textColor = [UIColor whiteColor];
        btnNext.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
        [btnNext setTitle: @"绑定卡" forState: UIControlStateNormal];
        [btnNext addTarget:self action:@selector(onBtnNext) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnNext];
    }
    
    return self;
}

- (void)onBtnBack
{
    if ([self.delegate respondsToSelector:@selector(onBack)]) {
        [self.delegate onBack];
    }
}

- (void)onBtnNext
{
    if ([self.delegate respondsToSelector:@selector(onNext)]) {
        [self.delegate onNext];
    }
}


@end
