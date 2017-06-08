//
//  YHDownLoader.m
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/1.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "YHDownLoader.h"
#import "YHDownLoadFileTool.h"
#import "NSString+MD5.h"

#define KCache  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

#define KTmp   NSTemporaryDirectory()

@interface YHDownLoader()<NSURLSessionDataDelegate>
{
    // 临时文件大小
    long long _tmpFileSize;
    // 总文件大小
    long long _totalFileSize;
}

// 缓存文件路径
@property (nonatomic, strong) NSString *cacheFilePath;

// 临时文件路径
@property (nonatomic, strong) NSString *tmpFilePath;

// 下载绘话
@property (nonatomic, strong) NSURLSession *session;

// 输出流
@property (nonatomic, strong) NSOutputStream *outputStream;

// 任务
@property (nonatomic, strong)NSURLSessionDataTask *task;

@end

@implementation YHDownLoader

- (NSURLSession *)session
{
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

- (void)downLoadWithUrl:(NSURL *)url withDownLoadInfo:(DownLoadInfoType)downLoadInfo DownLoadSuccesType:(DownLoadSuccesType)downLoadSuccess DownLoadFaileType:(DownLoadFaileType)DownLoadFaile
{
    self.downLoadInfo = downLoadInfo;
    self.downLoadFaile = DownLoadFaile;
    self.downLoadSuccess = downLoadSuccess;
    
    [self downLoadWithUrl:url];
}

- (void)downLoadWithUrl:(NSURL *)url
{
    // 这里面需要做两件事情
    self.cacheFilePath = [KCache stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [[KTmp stringByAppendingPathComponent:url.absoluteString] md5];
    
    // 1.如果文件已经下载完成, 直接返回
    if ([YHDownLoadFileTool isFileExists:self.cacheFilePath]) {
        if (self.downLoadInfo) {
            self.downLoadInfo([YHDownLoadFileTool fileSizeWithPath:self.cacheFilePath]);
        }
        NSLog(@"文件已经存在");
        
        self.state = YHDownLoadStateSuccess;
        if (self.downLoadSuccess) {
            self.downLoadSuccess(self.cacheFilePath);
        }
        
        return;
    }
    
    if ([url isEqual:self.task.originalRequest.URL]) {
        if (self.state == YHDownLoadStateDowning) {
            return;
        }
        
        if (self.state == YHDownLoadStatePause) {
            [self resume];
            self.state = YHDownLoadStateDowning;
            // 任务存在  正在下载-> 返回
            // 暂停-> 恢复
            return;
        }
    }
    
    // 任务不存在 取消
    [self cancel];
    
    // 2.如果文件没有下载完成, 接着缓存的位置继续下载
    _tmpFileSize = [YHDownLoadFileTool fileSizeWithPath:self.tmpFilePath];
    [self downLoadWithUrl:url offSet:_tmpFileSize];
    
}

// 恢复
- (void)resume
{
    if (self.state == YHDownLoadStatePause) {
        [self.task resume];
        self.state = YHDownLoadStateDowning;
    }
}

// 暂停
- (void)pause
{
    if (self.state == YHDownLoadStateDowning) {
        [self.task suspend];
        self.state = YHDownLoadStatePause;
    }
}

// 取消
- (void)cancel
{
    // 结束绘话
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndRemoveCache
{
    [self cancel];

    // 删除缓存
    [YHDownLoadFileTool removeFile:self.tmpFilePath];
}

/**
 
 
 */
- (void)downLoadWithUrl:(NSURL *)url offSet: (long long)offSet
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offSet] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    [task resume];
    
    self.task = task;
}

#pragma mark--NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Length"]) {
        NSString *range = httpResponse.allHeaderFields[@"Content-Length"];
        _totalFileSize = [[range componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    // 判断本地缓存文件大小和文件的总大小
    // 当本地缓存 = 文件总大小, 移动临时文件到缓存文件退出
    if (_totalFileSize == _tmpFileSize ) {
        
        self.state = YHDownLoadStateSuccess;
        
        [YHDownLoadFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    if (self.downLoadInfo) {
        self.downLoadInfo(_totalFileSize);
    }
    
    // 本地缓存 > 文件总大小 说明缓存有问题 删除缓存 重新下载
    if (_tmpFileSize > _totalFileSize) {
        // 删除环境
        [YHDownLoadFileTool removeFile:self.tmpFilePath];
        
        // 取消任务
        completionHandler(NSURLSessionResponseCancel);
        // 重新下载
        [self downLoadWithUrl:response.URL offSet:0];
        self.state = YHDownLoadStateDowning;
        return;
    }
    
    self.state = YHDownLoadStateDowning;
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    // 说明没有下载完成,继续下载
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data
{
    [self.outputStream write:data.bytes maxLength:data.length];
    
    _tmpFileSize += data.length;
    
    self.progress = 0.1 * _tmpFileSize / _totalFileSize;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.outputStream close];
    self.outputStream = nil;
    
    if (error == nil) {
        self.state = YHDownLoadStateSuccess;
        
        // 将临时文件移动到缓存文件
        [YHDownLoadFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        if (self.downLoadSuccess) {
            self.downLoadSuccess(self.cacheFilePath);
        }
    }else{
        self.state = YHDownLoadStateFaile;
        NSLog(@"有错误---%@",error);
        if (self.downLoadFaile) {
            self.downLoadFaile();
        }
    }
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if (self.DownLoadProgress) {
        self.DownLoadProgress(_progress);
    }
}

- (void)setState:(YHDownLoadState)state
{
    if (_state == state) {
        return;
    }
    
    _state = state;
    if (self.downLoadState) {
        self.downLoadState(_state);
    }
}

@end
