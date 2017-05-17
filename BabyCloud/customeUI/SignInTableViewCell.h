//
//  SignInTableViewCell.h
//  YSTParentClient
//
//  Created by apple on 15/5/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignInDelegate <NSObject>
@optional
-(void)onTapStudent:(int)index;
@end

@interface SignInTableViewCell : UITableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSMutableArray*)itemArray date:(NSString*)dateTiem;
+(float)calculateCellHeight:(NSMutableArray*)itemArray;

@property(nonatomic,weak) id<SignInDelegate>delegate;
@end
