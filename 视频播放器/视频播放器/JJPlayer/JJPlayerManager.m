//
//  JJPlayerManager.m
//  视频播放器
//
//  Created by 16 on 2018/6/7.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "JJPlayerControlView.h"

@interface JJPlayerManager ()<JJPlayerControlViewDelegate>

@property (nonatomic , strong) AVPlayer *player;
@property (nonatomic , strong) AVPlayerLayer *playerLayer;
@property (nonatomic , strong) AVPlayerItem *playerItem;
@property (nonatomic , strong) JJPlayerControlView *control;
@property (nonatomic , strong) UIView *superView; // 父视图,切换屏幕用
@property (nonatomic , strong) NSString *title; // 视频标题
@property (nonatomic , assign) BOOL isPause; // 是否点击了暂停
@property (nonatomic , assign) NSInteger allTime; // 总时长
@property (nonatomic , assign) JJ_PLayerType type; // 播放器类型
@end
@implementation JJPlayerManager

static JJPlayerManager *instance;
#pragma mark 创建视频单例,防止播放器用其他方式创建
+ (void)initialize{
    [JJPlayerManager manager];
}
+ (instancetype)manager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJPlayerManager alloc]init];
        instance.backgroundColor = [UIColor blackColor];
        instance.clipsToBounds = YES;
        instance.isPause = NO;
    });
    return instance;
}
+ (instancetype)alloc
{
    if (instance) {
        NSException *exception = [NSException exceptionWithName:@"JJPlayerManager" reason:@"JJPlayerManager是一个单例!" userInfo:nil];
        [exception raise];
    }
    return [super alloc];
}
- (id)copy
{
    return self;
}
- (id)mutableCopy
{
    return self;
}
#pragma mark 添加视频视图
+ (void)showOnView:(UIView *)view url:(NSURL *)url title:(NSString *)title type:(JJ_PLayerType)type complete:(JJPlayerManagerPlayFinishedCallback)complete
{
    instance.block = complete;
    instance.superView = view;
    instance.type = type;
    instance.title = title;
    [instance showOnView:view withUrl:url];
}
- (void)showOnView:(UIView *)view withUrl:(NSURL *)url
{
    self.frame = view.bounds;
    [view addSubview:self];
    
    // 创建一个播放器item
    self.playerItem=[AVPlayerItem playerItemWithURL:url];
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    // 创建播放器
    self.player=[AVPlayer playerWithPlayerItem:_playerItem];
    
    // 创建播放器layer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 设置播放器layer的尺寸
    _playerLayer.frame=view.bounds;
    // 添加到播放器管理单例上
    [self.layer addSublayer:_playerLayer];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    // 添加控制视图,并展示加载视图
    self.control = [[JJPlayerControlView alloc] initWithFrame:self.bounds controlStyle:[self getPlayerControlStyle]];
    _control.delegate = self;
    [_control setUpTitle:_title];
    [self addSubview:_control];
    [_control showLoading];
}
+ (void)showOnView:(UIView *)view type:(JJ_PLayerType)type
{
    instance.type = type;
    instance.frame = view.bounds;
    instance.superView = view;
    instance.control.frame = view.bounds;
    instance.control.style = [instance getPlayerControlStyle];
    instance.playerLayer.frame = view.bounds;
    [view addSubview:instance];
}
#pragma KVO监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            CMTime duration = playerItem.duration;
            self.allTime = CMTimeGetSeconds(duration);
            if (duration.value) {
                // 开始播放
                [self playerPlay];
                [_control hiddenLoading];
            }else {
                // 展示播放出错视图
                [_control showError];
            }
        }else if (status==AVPlayerStatusFailed) {
            // 展示播放出错视图
            [_control showError];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        // 获取缓冲信息
        NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
        // 获取缓冲区域
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        // 计算缓冲总进度
        NSTimeInterval result = startSeconds + durationSeconds;
        // 计算当前播放的进度
        NSTimeInterval play = self.player.currentTime.value/self.player.currentTime.timescale;
        // 实时设置缓冲进度
        NSString *progress = [NSString stringWithFormat:@"%.2f",result/self.allTime];
        [_control setUpProgress:[progress floatValue]];
        
        if (result > play+20 || result == playerItem.duration.value) {
        
            if (self.isPause) return;
            [self.player play];
            [_control hiddenLoading];
        }

    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"缓冲用完了");
        [_control showLoading];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"缓冲足够用了");
    }
}
#pragma mark 播放器播放视频
+ (void)play
{
    [instance playerPlay];
}
- (void)playerPlay
{
    if (self.player)
    {
        self.isPause = NO;
        [self.player play];
        __weak typeof(self) weakSelf = self;
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            // 获取当前时间和总时长
            float currentTime = CMTimeGetSeconds(time);
            [strongSelf.control setUpSlider:currentTime all:strongSelf.allTime];
        }];
    };
}
#pragma mark 播放器停止播放
+ (void)pause
{
    [instance playerPause];
}
- (void)playerPause
{
    if (self.player) {
        self.isPause = YES;
        [self.player pause];
    }
}
#pragma mark 播放器释放
+ (void)remove
{
    [instance removePlayer];
}
- (void)removePlayer
{
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer=nil;
    self.player=nil;
    [self removeFromSuperview];
}
#pragma mark 判断播放器是否播放中
+ (BOOL)isPlaying
{
    return [instance isPlay];
}
- (BOOL)isPlay
{
    if (self.player.rate == 0) {
        return NO;
    }
    return YES;
}
#pragma mark 其他方法
- (void)playFinished:(NSNotification *)notify
{
    NSLog(@"视频播放完成");
    self.block();
}
#pragma mark 代理方法
- (void)JJPlayerControlViewSliderWillChange
{
    [self playerPause];
}
- (void)JJPlayerControlViewSliderChangedEnd:(CGFloat)current
{
    CMTime dragTime = CMTimeMake(current, 1);
    // 重新设置当前播放时间
    __weak typeof(self) weakself = self;
    [self.player seekToTime:dragTime completionHandler:^(BOOL finished) {
        __strong typeof(weakself) strongSelf = weakself;
        // 继续播放
        [strongSelf playerPlay];
    }];
}
- (void)JJPlayerControlViewPlayBtnClicked:(BOOL)play
{
    if (play) {
        [self playerPause];
    }else {
        [self playerPlay];
    }
}
- (void)JJPlayerControlViewFullBtnClicked:(BOOL)full
{
    NSLog(@"%d",full);
    if (full) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = window.bounds;
        self.control.frame = window.bounds;
        self.playerLayer.frame = window.bounds;
        [window addSubview:self];
    }else {
        self.frame = _superView.bounds;
        self.control.frame = _superView.bounds;
        self.playerLayer.frame = _superView.bounds;
        [_superView addSubview:self];
    }
}
#pragma mark 获取控制器类型
- (JJPlayerControlViewStyle)getPlayerControlStyle
{
    if (_type == JJ_PLayerTypeTypeDefault) {
        return JJPlayerControlViewStyleDefault;
    }else if (_type == JJ_PLayerTypeTypeOnlyVideo) {
        return JJPlayerControlViewStyleOnlyVideo;
    }else {
        return JJPlayerControlViewStyleShortVideo;
    }
}
@end
