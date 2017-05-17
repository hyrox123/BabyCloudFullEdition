//
//  UserSQLite.h
//  YSTParentClient
//
//  Created by apple on 14-11-14.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UserBase;

@interface UserSQLite : NSObject

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(UserSQLite*)getInstance;
-(void)addNewUser:(NSString*)account password:(NSString*)psw;
-(NSMutableArray*)searchAllUsers;
-(NSURL*)applicationDocumentsDirectory;

@end
