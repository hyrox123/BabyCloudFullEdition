//
//  ShuttleTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 14-10-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "ShuttleTableViewCell.h"

@implementation ShuttleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"infoitembk.png"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"infoitembk.png"]];
        self.backgroundColor = [UIColor clearColor];
        
        self.updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 100, 15)];
        self.beginTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 10, 200, 12)];
        self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 40, 200, 12)];
        
        UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 50, 12)];
        UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, 50, 12)];
        
        title1.text = @"入园:";
        title2.text = @"离园:";
        
        [self.updateTimeLabel setFont:[UIFont boldSystemFontOfSize: 12.0]];
        [self.beginTimeLabel setFont:[UIFont systemFontOfSize: 12.0]];
        [self.endTimeLabel setFont:[UIFont systemFontOfSize: 12.0]];
        [title1 setFont:[UIFont systemFontOfSize: 12.0]];
        [title2 setFont:[UIFont systemFontOfSize: 12.0]];

        [title1 setTextColor:[UIColor orangeColor]];
        [title2 setTextColor:[UIColor blueColor]];
        
        [self addSubview:self.updateTimeLabel];
        [self addSubview:self.beginTimeLabel];
        [self addSubview:self.endTimeLabel];
        [self addSubview:title1];
        [self addSubview:title2];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
