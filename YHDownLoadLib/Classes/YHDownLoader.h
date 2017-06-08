//
//  YHDownLoader.h
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/1.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger{
    YHDownLoadStateUnKnown,
    
    YHDownLoadStatePause,
    
    YHDownLoadStateDowning,
    
    YHDownLoadStateSuccess,
    
    YHDownLoadStateFaile
    
}YHDownLoadState;


typedef void(^DownLoadInfoType)(long long fileSize);
typedef void(^DownLoadSuccesType)(NSString *cacheFilePath);
typedef void(^DownLoadFaileType)();
typedef void(^DownLoadStateChange)(YHDownLoadState state);



@interface YHDownLoader : NSObject

// 下载的文件信息
@property (nonatomic, copy)DownLoadInfoType downLoadInfo;

// 下载成功后调用的block
@property (nonatomic, copy)DownLoadSuccesType downLoadSuccess;

// 下载失败后调用的block
@property (nonatomic, copy)DownLoadFaileType downLoadFaile;

// 下载状态的改变
@property (nonatomic, copy)DownLoadStateChange downLoadState;

// 下载进度
@property (nonatomic, assign) float progress;

// 下载
- (void)downLoadWithUrl: (NSURL *)url withDownLoadInfo: (DownLoadInfoType)downLoadInfo  DownLoadSuccesType:(DownLoadSuccesType)downLoadSuccess DownLoadFaileType:(DownLoadFaileType)DownLoadFaile;

// 下载
- (void)downLoadWithUrl: (NSURL *)url;

// 暂停下载
- (void)pause;

// 恢复下载
- (void)resume;

// 取消下载
- (void)cancel;

@property (nonatomic, assign) YHDownLoadState state;

@property (nonatomic, copy) DownLoadStateChange stateChange;

@property (nonatomic, copy) void(^DownLoadProgress)(float progress);

@end
