//
//  YHDownLoadManager.m
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/8.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "YHDownLoadManager.h"
#import "NSString+MD5.h"

@interface YHDownLoadManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, YHDownLoader *>*downLoadInfo;

@end

@implementation YHDownLoadManager

static YHDownLoadManager *_defaultManager;
+ (instancetype)defaultManager
{
    if (_defaultManager == nil) {
        _defaultManager = [[YHDownLoadManager alloc] init];
    }
    return _defaultManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    
    if (!_defaultManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _defaultManager = [super allocWithZone:zone];
        });
    }
     return _defaultManager;
}

- (YHDownLoader *)downLoadWithUrl: (NSURL *)url withDownLoadInfo:(DownLoadInfoType)downLoadInfo DownLoadSuccesType:(DownLoadSuccesType)downLoadSuccess DownLoadFaileType:(DownLoadFaileType)DownLoadFaile
{
    NSString *md5 = url.absoluteString.md5;
    YHDownLoader *downLoad = _downLoadInfo[md5];
    if (downLoad) {
        [downLoad resume];
        return downLoad;
    }
    downLoad = [[YHDownLoader alloc] init];
    [_downLoadInfo setValue:downLoad forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoad downLoadWithUrl:url withDownLoadInfo:^(long long fileSize) {
        
    } DownLoadSuccesType:^(NSString *cacheFilePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if (downLoadSuccess) {
            downLoadSuccess(cacheFilePath);
        }
    } DownLoadFaileType:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if (DownLoadFaile) {
            DownLoadFaile();
        }
    }];
    
    return downLoad;
}

- (YHDownLoader *)downLoadWithUrl: (NSURL *)url
{
    NSString *md5 = url.absoluteString.md5;
    YHDownLoader *downLoad = _downLoadInfo[md5];
    if (downLoad) {
        [downLoad resume];
        return downLoad;
    }
    downLoad = [[YHDownLoader alloc] init];
    [_downLoadInfo setValue:downLoad forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoad downLoadWithUrl:url withDownLoadInfo:^(long long fileSize) {
        
    } DownLoadSuccesType:^(NSString *cacheFilePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    } DownLoadFaileType:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    }];
    
    return downLoad;
}

// 暂停下载
- (void)pauseWithUrl: (NSURL *)url;
{
    YHDownLoader *downLoad = self.downLoadInfo[url.absoluteString.md5];
    [downLoad pause];
}

// 恢复下载
- (void)resumeWithUrl: (NSURL *)url;
{
    YHDownLoader *downLoad = self.downLoadInfo[url.absoluteString.md5];
    [downLoad resume];
}

// 取消下载
- (void)cancelWithUrl: (NSURL *)url
{
    YHDownLoader *downLoad = self.downLoadInfo[url.absoluteString.md5];
    [downLoad cancel];
}

- (void)pauseAll
{
    [[self.downLoadInfo allKeys]makeObjectsPerformSelector:@selector(pause)];
}

@end
