//
//  SignInTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/5/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "SignInTableViewCell.h"
#import "ProtoType.h"
#import "SDPieLoopProgressView.h"
#import "SDTransparentPieProgressView.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"

@interface SignInTableViewCell()
-(void)initSubview:(NSArray*)itemArray date:(NSString*)dateTiem;
-(void)onTapImage:(UITapGestureRecognizer*)gesture;
@end

@implementation SignInTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSMutableArray*)itemArray date:(NSString*)dateTiem
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initSubview:itemArray date:dateTiem];
        // Initialization code
    }
    
    return self;
}

- (void)initSubview:(NSArray*)itemArray date:(NSString*)dateTiem
{
    CGRect itemRect, clientRect = [ UIScreen mainScreen ].bounds;
    itemRect.size.width = (clientRect.size.width-50)/4;
    itemRect.size.height = (clientRect.size.width-50)/4 + 30;

    int posX, posY, signeInStudent = 0;
    
    for (int i = 0; i < itemArray.count; i++) {
        
        posX = 10+(i%4)*itemRect.size.width+(i%4)*10;
        posY = 35+(i/4)*itemRect.size.height;
        
        UIImageView *imagV = [[UIImageView alloc] initWithFrame:CGRectMake(posX, posY, itemRect.size.width, itemRect.size.width)];
        [self.contentView addSubview:imagV];
        
        imagV.tag = 0x100+i;
        imagV.layer.masksToBounds = YES;
        imagV.layer.cornerRadius = 8;

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY+itemRect.size.width, itemRect.size.width, 20)];
        [self.contentView addSubview:nameLabel];
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        
        SignInItem *item = [itemArray objectAtIndex:i];
        nameLabel.text = item.studentName;
        
        if ([item.state isEqualToString:@"1"]) {
            nameLabel.textColor = [UIColor blackColor];
            signeInStudent++;
        }
        else
        {
            nameLabel.textColor = [UIColor lightGrayColor];
        }
        
        if (item.portrait != nil && item.portrait.length > 0) {
            
            __block SDPieLoopProgressView *activityIndicator = nil;
            __weak UIImageView *weakImageView = imagV;
            [imagV sd_setImageWithURL:[NSURL URLWithString:item.portrait]
                     placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]]
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
                                
                                if (![item.state isEqualToString:@"1"]) {
                                    UIImage *dstImg = [utilityFunction getGrayImage:weakImageView.image];
                                    weakImageView.image = dstImg;
                                }
                            }];
        }
        else
        {
            if (![item.state isEqualToString:@"1"]) {
                imagV.image = [utilityFunction getGrayImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]]];
            }
            else
            {
                imagV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]];
            }
        }
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImage:)];
        [imagV addGestureRecognizer:singleTapGesture];
    }
    
    
    UILabel *describLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, clientRect.size.width-10, 20)];
    [self.contentView addSubview:describLabel];
    
    describLabel.textAlignment = NSTextAlignmentLeft;
    describLabel.font = [UIFont systemFontOfSize:12];
    describLabel.textColor = [UIColor lightGrayColor];
    
    NSMutableDictionary *dict = [utilityFunction getChineseDate:dateTiem complex:NO];
    NSString *date = [dict objectForKey:@"dateTime"];
    
    NSString *textContent = [NSString stringWithFormat:@"%@: %d名学生已签到 %d名学生未签到", date, signeInStudent, itemArray.count-signeInStudent];

#if 0
    NSRange range1 = [textContent rangeOfString:@"名学生 其中"];
    NSRange range2 = [textContent rangeOfString:@"名学生已签到 "];
    NSRange range3 = [textContent rangeOfString:@"名学生未签到"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:textContent];
   
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(3,range1.location-3)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique" size:18.0] range:NSMakeRange(3, range1.location-3)];
    
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(range1.location+range1.length,range2.location-range1.location-range1.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique" size:18.0] range:NSMakeRange(range1.location+range1.length,range2.location-range1.location-range1.length)];
    
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(range2.location+range2.length,range3.location-range2.location-range2.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique" size:18.0] range:NSMakeRange(range2.location+range2.length,range3.location-range2.location-range2.length)];
    
    describLabel.attributedText = str;
    
#else
    NSRange range = [textContent rangeOfString:@":"];
   
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:textContent];
    
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,range.location)];
    [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, range.location)];

    describLabel.attributedText = str;
#endif
    
}

- (void)onTapImage:(UITapGestureRecognizer*)gesture
{
    UIView *tmpView = [gesture view];
    
    if (tmpView != nil) {
        NSInteger index = tmpView.tag-0x100;
        if ([self.delegate respondsToSelector:@selector(onTapStudent:)]) {
            [self.delegate onTapStudent:index];
        }
    }
}

+ (float)calculateCellHeight:(NSMutableArray*)itemArray
{
    if (itemArray.count == 0) {
        return 40;
    }
    
    CGRect itemRect, clientRect = [ UIScreen mainScreen ].bounds;
    itemRect.size.width = (clientRect.size.width-50)/4;
    itemRect.size.height = (clientRect.size.width-50)/4 + 30;

    float additionHeight = 0;
    
    if (itemArray.count%4 != 0) {
        additionHeight = itemRect.size.height;
    }
    
    return ((itemArray.count/4)*itemRect.size.height+additionHeight+40);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
