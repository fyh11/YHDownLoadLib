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

@end

@implementation YHDownLoader

- (NSURLSession *)session
{
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

- (void)downLoadWithUrl:(NSURL *)url
{
    // 这里面需要做两件事情
    self.cacheFilePath = [KCache stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [[KTmp stringByAppendingPathComponent:url.absoluteString] md5];
    
    // 1.如果文件已经下载完成, 直接返回
    if ([YHDownLoadFileTool isFileExists:self.cacheFilePath]) {
        
        return;
    }
    
    // 2.如果文件没有下载完成, 接着缓存的位置继续下载
    _tmpFileSize = [YHDownLoadFileTool fileSizeWithPath:self.tmpFilePath];
    [self downLoadWithUrl:url offSet:_tmpFileSize];
    
}

- (void)downLoadWithUrl:(NSURL *)url offSet: (long long)offSet
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offSet] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    [task resume];
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
        
        [YHDownLoadFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    // 本地缓存 > 文件总大小 说明缓存有问题 删除缓存 重新下载
    if (_tmpFileSize > _totalFileSize) {
        // 删除环境
        [YHDownLoadFileTool removeFile:self.tmpFilePath];
        
        // 取消任务
        completionHandler(NSURLSessionResponseCancel);
        // 重新下载
        [self downLoadWithUrl:response.URL offSet:0];
        return;
    }
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    // 说明没有下载完成,继续下载
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data
{
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.outputStream close];
    self.outputStream = nil;
    
    if (error == nil) {
        
        // 将临时文件移动到缓存文件
        [YHDownLoadFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
    }else{
        
        NSLog(@"有错误---%@",error);
    }
}



@end
