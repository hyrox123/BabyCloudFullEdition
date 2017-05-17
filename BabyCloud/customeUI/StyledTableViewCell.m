//
//  StyledTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/5/6.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "StyledTableViewCell.h"
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

@interface StyledTableViewCell()
-(float)layoutPicture:(UIView*)parent originY:(float)originY pictures:(NSMutableArray*)pictureList;
-(void)initSubview:(NewsItem*)item identifer:(NSString*)identifer;
-(void)onTapImage:(UITapGestureRecognizer*)gesture;
-(void)onTapDelete:(UITapGestureRecognizer*)gesture;
-(void)onTapReport:(UITapGestureRecognizer *)gesture;
-(void)onTapComment:(UITapGestureRecognizer *)gesture;
-(void)onTapPraise:(UITapGestureRecognizer *)gesture;
+(float)creatAttributedLabel:(NSString *)text Label:(OHAttributedLabel *)label fontSize:(float)size;

@property(nonatomic) NSString *authorId, *schoolId, *newsId, *authorName, *portrait;
@end

@implementation StyledTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubview:item identifer:reuseIdentifier];
        // Initialization code
    }
    return self;
}

- (void)initSubview:(NewsItem*)item identifer:(NSString *)identifer
{
    _authorId = item.authorId;
    _newsId = item.newsId;
    _authorName = item.authorName;
    _portrait = item.authorPortrait;
    
    self.backgroundColor = [UIColor clearColor];
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    UIView *pannelView = [[UIView alloc] init];
    [self.contentView addSubview:pannelView];
    
    pannelView.userInteractionEnabled = YES;
    UITapGestureRecognizer *blankTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlank:)];
    [pannelView addGestureRecognizer:blankTapGesture];
    
    pannelView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
    [pannelView addSubview:logoView];
    
    logoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAutor:)];
    [logoView addGestureRecognizer:singleTapGesture0];
    
    logoView.layer.masksToBounds = YES;
    logoView.layer.cornerRadius = 8;
    
    if (item.authorPortrait != nil && item.authorPortrait.length > 0) {
        
        NSString *portraitUrl = [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, item.authorPortrait];
        
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
        
    }
    else
    {
        logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]];
    }
    
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 12, 150, 15)];
    [pannelView addSubview:authorLabel];
    
    authorLabel.font = [UIFont boldSystemFontOfSize:16];
    authorLabel.textColor = [UIColor colorWithRed:0.5922f green:0.8078f blue:0.4078f alpha:1.0f];
    authorLabel.text = item.authorName;
    
    authorLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAutor:)];
    [authorLabel addGestureRecognizer:singleTapGesture1];
    
    UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 37, 60, 15)];
    [pannelView addSubview:updateTimeLabel];
    
    updateTimeLabel.font = [UIFont systemFontOfSize:12];
    updateTimeLabel.textColor = [UIColor lightGrayColor];
    updateTimeLabel.text = [utilityFunction getTraditionalDate:item.updateTime complex:YES];
    
    CGSize customerTmpStringTextSize = [item.organization boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} context:nil].size;
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(clientRect.size.width-customerTmpStringTextSize.width-27, 14, 16, 16)];
    [pannelView addSubview:imageV];
    
    imageV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"youeryuan@2x" ofType:@"png"]];
    
    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width-customerTmpStringTextSize.width-8, 15, 80, 15)];
    [pannelView addSubview:schoolLabel];
    
    schoolLabel.font = [UIFont systemFontOfSize:11];
    schoolLabel.textColor = [UIColor lightGrayColor];
    schoolLabel.textAlignment = NSTextAlignmentLeft;
    schoolLabel.text = item.organization;
    
#if 0
    schoolLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapSchool:)];
    [schoolLabel addGestureRecognizer:singleTapGesture2];
