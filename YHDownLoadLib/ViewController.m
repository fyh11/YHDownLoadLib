//
//  ViewController.m
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/1.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "ViewController.h"
#import "YHDownLoadManager.h"

@interface ViewController ()

@property (nonatomic, strong) YHDownLoader *downLoader;
@property (weak, nonatomic) IBOutlet UIButton *startDownLoad;
@property (weak, nonatomic) IBOutlet UIButton *resume;
@property (weak, nonatomic) IBOutlet UIButton *pause;
@property (weak, nonatomic) IBOutlet UIButton *cancle;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) NSURL *url;

@end

@implementation ViewController

#pragma mark --- 懒加载url
-(NSURL *)url
{
    if (!_url) {
        _url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"];
    }
    return _url;
}

#pragma mark-- 懒加载timer
- (NSTimer *)timer
{
    if (_timer == nil) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}


#pragma mark-- 懒加载downLoader
- (YHDownLoader *)downLoader
{
    if (_downLoader == nil) {
        
        _downLoader = [[YHDownLoader alloc] init];
    }
    
    return _downLoader;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self timer];
 
}

- (void) update
{
    NSLog(@"state == %ld",(long)self.downLoader.state);
}

- (IBAction)sender:(id)sender {
    
    if (sender == self.startDownLoad) { // 开始下载
        [[YHDownLoadManager defaultManager] downLoadWithUrl:self.url withDownLoadInfo:^(long long fileSize) {
            NSLog(@"fileSize == %lld",fileSize);
            self.downLoader.state = YHDownLoadStateDowning;
        } DownLoadSuccesType:^(NSString *cacheFilePath) {
             NSLog(@"cacheFilePath == %@",cacheFilePath);
            self.downLoader.state = YHDownLoadStateSuccess;
        } DownLoadFaileType:^{
            self.downLoader.state = YHDownLoadStateFaile;
             NSLog(@"下载失败了");
        }];
    }else if (sender == self.resume){ // 继续下载
        [[YHDownLoadManager defaultManager] resumeWithUrl:self.url];
    }else if (sender == self.pause){ // 暂停下载
        [[YHDownLoadManager defaultManager] pauseWithUrl:self.url];
    }else{ // 取消下载
        [[YHDownLoadManager defaultManager] cancelWithUrl:self.url];;
    }
}


@end
