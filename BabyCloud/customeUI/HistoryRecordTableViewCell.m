//
//  HistoryRecordTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/5/28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "HistoryRecordTableViewCell.h"
#import "ProtoType.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"
#import "HttpService.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSAttributedString+Attributes.h"
#import "ZBMessage.h"
#import "CustomMethod.h"
#import "OHAttributedLabel.h"
#import "MarkUpParser.h"
#import "ZBMessageBubbleFactory.h"

@implementation HistoryRecordTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier records:(NSMutableArray*)recordArray
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubview:recordArray identifer:reuseIdentifier];
        // Initialization code
    }
    return self;
}

- (void)initSubview:(NSMutableArray*)recordArray identifer:(NSString *)identifer
{
    NewsItem *firstItem = recordArray[0];
    
    UILabel *dayLable = [[UILabel alloc] init];
    dayLable.font = [UIFont boldSystemFontOfSize:25];
    
    UILabel *monthLable = [[UILabel alloc] init];
    monthLable.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:dayLable];
    [self.contentView addSubview:monthLable];
    
    NSMutableDictionary *dict = [utilityFunction getChineseDate:firstItem.updateTime complex:YES];
    NSString *dateTime = [dict objectForKey:@"dateTime"];
    NSString *day = [dict objectForKey:@"day"];
    NSString *month = [dict objectForKey:@"month"];
    
    CGRect dayLableRect, monthLableRect;
    
    if (dateTime.length == 2)
    {
        dayLableRect = CGRectMake(15, 8, 80, 25);
        monthLableRect = CGRectMake(95, 8, 0, 0);
        dayLable.text = dateTime;
        monthLable.text = @"";
    }
    else
    {
        dayLableRect = CGRectMake(15, 8, 40, 25);
        monthLableRect = CGRectMake(50, 16, 40, 15);
        dayLable.text = day;
        monthLable.text = month;
    }
    
    dayLable.frame = dayLableRect;
    monthLable.frame = monthLableRect;
    
    [self layoutSection:recordArray];
}

-(void)layoutSection:(NSMutableArray*)recordArray
{
    float originY = 10;
    int i = 0;
    
    for (NewsItem *item in recordArray) {
        
        UIView *pannelView = [[UIView alloc] init];
        [self.contentView addSubview:pannelView];
        pannelView.backgroundColor = [UIColor colorWithRed:0.8827f green:0.8827f blue:0.8827f alpha:1.0f];
        pannelView.userInteractionEnabled = YES;
        
        pannelView.tag = 0x200+i;
        i++;
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapView:)];
        [pannelView addGestureRecognizer:singleTapGesture];
        
        CGRect picRect = [self layoutPicture:pannelView originX:5 originY:5 pictures:item.imageArray];
        
        OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
        [pannelView addSubview:contentLabel];
        contentLabel.userInteractionEnabled = NO;
        
        if (item.textContent != nil && (item.textContent.length > 0))
        {
            contentLabel.text = item.textContent;
        }
        else
        {
            contentLabel.text = [NSString stringWithFormat:@"共有%d张图片", [item.imageArray count]];
        }
        
        [HistoryRecordTableViewCell creatAttributedLabel:contentLabel.text Label:contentLabel maxRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-picRect.size.width-115, picRect.size.height) fontSize:14];
        [CustomMethod drawImage:contentLabel];
        
        if (picRect.size.height == 0) {
            contentLabel.frame = CGRectMake(5, 5, CGRectGetWidth(contentLabel.frame), CGRectGetHeight(contentLabel.frame));
            pannelView.frame = CGRectMake(100, originY, [UIScreen mainScreen].bounds.size.width-105, CGRectGetHeight(contentLabel.frame)+10);
        }
        else
        {
            contentLabel.frame = CGRectMake(10+picRect.size.width, 5, [UIScreen mainScreen].bounds.size.width-picRect.size.width-115, CGRectGetHeight(contentLabel.frame));
          
            pannelView.frame = CGRectMake(100, originY, [UIScreen mainScreen].bounds.size.width-105, CGRectGetHeight(picRect)+2);
        }
    
        originY += (CGRectGetHeight(pannelView.frame)+3);
    }
}

