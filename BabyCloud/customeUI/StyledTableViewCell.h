//
//  StyledTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/5/6.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@protocol StyledTableViewCellDelegate <NSObject>
@optional
-(void)onTapImage:(NSString*)newsId index:(int)index;
-(void)onTapAutor:(NSString*)authorId authorName:(NSString*)authorName portriat:(NSString*)portriat;
-(void)onTapSchool:(NSString*)schoolId;
-(void)onTapComment:(NSString*)newsId;
-(void)onTapPraise:(NSString*)newsId authorId:(NSString*)authorId;
-(void)onTapDelete:(NSString*)newsId;
-(void)onTapReport:(NSString*)newsId;
-(void)onTapBlank;
@end

@interface StyledTableViewCell : UITableViewCell
@property(nonatomic, weak) id<StyledTableViewCellDelegate>delegate;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item;
+(float)calculateCellHeight:(NewsItem*)item;
@end
