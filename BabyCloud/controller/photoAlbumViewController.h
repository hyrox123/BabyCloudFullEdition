//
//  photoAlbumViewController.h
//  YSTParentClient
//
//  Created by apple on 14-10-15.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTThumbsViewController.h"
#import "PhotoDataSource.h"

@interface photoAlbumViewController : KTThumbsViewController
@property (nonatomic) PhotoDataSource *photoSrc;
@end