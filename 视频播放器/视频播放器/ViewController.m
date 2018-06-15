//
//  ViewController.m
//  视频播放器
//
//  Created by 16 on 2018/6/7.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "ViewController.h"
#import "JJPlayerManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 创建底部父视图,播放器会与底部父视图同样大小
    UIView *test = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    [self.view addSubview:test];
    
    // 一句话实现播放器
    [JJPlayerManager showOnView:test url:[NSURL URLWithString:@"http://tb-video.bdstatic.com/videocp/12045395_f9f87b84aaf4ff1fee62742f2d39687f.mp4"] title:@"在这里设置标题" type:JJ_PLayerTypeTypeDefault complete:^{
        NSLog(@"播放完成了");
    }];

    // 一段时间后转移父视图
    UIView *test1 = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 300, 400)];
    [self.view addSubview:test1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JJPlayerManager showOnView:test1 type:JJ_PLayerTypeTypeShortVideo];
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


@end
