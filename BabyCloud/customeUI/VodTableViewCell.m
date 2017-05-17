//
//  VodTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/9/15.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "VodTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"
#import "ProtoType.h"

@interface VodTableViewCell()
@property(nonatomic) UIImageView *coverView;
@property(nonatomic) UILabel *sumLabel;
@property(nonatomic) UILabel *describLabel;
@property(nonatomic) UILabel *stateLabel;
@end

@implementation VodTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mediaItem:(MediaItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubview:item identifer:reuseIdentifier];
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initSubview:(MediaItem*)item identifer:(NSString *)identifer
{
    
    self.backgroundColor = [UIColor clearColor];
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    UIImageView* frameBorderV = [[UIImageView alloc] initWithFrame:CGRectMake(6, 3, clientRect.size.width/2+10, clientRect.size.width/3+8)];
    [self.contentView addSubview:frameBorderV];
    
    if (item.totalCount > 1) {
        frameBorderV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blankBorder@2x" ofType:@"png"]];
    }
    
    // Initialization code
    self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, clientRect.size.width/2, clientRect.size.width/3)];
    [self.contentView addSubview:self.coverView];
        
    __block SDTransparentPieProgressView *activityIndicator = nil;
    __weak UIImageView *weakImageView = self.coverView;
    [self.coverView sd_setImageWithURL:[NSURL URLWithString:item.pic]
                      placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultVod@2x" ofType:@"png"]]
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

    
    UIView *pannel = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.coverView.frame)-20, CGRectGetWidth(self.coverView.frame), 20)];
    [self.coverView addSubview:pannel];
    
    pannel.backgroundColor =  [UIColor colorWithWhite:0 alpha:0.6];
    
    self.sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, CGRectGetWidth(pannel.frame)-5, 16)];
    [pannel addSubview:self.sumLabel];
    
    self.sumLabel.font = [UIFont systemFontOfSize:14];
    self.sumLabel.textColor = [UIColor whiteColor];
    self.sumLabel.textAlignment = NSTextAlignmentRight;
    self.sumLabel.text = [NSString stringWithFormat:@"更新至第%d集", item.totalCount];
    
    self.describLabel = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2+18, 12, clientRect.size.width/2-22, 20)];
    [self.contentView addSubview:self.describLabel];
    
    self.describLabel.font = [UIFont boldSystemFontOfSize:18];
    self.describLabel.text =item.name;
    
    self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2+18, 32, clientRect.size.width/2-22, 20)];
    [self.contentView addSubview:self.stateLabel];
    
    self.stateLabel.font = [UIFont systemFontOfSize:12];
    self.stateLabel.textColor = [UIColor lightGrayColor];
    self.stateLabel.text = [NSString stringWithFormat:@"播放 %d次", item.playCount];
    
    UIImageView *horiz = [[UIImageView alloc]initWithFrame:CGRectMake(10, clientRect.size.width/3+20, CGRectGetWidth(clientRect)-20, 0.5)];
    [self.contentView addSubview:horiz];
    
    UIGraphicsBeginImageContext(horiz.frame.size);
    [horiz.image drawInRect:CGRectMake(0, 0, horiz.frame.size.width, horiz.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    const CGFloat lengths[] = {2,2};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor blackColor].CGColor);
    
    CGContextSetLineDash(line, 0, lengths, 2);
    CGContextMoveToPoint(line, 0, 0);
    CGContextAddLineToPoint(line, CGRectGetWidth(horiz.frame), 0);
    CGContextStrokePath(line);
    
    horiz.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

@end
