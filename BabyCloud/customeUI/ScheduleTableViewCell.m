//
//  ScheduleTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 14-11-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "ScheduleTableViewCell.h"
#import "ProtoType.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "SDPieLoopProgressView.h"

@interface ScheduleTableViewCell()

@end

@implementation ScheduleTableViewCell

- (void)awakeFromNib {
    // Initialization code
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
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    self.backgroundColor = [UIColor clearColor];
    UIView *pannelView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, clientRect.size.width-16, 400)];
    pannelView.backgroundColor = [UIColor whiteColor];
    pannelView.layer.borderWidth = 0.5;
    pannelView.layer.borderColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f].CGColor;
    [self.contentView addSubview:pannelView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    [pannelView addSubview:contentLabel];
    
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.numberOfLines = 0;
    
    CGFloat textX = 10;
    CGFloat textY = 8;
    CGFloat textWidth = clientRect.size.width - 38;
    
    CGSize textSize = [item.textContent boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    
    CGRect textRect = CGRectMake(textX, textY, textSize.width, textSize.height);
    
    contentLabel.frame = textRect;
    contentLabel.text = item.textContent;
    
    int itemHeight = [self layoutPicture:(textRect.size.height+textY+16) pictures:item.imageArray parentView:pannelView];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, itemHeight+10, 200, 15)];
    [pannelView addSubview:authorLabel];
    
    authorLabel.font = [UIFont systemFontOfSize:12];
    authorLabel.textColor = [UIColor lightGrayColor];
    
    
    [[HttpService getInstance] queryAuthorInfo:item.authorId andBlock:^(CandidateItem *candidate) {
        authorLabel.text =  [NSString stringWithFormat:@"发布者:%@-%@", candidate.nickName, candidate.organization];
    }];
    
    UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width-150, itemHeight+10, 115, 15)];
    [pannelView addSubview:updateTimeLabel];
    
    updateTimeLabel.font = [UIFont systemFontOfSize:12];
    updateTimeLabel.textColor = [UIColor lightGrayColor];
    updateTimeLabel.textAlignment = NSTextAlignmentRight;
    updateTimeLabel.text = [utilityFunction getTraditionalDate:item.updateTime complex:YES];
    _height = itemHeight+40;
    
    pannelView.frame = CGRectMake(8, 8, clientRect.size.width-16, _height-8);
}

-(int)layoutPicture:(int)originY pictures:(NSMutableArray*)pictureList parentView:(UIView*)parent
{
    if ([pictureList count] == 0) {
        return originY;
    }
    
    for (int i = 0; i < [pictureList count]; i++)
    {
        UIImageView *tmp = (UIImageView*)[self viewWithTag:0x100+i];
        
        if (tmp) {
            [tmp removeFromSuperview];
            tmp = nil;
        }
    }
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
        
    for (int i = 0; i < [pictureList count]; i++) {
        
        CGRect rect;
        rect.origin.x = 10;
        rect.origin.y = originY;
        rect.size.width = clientRect.size.width-38;
        rect.size.height = rect.size.width;
        
        UIImageView *imageItem = [[UIImageView alloc] initWithFrame:rect];
        [parent addSubview:imageItem];
        
        imageItem.tag = 0x100+i;
        imageItem.userInteractionEnabled = YES;
        
        NSString *originalUrl = [pictureList objectAtIndex:i];
        NSString *ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"ratio"];
        
        __block SDPieLoopProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = imageItem;
        [imageItem sd_setImageWithURL:[NSURL URLWithString:ratioUrl]
                     placeholderImage:[UIImage imageNamed:@"morentupian1.png"]
                              options:SDWebImageProgressiveDownload
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
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImage:)];
        [imageItem addGestureRecognizer:singleTapGesture];
        
        originY += (rect.size.height+5);
    }
    
    return originY;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)onTapImage:(UITapGestureRecognizer*)gesture
{
    UIView *tmpView = [gesture view];
    
    if (tmpView != nil) {
        NSInteger index = tmpView.tag-0x100;
        if ([self.delegate respondsToSelector:@selector(onTapImage:index:)]) {
            [self.delegate onTapImage:_section index:index];
        }
    }
}

@end
