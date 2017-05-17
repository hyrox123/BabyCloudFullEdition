//
//  instructionViewController.h
//  YSTParentClient
//
//  Created by apple on 14-11-21.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol instructionViewDelegate <NSObject>
-(void)onCloseInstruction;
@end

@interface instructionViewController : UIViewController
@property(nonatomic, weak) id<instructionViewDelegate>delegate;
@end
