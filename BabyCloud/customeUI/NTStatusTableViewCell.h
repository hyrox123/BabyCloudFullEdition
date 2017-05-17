//
//  NTStatusTableViewCell.h
//  TableView
//
//  Created by MD101 on 14-10-10.
//  Copyright (c) 2014年 NT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShuttleItem;

@protocol shuttleViewCellDelegate <NSObject>
@optional
-(void)onTapImage:(NSString*)shuttleId index:(int)index;
@end

@interface NTStatusTableViewCell : UITableViewCell
@property(nonatomic, weak) id<shuttleViewCellDelegate>delegate;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier shuttleItem:(ShuttleItem*)item;
+(float)calculateCellHeight:(ShuttleItem*)item;
@end
