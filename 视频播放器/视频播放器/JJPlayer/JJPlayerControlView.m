//
//  JJPlayerControlView.m
//  视频播放器
//
//  Created by 16 on 2018/6/8.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPlayerControlView.h"
#import "UIDevice+JJOrientation.h"
#import "JJPlayerMessageView.h"
#import <MediaPlayer/MediaPlayer.h>

#define sh self.frame.size.height
#define sw self.frame.size.width
#define h 20
@interface JJPlayerControlView ()

@property (nonatomic , strong) UIButton *backGround; // 底部背景视图
@property (nonatomic , strong) UIButton *back; // 返回按钮
@property (nonatomic , strong) UIImageView *loadingImg; // 播放出错提示图片
@property (nonatomic , strong) JJPlayerMessageView *messageView; // 进度提示图片
@property (nonatomic , strong) UIButton *playBtn; // 播放/暂停按钮
@property (nonatomic , strong) UIButton *moreBtn; // 全屏按钮
@property (nonatomic , strong) UIProgressView *progress; // 进度条
@property (nonatomic , strong) UISlider *slider; // 进度控制杆
@property (nonatomic , strong) UILabel *currentTime; // 当前播放时间
@property (nonatomic , strong) UILabel *allTime; // 总时长
@property (nonatomic , assign) NSInteger time; // 视频时长
@property (nonatomic , strong) UILabel *title; // 标题(后期滚动)
@property (nonatomic , strong) NSMutableArray <UIView*>*controls; // 子视图数组
@property (nonatomic , strong) UIPanGestureRecognizer *pan;// 移动手势
@property (nonatomic , assign) CGFloat endTime; // 最后修改后的时间
@property (nonatomic , strong) UISlider *volumeViewSlider; // 用来控制系统音量的slider
@property (nonatomic , strong)  MPVolumeView *volumeView;

