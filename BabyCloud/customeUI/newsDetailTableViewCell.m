//
//  newsDetailTableViewCell.m
//  BabyCloud
//
//  Created by apple on 15/7/28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "newsDetailTableViewCell.h"
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


@interface newsDetailTableViewCell()
-(float)layoutPicture:(UIView*)parent originY:(float)originY pictures:(NSMutableArray*)pictureList;
-(void)initSubview:(NewsItem*)item identifer:(NSString*)identifer;
-(void)onTapImage:(UITapGestureRecognizer*)gesture;

@property(nonatomic) NSString *authorId, *schoolId, *newsId, *authorName, *portrait;

@end

@implementation newsDetailTableViewCell

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
    pannelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pannelView.layer.borderWidth = 0.5;
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
    [pannelView addSubview:logoView];
    
    logoView.layer.cornerRadius = 8;
    logoView.layer.masksToBounds = YES;
    logoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAutor:)];
    [logoView addGestureRecognizer:singleTapGesture0];

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
    
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 10, 150, 15)];
    [pannelView addSubview:authorLabel];
    
    authorLabel.font = [UIFont boldSystemFontOfSize:16];
    authorLabel.textColor = [UIColor colorWithRed:0.5922f green:0.8078f blue:0.4078f alpha:1.0f];
    authorLabel.text = item.authorName;
    
    authorLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAutor:)];
    [authorLabel addGestureRecognizer:singleTapGesture1];

    UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 35, 60, 15)];
    [pannelView addSubview:updateTimeLabel];
    
    updateTimeLabel.font = [UIFont systemFontOfSize:13];
    updateTimeLabel.textColor = [UIColor lightGrayColor];
    updateTimeLabel.text = [utilityFunction getTraditionalDate:item.updateTime complex:YES];
    updateTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
    {
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pannelView addSubview:replyBtn];
        
        replyBtn.frame = CGRectMake(clientRect.size.width-36, 8, 30, 20);
        replyBtn.showsTouchWhenHighlighted = YES;
        replyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        replyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        replyBtn.backgroundColor = [UIColor clearColor];
        [replyBtn setTitleColor:[UIColor colorWithRed:0.121f green:0.376f blue:1.0f alpha:1] forState:UIControlStateNormal];
        [replyBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [replyBtn setTitle:@"回复" forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(onBtnReply) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pannelView addSubview:shareBtn];
        
        shareBtn.frame = CGRectMake(clientRect.size.width-80, 8, 30, 20);
        shareBtn.showsTouchWhenHighlighted = YES;
        shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        shareBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        shareBtn.backgroundColor = [UIColor clearColor];
        [shareBtn setTitleColor:[UIColor colorWithRed:0.121f green:0.376f blue:1.0f alpha:1] forState:UIControlStateNormal];
        [shareBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(onBtnShare) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *segLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width-45, 8, 5, 20)];
        [pannelView addSubview:segLable];
        segLable.text = @"|";
        segLable.textColor = [UIColor colorWithRed:0.121f green:0.376f blue:1.0f alpha:1];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pannelView addSubview:deleteBtn];
        
        deleteBtn.frame = CGRectMake(clientRect.size.width-36, 8, 30, 20);
        deleteBtn.showsTouchWhenHighlighted = YES;
        deleteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        deleteBtn.backgroundColor = [UIColor clearColor];
        [deleteBtn setTitleColor:[UIColor colorWithRed:0.121f green:0.376f blue:1.0f alpha:1] forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(onBtnDelete) forControlEvents:UIControlEventTouchUpInside];
    }
    
    float itemHeight = [self layoutPicture:pannelView originY:68 pictures:item.imageArray];
    
    OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
    [pannelView addSubview:contentLabel];
    
    if (item.textContent != nil && (item.textContent.length > 0))
    {
        contentLabel.text = item.textContent;
        
        [newsDetailTableViewCell creatAttributedLabel:contentLabel.text Label:contentLabel fontSize:14];
        [CustomMethod drawImage:contentLabel];
        
        contentLabel.frame = CGRectMake(10,itemHeight,CGRectGetWidth(contentLabel.frame),CGRectGetHeight(contentLabel.frame));
        itemHeight += contentLabel.frame.size.height+10;
    }
    else
    {
        contentLabel.text = @"";
        contentLabel.frame = CGRectZero;
    }
    
#if 1
    itemHeight += [self layoutComment:self originY:itemHeight comments:item.commentArray];
