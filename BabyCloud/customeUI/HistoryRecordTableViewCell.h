//
//  HistoryRecordTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/5/28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryRecordTableViewCellDelegate <NSObject>
@optional
-(void)onTapSection:(int)row index:(int)index;
@end

@interface HistoryRecordTableViewCell : UITableViewCell
@property(nonatomic, weak) id<HistoryRecordTableViewCellDelegate>delegate;
@property(nonatomic) int row;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier records:(NSMutableArray*)recordArray;
+(float)calculateCellHeight:(NSMutableArray*)recordArray;
@end