-(CGRect)layoutPicture:(UIView*)parent originX:(float)originX  originY:(float)originY pictures:(NSMutableArray*)pictureList
{
    if ([pictureList count] == 0) {
        return CGRectMake(originX, originY, 0, 0);
    }
    
    for (int i = 0; i < [pictureList count]; i++)
    {
        UIImageView *tmp = (UIImageView*)[parent viewWithTag:0x100+i];
        
        if (tmp) {
            [tmp removeFromSuperview];
            tmp = nil;
        }
    }
    
    CGRect imgRect;
    int maxItemCountPerRow = 1;
    
    if ([pictureList count] == 1)
    {
        imgRect.size.width = 100;
        imgRect.size.height = 100;
    }
    else
    {
        imgRect.size.width = 50;
        imgRect.size.height = 50;
        maxItemCountPerRow = 2;
    }
    
    for (int i = 0; i < [pictureList count]; i++) {
        
        if (i > 0 && (i%maxItemCountPerRow) == 0)
        {
            originY += imgRect.size.height + 3;
            originX = 5;
        }
        else
        {
            originX = 5 + (i%maxItemCountPerRow)*imgRect.size.width + (i%maxItemCountPerRow)*3;
        }
        
        CGRect rect = imgRect;
        rect.origin.x = originX;
        rect.origin.y = originY;
        
        UIImageView *imageItem = [[UIImageView alloc] initWithFrame:rect];
        [parent addSubview:imageItem];
        
        imageItem.userInteractionEnabled = NO;
        imageItem.tag = 0x100+i;
        
        NSString *originalUrl = [pictureList objectAtIndex:i];
        NSString *ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"];
        
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
    }
    
    int picWidth;
    
    if ([pictureList count] == 1)
    {
        picWidth = 100;
    }
    else
    {
        picWidth = 103;
    }
    
    return CGRectMake(originX, originY, picWidth, originY+imgRect.size.height+3);
}

+(void)creatAttributedLabel:(NSString *)text Label:(OHAttributedLabel *)label maxRect:(CGRect)maxRect fontSize:(float)size{
    
    [label setNeedsDisplay];
    
    NSMutableArray *httpArr = [CustomMethod addHttpArr:text];
    NSMutableArray *phoneNumArr = [CustomMethod addPhoneNumArr:text];
    NSMutableArray *emailArr = [CustomMethod addEmailArr:text];
    
    NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *expressionDic   = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
    
    NSString *o_text = [CustomMethod transformString:text emojiDic:expressionDic];
    o_text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",o_text];
    
    MarkUpParser *wk_markupParser = [[MarkUpParser alloc] init];
    NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkUp:o_text];
    [attString setFont:[UIFont systemFontOfSize:size]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAttString:attString withImages:wk_markupParser.images];
    
    NSString *string = attString.string;
    
    if ([emailArr count])
    {
        for (NSString *emailStr in emailArr)
        {
            [label addCustomLink:[NSURL URLWithString:emailStr] inRange:[string rangeOfString:emailStr]];
        }
    }
    
    if ([phoneNumArr count])
    {
        for (NSString *phoneNum in phoneNumArr)
        {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    if ([httpArr count])
    {
        for (NSString *httpStr in httpArr)
        {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }
    
    CGRect labelRect = label.frame;
    
    if (maxRect.size.height == 0) {
        maxRect.size.height = 50;
    }
    
    labelRect.size.width = [label sizeThatFits:CGSizeMake(maxRect.size.width, maxRect.size.height)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(maxRect.size.width, maxRect.size.height)].height;
    
    label.frame = labelRect;
    label.underlineLinks = NO;
    [label.layer display];
}

+(float)calculateCellHeight:(NSMutableArray*)recordArray
{
    int maxItemCountPerRow = 1;
    float originY = 10;
    
    for (NewsItem *item in recordArray) {
        
        if (item.imageArray.count > 0) {
            
            CGRect imgRect;
            
            if ([item.imageArray count] == 1)
            {
                imgRect.size.width = 100;
                imgRect.size.height = 100;
            }
            else
            {
                imgRect.size.width = 50;
                imgRect.size.height = 50;
                maxItemCountPerRow = 2;
            }
            
            for (int i = 0; i < item.imageArray.count; i++) {
                
                if (i > 0 && (i%maxItemCountPerRow) == 0)
                {
                    originY += imgRect.size.height + 3;
                }
            }
            
            originY += imgRect.size.height+15;
        }
        else
        {
            OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
            [HistoryRecordTableViewCell creatAttributedLabel:item.textContent Label:contentLabel maxRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-115, 0) fontSize:14];
            
            originY += (CGRectGetHeight(contentLabel.frame)+15);
        }
    }
    
    return originY+3;
}

- (void)onTapView:(UITapGestureRecognizer*)gesture
{
    UIView *tmpView = [gesture view];
    
    if (tmpView != nil) {
        NSInteger index = tmpView.tag-0x200;
        if ([self.delegate respondsToSelector:@selector(onTapSection:index:)]) {
            [self.delegate onTapSection:_row index:index];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
