//
//  NewsTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/3/18.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "ProtoType.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface NewsTableViewCell()
-(int)layoutPicture:(int)originY pictures:(NSMutableArray*)pictureList;
-(void)initSubview:(NewsItem*)item;
-(void)onTapImage:(UITapGestureRecognizer*)gesture;

@property(nonatomic) UIImageView *logoView;
@property(nonatomic) UILabel *authorLabel;
@property(nonatomic) UILabel *contentLabel;
@property(nonatomic) UILabel *updateTimeLabel;
@property(nonatomic) UILabel *schoolLabel;
@end


@implementation NewsTableViewCell

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
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 50, 50)];
    [self.contentView addSubview:logoView];
    logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]];
    logoView.layer.masksToBounds = YES;
    logoView.layer.cornerRadius = 8;
    
    UILabel *authorLabel = [[UILabel alloc] init];
    [self.contentView addSubview:authorLabel];
    
    authorLabel.font = [UIFont systemFontOfSize:14];
    authorLabel.textColor = [UIColor colorWithRed:0.5922f green:0.8078f blue:0.4078f alpha:1.0f];
    authorLabel.text = @"...";
  
    CGFloat authorTextX = 12;
    CGFloat authorTextY = 70;
    CGFloat authorTextWidth = 50;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    [self.contentView addSubview:contentLabel];
    
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.numberOfLines = 0;
    
    CGFloat contentTextX = 80;
    CGFloat contentTextY = 15;
    CGFloat contentTextWidth = clientRect.size.width - 90;
    
    CGSize contentTextSize = [item.textContent boundingRectWithSize:CGSizeMake(contentTextWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    
    CGRect contentTextRect = CGRectMake(contentTextX, contentTextY, contentTextSize.width, contentTextSize.height);
    
    contentLabel.frame = contentTextRect;
    contentLabel.text = item.textContent;
    
    _height = [self layoutPicture:(contentTextRect.size.height+contentTextY+10) pictures:item.imageArray];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(12, _height+5, 13, 18)];
    [self.contentView addSubview:imageV];
    imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"weizhi2a@2x" ofType:@"png"]];
    
    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, _height+5, 140, 20)];
    [self.contentView addSubview:schoolLabel];
    
    schoolLabel.font = [UIFont systemFontOfSize:12];
    schoolLabel.textColor = [UIColor lightGrayColor];
    schoolLabel.textAlignment = NSTextAlignmentLeft;
    schoolLabel.text = @"正在检索...";
    
    UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width-150, _height+5, 140, 20)];
    [self.contentView addSubview:updateTimeLabel];
    
    updateTimeLabel.font = [UIFont systemFontOfSize:12];
    updateTimeLabel.textColor = [UIColor lightGrayColor];
    updateTimeLabel.text = [utilityFunction getTraditionalDate:item.updateTime complex:YES];
    updateTimeLabel.textAlignment = NSTextAlignmentRight;
    
    [[HttpService getInstance] queryAuthorInfo:item.authorId andBlock:^(CandidateItem *candidate) {
        
        if (candidate.nickName.length > 4)
        {
            authorLabel.numberOfLines = 0;
            CGSize authorTextSize = [candidate.nickName boundingRectWithSize:CGSizeMake(authorTextWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
            
            CGRect autthorTextRect = CGRectMake(authorTextX, authorTextY, authorTextSize.width, authorTextSize.height);
            authorLabel.frame = autthorTextRect;
        }
        else
        {
            authorLabel.frame = CGRectMake(authorTextX, authorTextY, authorTextWidth, 20);
            authorLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        authorLabel.text = candidate.nickName;
        schoolLabel.text = [NSString stringWithFormat:@"%@", candidate.organization];
        
        NSString *portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, candidate.portrait];
        
        __block SDTransparentPieProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = logoView;
        [logoView sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
                    placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]]
                             options:SDWebImageProgressiveDownload
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                if (!activityIndicator) {
                                    activityIndicator = [SDTransparentPieProgressView progressView];
                                    activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-40)/2, (weakImageView.frame.size.height-40)/2, 40, 40);
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
    }];
    
    _height += 30;
    
    if (_height < 115)
    {
        _height = 115;
        
        CGRect rect = contentLabel.frame;
        contentLabel.frame = CGRectMake(rect.origin.x, 40, rect.size.width, rect.size.height);
        rect = updateTimeLabel.frame;
        updateTimeLabel.frame = CGRectMake(rect.origin.x, _height-20, rect.size.width, rect.size.height);
        rect = imageV.frame;
        imageV.frame = CGRectMake(rect.origin.x, _height-20, rect.size.width, rect.size.height);
        rect = schoolLabel.frame;
        schoolLabel.frame = CGRectMake(rect.origin.x, _height-20, rect.size.width, rect.size.height);
    }
}

-(int)layoutPicture:(int)originY pictures:(NSMutableArray*)pictureList
{
    if ([pictureList count] == 0) {
        return originY;
    }
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    for (int i = 0; i < [pictureList count]; i++)
    {
        UIImageView *tmp = (UIImageView*)[self.contentView viewWithTag:0x100+i];
        
        if (tmp) {
            [tmp removeFromSuperview];
            tmp = nil;
        }
    }
    
    CGRect imgRect;
    int maxItemCountPerRow = 1, originX = 80;
    
    if ([pictureList count] == 1)
    {
        imgRect.size.width = clientRect.size.width-90;
        imgRect.size.height = imgRect.size.width;
    }
    else if([pictureList count] >= 2 && [pictureList count] <= 4)
    {
        imgRect.size.width = (clientRect.size.width-95)/2;
        imgRect.size.height = imgRect.size.width;
        maxItemCountPerRow = 2;
    }
    else
    {
        imgRect.size.width = (clientRect.size.width-100)/3;
        imgRect.size.height = imgRect.size.width;
        maxItemCountPerRow = 3;
    }
    
    for (int i = 0; i < [pictureList count]; i++) {
        
        if (i > 0 && (i%maxItemCountPerRow) == 0)
        {
            originY += imgRect.size.height + 5;
            originX = 80;
        }
        else
        {
            originX = 80 + (i%maxItemCountPerRow)*imgRect.size.width + (i%maxItemCountPerRow)*5;
        }
        
        CGRect rect = imgRect;
        rect.origin.x = originX;
        rect.origin.y = originY;
        
        UIImageView *imageItem = [[UIImageView alloc] initWithFrame:rect];
        [self.contentView addSubview:imageItem];
        
        imageItem.tag = 0x100+i;
        imageItem.userInteractionEnabled = YES;
        
        NSString *originalUrl = [pictureList objectAtIndex:i];
        NSString *ratioUrl = nil;
        
        if ([pictureList count] > 1) {
            ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"];
        }
        else
        {
            ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"ratio"];
        }
 
        __block SDPieLoopProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = imageItem;
        [imageItem sd_setImageWithURL:[NSURL URLWithString:ratioUrl]
                     placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"morentupian1@2x" ofType:@"png"]]
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
    }
    
    return (originY+imgRect.size.height+5);
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
            [self.delegate onTapImage:_row index:index];
        }
    }
}

@end
