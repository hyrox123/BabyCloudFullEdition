//
//  ScheduleTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 14-11-20.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@protocol ScheduleTableViewCellDelegate <NSObject>
@optional
-(void)onTapImage:(int)section index:(int)index;
@end


@interface ScheduleTableViewCell : UITableViewCell
@property(nonatomic) CGFloat height;
@property(nonatomic) int section;
@property(nonatomic, weak) id<ScheduleTableViewCellDelegate>delegate;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item;
@end
