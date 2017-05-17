//
//  XAbstractTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/5/4.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@interface XAbstractTableViewCell : UITableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NewsItem:(NewsItem*)item;
@end