#endif
    
    float itemHeight = [self layoutPicture:pannelView originY:68 pictures:item.imageArray];
    
    OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
    [pannelView addSubview:contentLabel];
    
    if (item.textContent != nil && (item.textContent.length > 0))
    {
        contentLabel.text = item.textContent;
        
        [StyledTableViewCell creatAttributedLabel:contentLabel.text Label:contentLabel fontSize:16];
        [CustomMethod drawImage:contentLabel];
        
        contentLabel.frame = CGRectMake(60,itemHeight,CGRectGetWidth(contentLabel.frame),CGRectGetHeight(contentLabel.frame));
    }
    else
    {
        contentLabel.text = @"";
        contentLabel.frame = CGRectMake(60, itemHeight, 0, 0);
    }
    
    if (contentLabel.frame.size.height > 0) {
        itemHeight += 5;
    }
    
    itemHeight += contentLabel.frame.size.height;
    
    UIImageView *commentLogo = [[UIImageView alloc] initWithFrame:CGRectMake(60, itemHeight+13, 15, 15)];
    [pannelView addSubview:commentLogo];
    
    commentLogo.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pinglun@2x" ofType:@"png"]];
    commentLogo.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapComment:)];
    [commentLogo addGestureRecognizer:singleTapGesture3];
    
    UILabel *commnetLable = [[UILabel alloc] initWithFrame:CGRectMake(80, itemHeight+13, 50, 15)];
    [pannelView addSubview:commnetLable];
    
    commnetLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapComment:)];
    [commnetLable addGestureRecognizer:singleTapGesture4];
    
    commnetLable.font = [UIFont systemFontOfSize:12];
    commnetLable.textColor = [UIColor lightGrayColor];
    commnetLable.textAlignment = NSTextAlignmentLeft;
    commnetLable.text = [NSString stringWithFormat:@"评论(%lu)", (unsigned long)[item.commentArray count]];
    
    UILabel *segLable1 = [[UILabel alloc] initWithFrame:CGRectMake(130, itemHeight+13, 20, 15)];
    [pannelView addSubview:segLable1];
    
    segLable1.text = @"|";
    segLable1.textColor = [UIColor lightGrayColor];
    
    UIImageView *praiseLogo = [[UIImageView alloc] initWithFrame:CGRectMake(145, itemHeight+13, 15, 15)];
    [pannelView addSubview:praiseLogo];
    
    praiseLogo.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zan@2x" ofType:@"png"]];
    praiseLogo.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTapGesture5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPraise:)];
    [praiseLogo addGestureRecognizer:singleTapGesture5];
    
    UILabel *praiseLable = [[UILabel alloc] initWithFrame:CGRectMake(165, itemHeight+13, 50, 15)];
    [pannelView addSubview:praiseLable];
    
    praiseLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPraise:)];
    [praiseLable addGestureRecognizer:singleTapGesture6];
    
    praiseLable.font = [UIFont systemFontOfSize:12];
    praiseLable.textColor = [UIColor lightGrayColor];
    praiseLable.textAlignment = NSTextAlignmentLeft;
    
    if (item.supportNumber == nil) {
        item.supportNumber = @"0";
    }
    
    praiseLable.text = [NSString stringWithFormat:@"送花(%@)", item.supportNumber];
    pannelView.frame = CGRectMake(0, 0, clientRect.size.width, itemHeight+30);
    
    
    if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
    {
        UILabel *segLable2 = [[UILabel alloc] initWithFrame:CGRectMake(220, itemHeight+13, 20, 15)];
        [pannelView addSubview:segLable2];
        
        segLable2.text = @"|";
        segLable2.textColor = [UIColor lightGrayColor];
        
        UIImageView *deleteLogo = [[UIImageView alloc] initWithFrame:CGRectMake(235, itemHeight+13, 15, 15)];
        [pannelView addSubview:deleteLogo];
        
        deleteLogo.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dustbin_down@2x" ofType:@"png"]];
        deleteLogo.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTapGesture5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapDelete:)];
        [deleteLogo addGestureRecognizer:singleTapGesture5];
        
        UILabel *deleteLable = [[UILabel alloc] initWithFrame:CGRectMake(255, itemHeight+13, 50, 15)];
        [pannelView addSubview:deleteLable];
        
        deleteLable.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapGesture6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapDelete:)];
        [deleteLable addGestureRecognizer:singleTapGesture6];
        
        deleteLable.font = [UIFont systemFontOfSize:12];
        deleteLable.textColor = [UIColor lightGrayColor];
        deleteLable.textAlignment = NSTextAlignmentLeft;
        deleteLable.text = @"删除";
    }
    
    [self layoutComment:self originY:itemHeight+35 comments:item.commentArray];
}

