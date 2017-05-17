//
//  NewsTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/3/18.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@protocol NewTableViewCellDelegate <NSObject>
@optional
-(void)onTapImage:(int)row index:(int)index;
@end


@interface NewsTableViewCell : UITableViewCell
@property(nonatomic) CGFloat height;
@property(nonatomic) int row;
@property(nonatomic, weak) id<NewTableViewCellDelegate>delegate;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item;
@end
