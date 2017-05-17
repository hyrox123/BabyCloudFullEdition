//
//  newsDetailTableViewCell.h
//  BabyCloud
//
//  Created by apple on 15/7/28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@protocol newsDetailTableViewCellDelegate <NSObject>
@optional
-(void)onTapAutor:(NSString*)authorId authorName:(NSString*)authorName portriat:(NSString*)portriat;
-(void)onTapImage:(NSString*)newsId index:(int)index;
-(void)onShare:(NSString*)newsId;
-(void)onDelete:(NSString*)newsId;
-(void)onReply:(NSString*)newsId;
-(void)onTapBlank;
@end

@interface newsDetailTableViewCell : UITableViewCell
@property(nonatomic, weak) id<newsDetailTableViewCellDelegate>delegate;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item;
+(float)calculateCellHeight:(NewsItem*)item;
@end