-(float)layoutPicture:(UIView*)parent originY:(float)originY pictures:(NSMutableArray*)pictureList
{
    if ([pictureList count] == 0) {
        return originY;
    }
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    for (int i = 0; i < [pictureList count]; i++)
    {
        UIImageView *tmp = (UIImageView*)[parent viewWithTag:0x100+i];
        
        if (tmp) {
            [tmp removeFromSuperview];
            tmp = nil;
        }
    }
    
    CGRect imgRect;
    int maxItemCountPerRow = 1, originX = 60;
    
    if ([pictureList count] == 1)
    {
        NSString *originalUrl = [pictureList objectAtIndex:0];
        NSString *ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"ratio"];
        CGSize picSize = [utilityFunction downloadImageSizeWithURL:ratioUrl];
        
        if(CGSizeEqualToSize(CGSizeZero, picSize))
        {
            imgRect.size.width = clientRect.size.width-70;
            imgRect.size.height = imgRect.size.width;
        }
        else
        {
            if(picSize.width > (clientRect.size.width-70))
            {
                imgRect.size.width = clientRect.size.width-70;
                imgRect.size.height = (picSize.height/picSize.width)*(imgRect.size.width-70);
            }
            else
            {
                originX = (clientRect.size.width-picSize.width)/2;
                imgRect.size.width = picSize.width;
                imgRect.size.height = picSize.height;
            }
        }
        
        CGRect rect = imgRect;
        rect.origin.x = originX;
        rect.origin.y = originY;
        
        UIImageView *imageItem = [[UIImageView alloc] initWithFrame:rect];
        [parent addSubview:imageItem];
        
        imageItem.tag = 0x100;
        imageItem.userInteractionEnabled = YES;
        
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
    else
    {
        maxItemCountPerRow = 2;
        imgRect.size.width = (clientRect.size.width-100)/2;
        imgRect.size.height = imgRect.size.width;
        
        for (int i = 0; i < [pictureList count]; i++) {
            
            if (i > 0 && (i%maxItemCountPerRow) == 0)
            {
                originY += imgRect.size.height + 5;
                originX = 60;
            }
            else
            {
                originX = 60 + (i%maxItemCountPerRow)*imgRect.size.width + (i%maxItemCountPerRow)*5;
            }
            
            CGRect rect = imgRect;
            rect.origin.x = originX;
            rect.origin.y = originY;
            
            UIImageView *imageItem = [[UIImageView alloc] initWithFrame:rect];
            [parent addSubview:imageItem];
            
            imageItem.tag = 0x100+i;
            imageItem.userInteractionEnabled = YES;
            
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
            
            UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImage:)];
            [imageItem addGestureRecognizer:singleTapGesture];
        }
    }
    
    return (originY+imgRect.size.height+8);
}

+ (NSString*)combinCommnet:(NSMutableArray*)commentsList
{
    if (commentsList.count == 0) {
        return nil;
    }
    
    NSString *comments = @"";
    
    for (commentItem * item in commentsList) {
        comments = [comments stringByAppendingString:[NSString stringWithFormat:@" %@:%@\n", item.authorName, item.content]];
    }
    
    return comments;
}

- (float)layoutComment:(UIView*)parent originY:(float)originY comments:(NSMutableArray*)commentsList
{
    NSString *comments = [StyledTableViewCell combinCommnet:commentsList];
    
    if (comments == nil) {
        return 0;
    }
    
    OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
    [StyledTableViewCell creatCommentLabel:comments Label:contentLabel fontSize:13];
    [CustomMethod drawImage:contentLabel];
    
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pinglun_bg@2x" ofType:@"png"]];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:16 topCapHeight:5]];
    
    bubbleImageView.frame = CGRectMake(60, originY, [UIScreen mainScreen].bounds.size.width-80, CGRectGetHeight(contentLabel.frame)+15);
    
    contentLabel.frame = CGRectMake(5, 10, CGRectGetWidth(contentLabel.frame), CGRectGetHeight(contentLabel.frame));
    
    [bubbleImageView addSubview:contentLabel];
    [parent addSubview:bubbleImageView];
    
    return CGRectGetHeight(bubbleImageView.frame);
}

+(float)creatAttributedLabel:(NSString *)text Label:(OHAttributedLabel *)label fontSize:(float)size{
    
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
    labelRect.size.width = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-80, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-80, CGFLOAT_MAX)].height;
    
    label.frame = labelRect;
    label.underlineLinks = NO;
    [label.layer display];
    
    return  CGRectGetHeight(label.frame);
}

