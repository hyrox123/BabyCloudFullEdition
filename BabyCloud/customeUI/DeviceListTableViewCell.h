//
//  DeviceListTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeviceListTableViewCellDelegate <NSObject>
@optional
- (void)onClickVideo:(int)index;
@end

@interface DeviceListTableViewCell : UITableViewCell
@property(nonatomic,weak) id<DeviceListTableViewCellDelegate>delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSMutableArray*)itemArray;
+(float)calculateCellHeight:(NSMutableArray*)itemArray;

@end
