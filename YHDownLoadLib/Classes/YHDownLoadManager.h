//
//  YHDownLoadManager.h
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/8.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHDownLoader.h"

@interface YHDownLoadManager : NSObject

+ (instancetype)defaultManager;

- (YHDownLoader *)downLoadWithUrl: (NSURL *)url withDownLoadInfo:(DownLoadInfoType)downLoadInfo DownLoadSuccesType:(DownLoadSuccesType)downLoadSuccess DownLoadFaileType:(DownLoadFaileType)DownLoadFaile;

- (YHDownLoader *)downLoadWithUrl: (NSURL *)url;

// 暂停下载
- (void)pauseWithUrl: (NSURL *)url;

// 恢复下载
- (void)resumeWithUrl: (NSURL *)url;

// 取消下载
- (void)cancelWithUrl: (NSURL *)url;

- (void)pauseAll;

@end