+(float)creatCommentLabel:(NSString *)text Label:(OHAttributedLabel *)label fontSize:(float)size{
    
    [label setNeedsDisplay];
    
    NSMutableArray *httpArr = [CustomMethod addHttpArr:text];
    NSMutableArray *phoneNumArr = [CustomMethod addPhoneNumArr:text];
    NSMutableArray *emailArr = [CustomMethod addEmailArr:text];
    NSMutableArray *authorArr = [CustomMethod addAutor:text];
    
    NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *expressionDic = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
    
    NSString *o_text = [CustomMethod transformString:text emojiDic:expressionDic];
    o_text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",o_text];
    
    MarkUpParser *wk_markupParser = [[MarkUpParser alloc] init];
    NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkUp:o_text];
    [attString setFont:[UIFont systemFontOfSize:size]];
    [label setBackgroundColor:[UIColor clearColor]];
    
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
    
    if ([authorArr count]) {
        
        for (NSString *autorStr in authorArr) {
            
            NSMutableString *tmpString = [[NSMutableString alloc] initWithString:string];
            NSMutableArray *sameStringArray = [NSMutableArray new];
            
            while (1) {
                
                NSRange possbileRange = [tmpString rangeOfString:autorStr];
                
                if (possbileRange.length > 0) {
                    
                    [sameStringArray addObject:[NSValue value:&possbileRange withObjCType:@encode(NSRange)]];
                    tmpString = (NSMutableString*)[tmpString stringByReplacingCharactersInRange:possbileRange withString:@""];
                    
                    for (int i = 0; i < possbileRange.length; i++) {
                        [tmpString insertString:@"*" atIndex:possbileRange.location];
                    }
                }
                else
                {
                    break;
                }
            }
            
            for (int i = 0; i < sameStringArray.count; i++) {
                NSRange possibleRange;
                [[sameStringArray objectAtIndex:i] getValue:&possibleRange];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.2941f green:0.3490f blue:0.4902f alpha:1.0f] range:possibleRange];
                [attString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:possibleRange];
            }
        }
    }
    
    [label setAttString:attString withImages:wk_markupParser.images];
    
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-80, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-80, CGFLOAT_MAX)].height;
    
    label.frame = labelRect;
    
    label.underlineLinks = NO;
    [label.layer display];
    
    return  CGRectGetHeight(label.frame);
}


- (void)onTapImage:(UITapGestureRecognizer*)gesture
{
    UIView *tmpView = [gesture view];
    
    if (tmpView != nil) {
        NSInteger index = tmpView.tag-0x100;
        if ([self.delegate respondsToSelector:@selector(onTapImage:index:)]) {
            [self.delegate onTapImage:_newsId index:index];
        }
    }
}

-(void)onTapAutor:(UITapGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapAutor:authorName:portriat:)]) {
        [self.delegate onTapAutor:_authorId authorName:_authorName portriat:_portrait];
    }
}

-(void)onTapDelete:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapDelete:)]) {
        [self.delegate onTapDelete:_newsId];
    }
}

-(void)onTapSchool
{
    
}

-(void)onTapReport:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapReport:)]) {
        [self.delegate onTapReport:_newsId];
    }
}

-(void)onTapComment:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapComment:)]) {
        [self.delegate onTapComment:_newsId];
    }
}

-(void)onTapPraise:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapPraise:authorId:)]) {
        [self.delegate onTapPraise:_newsId authorId:_authorId];
    }
}

-(void)onTapBlank:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapBlank)]) {
        [self.delegate onTapBlank];
    }
}

+(float)calculateCellHeight:(NewsItem*)item
{
    int maxItemCountPerRow = 1;
    float originY = 68;
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    
    if (item.imageArray.count > 0) {
        
        CGRect imgRect;
        
        if ([item.imageArray count] == 1)
        {
            NSString *originalUrl = [item.imageArray objectAtIndex:0];
            NSString *ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"ratio"];
            CGSize picSize = [utilityFunction downloadImageSizeWithURL:ratioUrl];
            
            if(CGSizeEqualToSize(CGSizeZero, picSize))
            {
                imgRect.size.width = clientRect.size.width-70;
                imgRect.size.height = imgRect.size.width;
            }
            else
            {
                if(picSize.width > (clientRect.size.width-70))
                {
                    imgRect.size.width = clientRect.size.width-70;
                    imgRect.size.height = (picSize.height/picSize.width)*(imgRect.size.width-70);
                }
                else
                {
                    imgRect.size.width = picSize.width;
                    imgRect.size.height = picSize.height;
                }
            }
        }
        else
        {
            maxItemCountPerRow = 2;
            imgRect.size.width = (clientRect.size.width-100)/2;
            imgRect.size.height = imgRect.size.width;
        }
        
        for (int i = 0; i < item.imageArray.count; i++) {
            
            if (i > 0 && (i%maxItemCountPerRow) == 0)
            {
                originY += imgRect.size.height + 5;
            }
        }
        
        originY += imgRect.size.height+8;
    }
    
    float txtHeight = 0;
    
    if(item.textContent != nil && (item.textContent.length > 0))
    {
        OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
        txtHeight = [StyledTableViewCell creatAttributedLabel:item.textContent Label:contentLabel fontSize:16] + 5;
    }
    
    NSString *comments = [StyledTableViewCell combinCommnet:item.commentArray];
    
    if (comments != nil) {
        OHAttributedLabel *commentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
        int commentTxtHeight = [StyledTableViewCell creatCommentLabel:comments Label:commentLabel fontSize:13];
        txtHeight += (commentTxtHeight+10);
    }
    
    return (originY+txtHeight+45);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
