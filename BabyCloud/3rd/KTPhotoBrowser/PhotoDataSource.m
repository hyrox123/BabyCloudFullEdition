//
//  PhotoDataSource.m
//  ReallyBigPhotoLibrary
//
//  Created by Kirby Turner on 9/14/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "PhotoDataSource.h"
#import "KTPhotoBrowserGlobal.h"

@interface PhotoDataSource()
@property(nonatomic) NSMutableArray *fileArray;
@end

@implementation PhotoDataSource

- (id)init
{
    self = [super init];
    
    if (self) {
                
        NSString *configPath =[NSHomeDirectory() stringByAppendingString:@"/Documents/Photos"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        
        _fileArray =  [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:configPath error:&error]];
    }
    
    return self;
}

- (NSInteger)numberOfPhotos
{
    return [_fileArray count];
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    NSString *filePath =[NSHomeDirectory() stringByAppendingString:@"/Documents/Photos"];
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@", filePath, [_fileArray objectAtIndex:index]];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if([fileMgr fileExistsAtPath:fileName])
    {
        NSError *err;
        [fileMgr removeItemAtPath:fileName error:&err];
        [_fileArray removeObjectAtIndex:index];
    }
}

// Implement either these, for synchronous images…
- (UIImage *)imageAtIndex:(NSInteger)index
{
    NSString *filePath =[NSHomeDirectory() stringByAppendingString:@"/Documents/Photos"];
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@", filePath, [_fileArray objectAtIndex:index]];
    return  [[UIImage alloc] initWithContentsOfFile:fileName];
}

- (UIImage *)thumbImageAtIndex:(NSInteger)index
{
    NSString *filePath =[NSHomeDirectory() stringByAppendingString:@"/Documents/Photos"];
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@", filePath, [_fileArray objectAtIndex:index]];
    return  [[UIImage alloc] initWithContentsOfFile:fileName];
}


@end
