//
//  XAbstractTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/5/4.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "XAbstractTableViewCell.h"
#import "ProtoType.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"
#import <QuartzCore/QuartzCore.h>

@implementation XAbstractTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubview:item];
        // Initialization code
    }
    return self;
}

- (void)initSubview:(NewsItem*)item
{
    self.backgroundColor = [UIColor clearColor];
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    UIView *pannelView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(clientRect)-10, 80)];
    [self.contentView addSubview:pannelView];
    
    pannelView.backgroundColor = [UIColor whiteColor];
    pannelView.layer.cornerRadius = 8;
    pannelView.layer.borderWidth = 0.5;
    pannelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 60, 60)];
    [pannelView addSubview:coverView];
    
    UIImageView *notfiyDot = [[UIImageView alloc] initWithFrame:CGRectMake(60, 8, 10, 10)];
    [pannelView addSubview:notfiyDot];

    if (!item.hasRead)
    {
        notfiyDot.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notifyDot@2x" ofType:@"png"]];
    }
    else
    {
        notfiyDot.image = nil;
    }
    
    if (item.imageArray.count > 0)
    {
        NSString *originalUrl = [item.imageArray objectAtIndex:0];
        NSString *ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"];
        
        __block SDPieLoopProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = coverView;
        [coverView sd_setImageWithURL:[NSURL URLWithString:ratioUrl]
                     placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xxmr@2x" ofType:@"png"]]                              options:SDWebImageProgressiveDownload
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 if (!activityIndicator) {
                                     activityIndicator = [SDPieLoopProgressView progressView];
                                     activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-60)/2, (weakImageView.frame.size.height-60)/2, 60, 60);
                                     [weakImageView addSubview:activityIndicator];
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     activityIndicator.progress = (float)receivedSize/(float)expectedSize;
                                 });
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                [activityIndicator dismiss];
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
    }
    else
    {
        coverView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xxmr@2x" ofType:@"png"]];
    }
    
    UILabel *contentLabel = [[UILabel alloc] init];
    [pannelView addSubview:contentLabel];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:14];
    
    if (item.textContent != nil && (item.textContent.length > 0))
    {
        contentLabel.text = item.textContent;
    }
    else
    {
        contentLabel.text = [NSString stringWithFormat:@"共有%lu张图片", (unsigned long)[item.imageArray count]];
    }
    
    CGSize textSize = [contentLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(clientRect)-90, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    
    if (textSize.height > 40) {
        textSize.height = 40;
    }
    
    CGRect textRect = CGRectMake(75, 10, textSize.width, textSize.height);
    contentLabel.frame = textRect;

    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(80, 52, 17, 15)];
    [pannelView addSubview:imageV];
    imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"youeryuan@2x" ofType:@"png"]];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 54, 150, 15)];
    [pannelView addSubview:authorLabel];
    
    authorLabel.font = [UIFont systemFontOfSize:11];
    authorLabel.textColor = [UIColor lightGrayColor];
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.text = item.organization;
    
    UIImageView *stateImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(clientRect)-40, 10, 20, 20)];
    [pannelView addSubview:stateImage];
    stateImage.image = nil;//[UIImage imageNamed:@"youeryuan.png"];

    NSString *customerTime = [utilityFunction getTraditionalDate:item.updateTime complex:YES];
    CGSize customerTimeTextSize = [customerTime boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} context:nil].size;
    
    UIImageView *timeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(clientRect.size.width-customerTimeTextSize.width-35, 54, 15, 15)];
    [pannelView addSubview:timeLogo];
    
    timeLogo.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shijian3@2x" ofType:@"png"]];
    
    UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width-customerTimeTextSize.width-17, 54, customerTimeTextSize.width, 15)];
    [pannelView addSubview:updateTimeLabel];
    
    updateTimeLabel.font = [UIFont systemFontOfSize:11];
    updateTimeLabel.textColor = [UIColor lightGrayColor];
    updateTimeLabel.text = customerTime;
    updateTimeLabel.textAlignment = NSTextAlignmentLeft;
}

@end
