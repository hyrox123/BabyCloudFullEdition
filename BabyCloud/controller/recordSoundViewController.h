//
//  recordSoundViewController.h
//  YSTParentClient
//
//  Created by apple on 15/7/7.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol recordSoundViewDelegate <NSObject>
-(void)onClosePopView:(NSString*)fileUrl;
@end

@interface recordSoundViewController : UIViewController
@property(nonatomic,weak) id<recordSoundViewDelegate>delegate;
@end
