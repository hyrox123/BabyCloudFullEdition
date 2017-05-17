//  NTStatusTableViewCell.m
//  TableView
//
//  Created by MD101 on 14-10-10.
//  Copyright (c) 2014年 NT. All rights reserved.
//

#import "NTStatusTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"
#import "ProtoType.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"

@interface NTStatusTableViewCell()
@property(nonatomic) NSString *shuttleId;
-(void)initSubview:(ShuttleItem*)item;
@end

@implementation NTStatusTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier shuttleItem:(ShuttleItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubview:item];
        // Initialization code
    }
    return self;
}

- (void)initSubview:(ShuttleItem*)item
{
    _shuttleId = item.shuttleId;
    
    UILabel *dayLable = [[UILabel alloc] init];
    dayLable.font = [UIFont boldSystemFontOfSize:25];
    
    UILabel *monthLable = [[UILabel alloc] init];
    monthLable.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:dayLable];
    [self.contentView addSubview:monthLable];
    
    NSMutableDictionary *dict = [utilityFunction getChineseDate:item.updateTime complex:YES];
    NSString *dateTime = [dict objectForKey:@"dateTime"];
    NSString *day = [dict objectForKey:@"day"];
    NSString *month = [dict objectForKey:@"month"];
    
    CGRect dayLableRect, monthLableRect;
    
    if (dateTime.length == 2)
    {
        dayLableRect = CGRectMake(10, 10, 80, 25);
        monthLableRect = CGRectMake(90, 10, 0, 0);
        dayLable.text = dateTime;
        monthLable.text = @"";
    }
    else
    {
        dayLableRect = CGRectMake(10, 10, 40, 25);
        monthLableRect = CGRectMake(45, 18, 40, 15);
        dayLable.text = day;
        monthLable.text = month;
    }
    
    dayLable.frame = dayLableRect;
    monthLable.frame = monthLableRect;
    
    int itemHeight = 10;
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    for (int i = 0; i < [item.recordArray count]; i++) {
        
        UILabel *textContent = [[UILabel alloc]init];
        textContent.font = [UIFont boldSystemFontOfSize:12];
        textContent.textColor = [UIColor blackColor];
        textContent.numberOfLines = 0;
        [self.contentView addSubview:textContent];
        
        CGFloat textX = 90;
        CGRect imgRect = CGRectZero;
        
        if ([item.imageArray count] > i) {
            
            CGSize pictureSize = [utilityFunction downloadImageSizeWithURL:item.imageArray[i]];
            
            if(CGSizeEqualToSize(CGSizeZero, pictureSize))
            {
                imgRect.size.width = 120;
                imgRect.size.height = 100;
            }
            else
            {
                if(pictureSize.width > (clientRect.size.width-150))
                {
                    imgRect.size.width = clientRect.size.width-150;
                    imgRect.size.height = (pictureSize.height/pictureSize.width)*imgRect.size.width;
                }
                else
                {
                    imgRect.size.width = pictureSize.width;
                    imgRect.size.height = pictureSize.height;
                }
            }
            
            UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(textX, itemHeight, imgRect.size.width, imgRect.size.height)];
            [self.contentView addSubview:imageV];
            
            __block SDTransparentPieProgressView *activityIndicator = nil;
            __weak UIImageView *weakImageView = imageV;
            [imageV sd_setImageWithURL:[NSURL URLWithString:item.imageArray[i]]
                      placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"morentupian1@2x" ofType:@"png"]]
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
            
            itemHeight += (imgRect.size.height+15);
            imgRect.size.height += 13;
        }
        
        CGSize textSize = [[item.recordArray objectAtIndex:i] boundingRectWithSize:CGSizeMake(clientRect.size.width-textX-5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} context:nil].size;
        
        CGRect textRect = CGRectMake(textX, itemHeight, textSize.width, textSize.height);
        
        textContent.frame = textRect;
        textContent.text = [item.recordArray objectAtIndex:i];
        
        itemHeight += textSize.height + 10;
        
        [self addSubview: textContent];
    }
}

+(float)calculateCellHeight:(ShuttleItem*)item
{
    float originY = 15;
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    for (int i = 0; i < [item.recordArray count]; i++) {
        
        if ([item.imageArray count] > i) {
            
            CGSize pictureSize = [utilityFunction downloadImageSizeWithURL:item.imageArray[i]];
            CGRect imgRect;
            
            if(CGSizeEqualToSize(CGSizeZero, pictureSize))
            {
                imgRect.size.width = 120;
                imgRect.size.height = 100;
            }
            else
            {
                if(pictureSize.width > (clientRect.size.width-150))
                {
                    imgRect.size.width = clientRect.size.width-150;
                    imgRect.size.height = (pictureSize.height/pictureSize.width)*imgRect.size.width;
                }
                else
                {
                    imgRect.size.width = pictureSize.width;
                    imgRect.size.height = pictureSize.height;
                }
            }
            
            originY += (imgRect.size.height+15);
        }
        
        CGSize textSize = [[item.recordArray objectAtIndex:i] boundingRectWithSize:CGSizeMake(clientRect.size.width-95, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} context:nil].size;
        
        originY += (textSize.height+10);
    }
    
    if (originY < 30) {
        originY = 30;
    }
    
    return  originY;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
