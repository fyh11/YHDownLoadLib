//
//  YHDownLoadFileTool.m
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/1.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "YHDownLoadFileTool.h"

@implementation YHDownLoadFileTool

+ (BOOL)isFileExists: (NSString *)filePath
{
   return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (long long)fileSizeWithPath: (NSString *)filePath;
{
    if (![self isFileExists:filePath]) {
        
        return 0;
    }
    
    NSDictionary *fileAtribute = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    long long size = [fileAtribute[NSFileSize] longLongValue];
    
    return size;
}

+ (void)moveFile: (NSString *)fromPath toPath: (NSString *)toPath
{
    if (![self isFileExists:fromPath]) {
        
        return;
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removeFile: (NSString *)filePath
{
    if (![self isFileExists:filePath]) {
        
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