@property (nonatomic , assign) BOOL isFull; // 是否是全屏格式
@property (nonatomic , assign) BOOL isEnter; // 是否切入到后台
@property (nonatomic , assign) BOOL isOnce; // 判断是否刚刚操作
@property (nonatomic , assign) BOOL isHandleLeft; // 是否在操作屏幕左侧
@property (nonatomic , assign) BOOL isHandleLevel; // 是否水平滑动
@property (nonatomic , assign) BOOL isHandleVertical; // 是否垂直滑动
@end
@implementation JJPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame controlStyle:(JJPlayerControlViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"style" options:NSKeyValueObservingOptionNew context:nil];
        self.style = style;
        
        // 获取系统音量
       self.volumeView = [[MPVolumeView alloc] init];
        _volumeViewSlider = nil;
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider *)view;
                break;
            }
        }
    }
    return self;
}
#pragma mark 加载提示
- (void)showLoading
{
    _loadingImg.image = [UIImage imageNamed:@"load"];
    _loadingImg.hidden = NO;
}
- (void)hiddenLoading
{
    _loadingImg.hidden = YES;
}
- (void)showError
{
    _loadingImg.image = [UIImage imageNamed:@"error"];
    _loadingImg.hidden = NO;
}
#pragma mark 设置进度条
- (void)setUpProgress:(CGFloat)progress
{
    [_progress setProgress:progress animated:NO];
}
#pragma mark 刷新控件样式
- (void)setUpSubViewsLayout
{
    // 设置视图尺寸
    if (_style == JJPlayerControlViewStyleDefault) {
        
        CGFloat y = sh-30;
        self.backGround.frame = self.bounds;
        self.playBtn.frame = CGRectMake(10, y, h, h);
        self.currentTime.frame = CGRectMake(30, y, 50, h);
        self.allTime.frame = CGRectMake(sw-80, y, 50, h);
        self.moreBtn.frame = CGRectMake(sw-30, y, h, h);
        self.loadingImg.frame = CGRectMake(0, 0, 50, 50);
        self.loadingImg.center = self.center;
        self.messageView.frame = CGRectMake(0, 0, self.frame.size.height/3, self.frame.size.height/4);
        self.messageView.center = self.center;
    }
}
#pragma mark 添加子视图
- (void)creatSubViews
{
    if (_style == JJPlayerControlViewStyleDefault) {
        
        // 添加视图
        [self addSubview:self.backGround];
        [self addSubview:self.loadingImg];
        [self addSubview:self.messageView];
        [self addSubview:self.playBtn];
        [self addSubview:self.currentTime];
        [self addSubview:self.progress];
        [self addSubview:self.slider];
        [self addSubview:self.allTime];
        [self addSubview:self.moreBtn];
        [self addSubview:self.title];
        [self addSubview:self.back];
        
        // 视图数组添加子视图
        self.controls = [NSMutableArray arrayWithObjects:_playBtn,_currentTime,_allTime,_moreBtn,_title,_back, nil];
    }else if (_style == JJPlayerControlViewStyleShortVideo)
    {
        // 添加视图
        [self addSubview:self.playBtn];
        [self addSubview:self.title];
        [self addSubview:self.progress];
        [self addSubview:self.slider];
        // 视图数组添加子视图
        self.controls = [NSMutableArray arrayWithObjects:_playBtn,_title,_progress,_slider, nil];
    }
}
#pragma mark 设置为被选中时视图布局
- (void)setUpNomalStatue
{
    if (_style == JJPlayerControlViewStyleDefault) {
        
        [_controls enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
        _title.frame = CGRectMake(10, 20, sw-20, 20);
        _slider.frame = CGRectMake(-5, sh-2, sw+10, 2);
        _progress.frame = CGRectMake(0, sh-2, sw, 2);
        _backGround.selected = NO;
        [self hiddenSilderThumbImage];
        _slider.userInteractionEnabled = NO;
        
    }else if (_style == JJPlayerControlViewStyleShortVideo)
    {
        // 添加视图
        [self addSubview:self.playBtn];
        [self addSubview:self.title];
        [self addSubview:self.progress];
        [self addSubview:self.slider];
        _playBtn.frame = CGRectMake(sw-50, sh-50, 30, 30);
        _title.frame = CGRectMake(10, sh-50, sw/2, 30);
        _progress.frame = CGRectMake(0, self.frame.size.height-2, sw, 2);
        _slider.frame = CGRectMake(0, self.frame.size.height-2, sw, 2);
        // 移除slider圆点
        [self hiddenSilderThumbImage];
        _slider.userInteractionEnabled = NO;
        // 显示视图
        [_controls enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = NO;
        }];
    }
}
#pragma mark 设置被选中时视图布局
- (void)setUpSelectedStatue
{
    if (_style == JJPlayerControlViewStyleDefault) {
        
        [_controls enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = NO;
        }];
        _back.frame = CGRectMake(0, 0, 0, 0);
        _title.frame = CGRectMake(10, 20, sw-20, 20);
        [_slider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        _slider.userInteractionEnabled = YES;
        _slider.frame = CGRectMake(80, sh-30, sw-160, 20);
        _progress.frame = CGRectMake(85, sh-21, sw-170, 2);
        _backGround.selected = YES;
    }
}
#pragma mark 设置全屏时视图布局
- (void)setUpFullStatue
{
    if (_style == JJPlayerControlViewStyleDefault) {
        
        [_controls enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = NO;
        }];
        _back.frame = CGRectMake(10, 20, 20, 20);
        _title.frame = CGRectMake(40, 20, sw-60, 20);
        [_slider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        _slider.userInteractionEnabled = YES;
        _slider.frame = CGRectMake(80, sh-30, sw-160, 20);
        _progress.frame = CGRectMake(85, sh-21, sw-170, 2);
        _backGround.selected = YES;
    }
}
#pragma mark slider点击事件
- (void)sliderTouchDown:(UISlider *)sender
{
    NSLog(@"按了slider");
    if ([self.delegate respondsToSelector:@selector(JJPlayerControlViewSliderWillChange)]) {
        [self.delegate JJPlayerControlViewSliderWillChange];
    }
}
- (void)sliderValueChanged:(UISlider *)sender
{
    CGFloat current = _time*sender.value;
    _currentTime.text = [NSString stringWithFormat:@"%02zd:%02zd", (NSInteger)current/60, (NSInteger)current%60];
}
- (void)sliderTouchEnd:(UISlider *)sender
{
    NSLog(@"slider停止滑动");
    if ([self.delegate respondsToSelector:@selector(JJPlayerControlViewSliderChangedEnd:)]) {
        [self.delegate JJPlayerControlViewSliderChangedEnd:_time*sender.value];
    }
}
- (void)setUpSlider:(float)current all:(float)all
{
    [_slider setValue:current/all animated:YES];
    _time = (NSInteger)all;
    _currentTime.text = [NSString stringWithFormat:@"%02zd:%02zd", (NSInteger)current/60, (NSInteger)current%60];
    _allTime.text = [NSString stringWithFormat:@"%02zd:%02zd", _time/60, _time%60];
}
#pragma mark 按钮点击事件
- (void)backGround:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (_isFull) {
            [self setUpFullStatue];
        }else {
            [self setUpSelectedStatue];
        }
    }else {
        [self setUpNomalStatue];
    }
}
- (void)back:(UIButton *)sender
{
    [self fullBtnClick:_moreBtn];
}
- (void)playBtnClick:(UIButton *)sender
{
    NSLog(@"播放或暂停");
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(JJPlayerControlViewPlayBtnClicked:)]) {
        [self.delegate JJPlayerControlViewPlayBtnClicked:sender.selected];
    }
}
- (void)fullBtnClick:(UIButton *)sender
{
    NSLog(@"全屏/小屏");
    sender.selected = !sender.selected;
    _isFull = sender.selected;
    if (_isFull) {
        [_backGround addGestureRecognizer:self.pan];
        [UIDevice setOrientation:UIInterfaceOrientationLandscapeRight];
    }else {
        [_backGround removeGestureRecognizer:self.pan];
        [UIDevice setOrientation:UIInterfaceOrientationPortrait];
    }
    if ([self.delegate respondsToSelector:@selector(JJPlayerControlViewFullBtnClicked:)]) {
        [self.delegate JJPlayerControlViewFullBtnClicked:sender.selected];
    }
    if (_isFull) {
        [self setUpFullStatue];
    }else {
        [self setUpSelectedStatue];
    }
}
#pragma mark 滑动手势操作
- (void)pan:(UIPanGestureRecognizer *)sender
{
    CGPoint translationPoint = [sender translationInView:_backGround];// 改变的距离 左，上为负值 ，右，下为正值
    CGPoint veloctyPoint = [sender velocityInView:_backGround];// 改变速率
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            
            self.isOnce = YES;
            _endTime = _slider.value;
            [self backGround:_backGround];
            CGPoint locationPoint = [sender locationInView:self.backGround]; // 当前的用户触摸的点
            // 判断用户点击左边屏幕还是右边屏幕
            if (locationPoint.x < self.frame.size.width/2) {
                self.isHandleLeft = YES;
            }else{
                self.isHandleLeft = NO;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            
            // 获取到当前点的绝对值
            int x = abs((int)translationPoint.x);
            int y = abs((int)translationPoint.y);
            
            // 如果有了滑动判断结果直接跳过
            if (self.isHandleLevel == self.isHandleVertical) {
                if (x!=0 || y!=0){ // 横向和纵向偏移量都不能为0
                    if (x > y) { // 判断是横向还是纵向
                        self.isHandleLevel = YES;
                        self.isHandleVertical = NO;
                    }else{
                        self.isHandleLevel = NO;
                        self.isHandleVertical = YES;
                    }
                }
            }
            
            // 设置水平滑动
            if (self.isHandleLevel) {
                
                _messageView.hidden = NO;
                if (veloctyPoint.x>0) {
                    [_messageView updateImg:@"快进"];
                }else if(veloctyPoint.x<0){
                    [_messageView updateImg:@"快退"];
                }
                if (_isOnce) {
                    if ([self.delegate respondsToSelector:@selector(JJPlayerControlViewSliderWillChange)]) {
                        [self.delegate JJPlayerControlViewSliderWillChange];
                    }
                }
                self.isOnce = NO;
                [_slider setValue:_slider.value+veloctyPoint.x/50000 animated:YES];
                CGFloat current = self.time * _slider.value;
                // 秒数和分钟数
                NSInteger proSec = (NSInteger)current % 60;
                NSInteger proMin = (NSInteger)current / 60;
                [_messageView updateMessage:[NSString stringWithFormat:@"%02zd:%02zd/%@", proMin, proSec,_allTime.text]];
            }else if (self.isHandleVertical) { // 这里可以设置音量和屏幕亮度
                
                if (self.isHandleLeft) {
                    
                    [UIScreen mainScreen].brightness -= translationPoint.y/3000;
                    if (translationPoint.y > 0) {
                        NSLog(@"正在右侧竖直向下滑动");
                    }else{
                        NSLog(@"正在右侧竖直向上滑动");
                    }
                }else{
                    self.volumeViewSlider.value -= translationPoint.y/8000;
                    if (translationPoint.y > 0) {
                        NSLog(@"正在左侧竖直向下滑动");
                    }else{
                        NSLog(@"正在左侧竖直向上滑动");
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            
            if (_isFull) {
                [self setUpFullStatue];
            }else {
                [self setUpSelectedStatue];
            }
            if (_endTime != 0) {
                if ([self.delegate respondsToSelector:@selector(JJPlayerControlViewSliderChangedEnd:)]) {
                    [self.delegate JJPlayerControlViewSliderChangedEnd:_time*_slider.value];
                }
            }
            [_messageView updateImg:@""];
            _messageView.hidden = YES;
            _playBtn.selected = NO;
            self.isHandleLevel = NO;
            self.isHandleVertical = NO;
            break;
        }
        case UIGestureRecognizerStatePossible: {
            
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            
            break;
        }
        case UIGestureRecognizerStateFailed: {
            
            break;
        }
    }
}
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        [self setUpSubViewsLayout];
    }
    if ([keyPath isEqualToString:@"style"]) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.controls = [NSMutableArray array];
        [self creatSubViews];
        [self setUpSubViewsLayout];
        [self setUpNomalStatue];
    }
}
#pragma mark 移除slider的圆
- (void)hiddenSilderThumbImage
{
    CGSize size=CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    UIRectFill(CGRectMake(0, 0, 1, 1));
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_slider setThumbImage:img forState:UIControlStateNormal];
}
#pragma mark 设置标题
- (void)setUpTitle:(NSString *)title
{
    _title.text = [NSString stringWithFormat:@"%@",title];
}
#pragma mark 懒加载
- (UIButton *)backGround
{
    if (_backGround == nil) {
        _backGround = [[UIButton alloc] init];
        [_backGround setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_backGround setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [_backGround addTarget:self action:@selector(backGround:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backGround;
}
- (UIButton *)back
{
    if (_back == nil) {
        _back = [[UIButton alloc] init];
        [_back setBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        [_back addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _back;
}
- (UIImageView *)loadingImg
{
    if (_loadingImg == nil) {
        _loadingImg = [[UIImageView alloc] init];
    }
    return _loadingImg;
}
- (JJPlayerMessageView *)messageView
{
    if (_messageView == nil) {
        _messageView = [[JJPlayerMessageView alloc] init];
        _messageView.hidden = YES;
    }
    return _messageView;
}
- (UIButton *)playBtn
{
    if (_playBtn == nil) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateSelected];
        _playBtn.selected = NO;
    }
    return _playBtn;
}
- (UIButton *)moreBtn
{
    if (_moreBtn == nil) {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn setImage:[UIImage imageNamed:@"全屏"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"小屏"] forState:UIControlStateSelected];
    }
    return _moreBtn;
}
- (UIProgressView *)progress
{
    if (_progress == nil) {
        _progress = [[UIProgressView alloc] init];
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(80, sh-26, sw-160, 1)];
        _progress.progressViewStyle = UIProgressViewStyleDefault;
        _progress.progressTintColor = [UIColor whiteColor];
        _progress.trackTintColor = [UIColor lightGrayColor];
    }
    return _progress;
}
- (UISlider *)slider
{
    if (_slider == nil) {
        _slider = [[UISlider alloc] init];
        [_slider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        _slider.minimumTrackTintColor = [UIColor redColor];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        // 设置slider属性
        [_slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    }
    return _slider;
}
- (UILabel *)currentTime
{
    if (_currentTime == nil) {
        _currentTime = [[UILabel alloc] init];
        _currentTime.textAlignment = NSTextAlignmentCenter;
        _currentTime.font = [UIFont systemFontOfSize:13];
        _currentTime.textColor = [UIColor whiteColor];
        _currentTime.text = @"00:00";
    }
    return _currentTime;
}
- (UILabel *)allTime
{
    if (_allTime == nil) {
        _allTime = [[UILabel alloc] init];
        _allTime.textAlignment = NSTextAlignmentCenter;
        _allTime.font = [UIFont systemFontOfSize:13];
        _allTime.textColor = [UIColor whiteColor];
        _allTime.text = @"00:00";
    }
    return _allTime;
}
- (UILabel *)title
{
    if (_title == nil) {
        _title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:22];
        _title.font = [UIFont boldSystemFontOfSize:22];
        _title.textColor = [UIColor whiteColor];
        _title.text = @"";
    }
    return _title;
}
- (UIPanGestureRecognizer *)pan
{
    if (_pan == nil) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    }
    return _pan;
}
@end
