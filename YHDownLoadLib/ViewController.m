//
//  ViewController.m
//  YHDownLoadLib
//
//  Created by 樊义红 on 17/6/1.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "ViewController.h"
#import "YHDownLoader.h"

@interface ViewController ()

@property (nonatomic, strong) YHDownLoader *downLoader;

@end

@implementation ViewController


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
    
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"];
    [self.downLoader downLoadWithUrl:url];
}


@end