#endif
    
    pannelView.frame = CGRectMake(0, 0, clientRect.size.width, itemHeight);
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
    int maxItemCountPerRow = 1, originX = 10;
    
    if ([pictureList count] == 1)
    {
        NSString *originalUrl = [pictureList objectAtIndex:0];
        NSString *ratioUrl = [originalUrl stringByReplacingOccurrencesOfString:@"original" withString:@"ratio"];
        CGSize picSize = [utilityFunction downloadImageSizeWithURL:ratioUrl];
        
        if(CGSizeEqualToSize(CGSizeZero, picSize))
        {
            imgRect.size.width = clientRect.size.width-20;
            imgRect.size.height = imgRect.size.width-20;
        }
        else
        {
            if(picSize.width > (clientRect.size.width-20))
            {
                imgRect.size.width = clientRect.size.width-20;
                imgRect.size.height = (picSize.height/picSize.width)*(imgRect.size.width-20);
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
        if([pictureList count] >= 2 && [pictureList count] <= 4)
        {
            maxItemCountPerRow = 2;
        }
        else
        {
            maxItemCountPerRow = 3;
        }
        
        imgRect.size.width = (clientRect.size.width-25)/2;
        imgRect.size.height = imgRect.size.width;
        
        for (int i = 0; i < [pictureList count]; i++) {
            
            if (i > 0 && (i%maxItemCountPerRow) == 0)
            {
                originY += imgRect.size.height + 5;
                originX = 10;
            }
            else
            {
                originX = 10 + (i%maxItemCountPerRow)*imgRect.size.width + (i%maxItemCountPerRow)*5;
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
    
    return (originY+imgRect.size.height+5);
}

- (void)onBtnShare
{
    if ([self.delegate respondsToSelector:@selector(onShare:)]) {
        [self.delegate onShare:_newsId];
    }
}

- (void)onBtnDelete
{
    if ([self.delegate respondsToSelector:@selector(onDelete:)]) {
        [self.delegate onDelete:_newsId];
    }
}

- (void)onBtnReply
{
    if ([self.delegate respondsToSelector:@selector(onReply:)]) {
        [self.delegate onReply:_newsId];
    }
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
                imgRect.size.width = clientRect.size.width-20;
                imgRect.size.height = imgRect.size.width-20;
            }
            else
            {
                if(picSize.width > (clientRect.size.width-20))
                {
                    imgRect.size.width = clientRect.size.width-20;
                    imgRect.size.height = (picSize.height/picSize.width)*(imgRect.size.width-20);
                }
                else
                {
                    imgRect.size.width = picSize.width;
                    imgRect.size.height = picSize.height;
                }
            }
        }
        else if([item.imageArray count]  >= 2 && [item.imageArray count]  <= 4)
        {
            maxItemCountPerRow = 2;
            imgRect.size.width = (clientRect.size.width-25)/2;
            imgRect.size.height = imgRect.size.width;
        }
        else
        {
            maxItemCountPerRow = 3;
            imgRect.size.width = (clientRect.size.width-25)/2;
            imgRect.size.height = imgRect.size.width;
        }
        
        for (int i = 0; i < item.imageArray.count; i++) {
            
            if (i > 0 && (i%maxItemCountPerRow) == 0)
            {
                originY += imgRect.size.height + 5;
            }
        }
        
        originY += imgRect.size.height+5;
    }
    
    float txtHeight = 0;
    
    if(item.textContent != nil && (item.textContent.length > 0))
    {
        OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
        txtHeight = [newsDetailTableViewCell creatAttributedLabel:item.textContent Label:contentLabel fontSize:14];
    }
    
#if 0
    NSString *comments = [newsDetailTableViewCell combinCommnet:item.commentArray];
    
    if (comments != nil && ![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"]) {
        OHAttributedLabel *commentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
        int commentTxtHeight = [newsDetailTableViewCell creatCommentLabel:comments Label:commentLabel fontSize:13];
        txtHeight += (commentTxtHeight+25);
    }
#else
    if (![[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
    {
        txtHeight += 35;
    }
#endif

    return (originY+txtHeight+15);
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

- (float)layoutReaderList:(UIView*)parent originY:(float)originY reader:(NSString*)readers
{
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
    {
        return 0;
    }
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, originY, 14, 14)];
    [parent addSubview:logo];
    
    logo.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yanjing@2x" ofType:@"png"]];
    
    UILabel *descLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(26, originY, 60, 15)];
    [parent addSubview:descLabel1];
    
    descLabel1.font = [UIFont systemFontOfSize:12];
    descLabel1.textColor = [UIColor lightGrayColor];
    descLabel1.text = @"3人已阅读";
    
    UILabel *descLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(85, originY, 200, 15)];
    [parent addSubview:descLabel2];
    
    descLabel2.font = [UIFont systemFontOfSize:12];
    descLabel2.textColor = [UIColor lightGrayColor];
    descLabel2.text = @"-----------";
    
    UILabel *descLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(10, originY+20, 300, 15)];
    [parent addSubview:descLabel3];
    
    descLabel3.font = [UIFont boldSystemFontOfSize:14];
    descLabel3.textColor = [UIColor orangeColor];
    descLabel3.text = readers;
 
    return 45;
}


- (float)layoutComment:(UIView*)parent originY:(float)originY comments:(NSMutableArray*)commentsList
{
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"3"])
    {
        return 0;
    }
    
    NSString *comments = [newsDetailTableViewCell combinCommnet:commentsList];
    
    if (comments == nil) {
        return 0;
    }
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 200, 15)];
    [parent addSubview:descLabel];
    
    descLabel.font = [UIFont systemFontOfSize:12];
    descLabel.textColor = [UIColor lightGrayColor];
    descLabel.text = @"----------以下是评论----------";
    
    OHAttributedLabel *contentLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
    [newsDetailTableViewCell creatCommentLabel:comments Label:contentLabel fontSize:13];
    [CustomMethod drawImage:contentLabel];
    
    contentLabel.frame = CGRectMake(10, originY+15, CGRectGetWidth(contentLabel.frame), CGRectGetHeight(contentLabel.frame));
    [parent addSubview:contentLabel];
    
    return CGRectGetHeight(contentLabel.frame)+25;
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
    labelRect.size.width = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-20, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-20, CGFLOAT_MAX)].height;
    
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
                [attString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:possibleRange];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:possibleRange];
            }
        }
    }
    
    [label setAttString:attString withImages:wk_markupParser.images];
    
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-20, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-20, CGFLOAT_MAX)].height;
    
    label.frame = labelRect;
    
    label.underlineLinks = NO;
    [label.layer display];
    
    return  CGRectGetHeight(label.frame);
}

-(void)onTapAutor:(UITapGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapAutor:authorName:portriat:)]) {
        [self.delegate onTapAutor:_authorId authorName:_authorName portriat:_portrait];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
