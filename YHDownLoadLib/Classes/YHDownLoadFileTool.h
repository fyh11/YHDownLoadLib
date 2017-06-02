//
//  YHDownLoadFileTool.h
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/1.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHDownLoadFileTool : NSObject

+ (BOOL)isFileExists: (NSString *)filePath;

+ (long long)fileSizeWithPath: (NSString *)filePath;

+ (void)moveFile: (NSString *)fromPath toPath: (NSString *)toPath;

+ (void)removeFile: (NSString *)filePath;

@end
