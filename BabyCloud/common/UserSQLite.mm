//
//  UserSQLite.m
//  YSTParentClient
//
//  Created by apple on 14-11-14.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "UserSQLite.h"
#import<CoreData/CoreData.h>
#import "UserBase.h"

static UserSQLite* instance = nil;

@interface UserSQLite()
@end

@implementation UserSQLite

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+(UserSQLite*)getInstance
{
    if (!instance) {
        instance = [UserSQLite new];
    }
    
    return instance;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewsModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)addNewUser:(NSString*)account password:(NSString*)psw
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserBase"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",
                               account]];
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if ([results count] == 0) {
        
        UserBase *user = [NSEntityDescription insertNewObjectForEntityForName:@"UserBase" inManagedObjectContext:context];
        user.name = account;
        user.psw = psw;
        
        NSError *error;
        if(![context save:&error])
        {
            NSLog(@"不能保存：%@",[error localizedDescription]);
        }
    }
}

- (NSMutableArray*)searchAllUsers
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setFetchLimit:100];
    [fetchRequest setFetchOffset:0];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserBase" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (UserBase *info in fetchedObjects) {
        [resultArray addObject:info];
    }
    
    return resultArray;
}

@end
