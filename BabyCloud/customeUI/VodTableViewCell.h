//
//  VodTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/9/15.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaItem;

@interface VodTableViewCell : UITableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mediaItem:(MediaItem*)item;
@end
