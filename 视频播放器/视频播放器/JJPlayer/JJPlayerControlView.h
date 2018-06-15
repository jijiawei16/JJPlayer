//
//  JJPlayerControlView.h
//  视频播放器
//
//  Created by 16 on 2018/6/8.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , JJPlayerControlViewStyle) {
    JJPlayerControlViewStyleDefault = 0, // 基本播放器,可以全屏播放,有屏幕手势操作
    JJPlayerControlViewStyleOnlyVideo = 1, // 只有图像,可以用作启动视频
    JJPlayerControlViewStyleShortVideo = 2, // 短视频模式
};

@protocol JJPlayerControlViewDelegate <NSObject>

/*
 * slider被按下的时候
 */
- (void)JJPlayerControlViewSliderWillChange;

/*
 * slider操作结束
 */
- (void)JJPlayerControlViewSliderChangedEnd:(CGFloat)current;

/*
 * 点击了播放与暂停按钮
 */
- (void)JJPlayerControlViewFullBtnClicked:(BOOL)full;

/*
 * 全屏/小屏
 */
- (void)JJPlayerControlViewPlayBtnClicked:(BOOL)a;
@end
@interface JJPlayerControlView : UIView

// 代理
@property (nonatomic , weak) id<JJPlayerControlViewDelegate>delegate;
// 类型
@property (nonatomic , assign) JJPlayerControlViewStyle style;
/*
 * 显示加载视图
 */
- (void)showLoading;

/*
 * 隐藏加载视图
 */
- (void)hiddenLoading;

/*
 * 显示播放失败视图
 */
- (void)showError;

/*
 * 设置缓冲进度
 */
- (void)setUpProgress:(CGFloat)progress;

/*
 * 设置slider进度
 */
- (void)setUpSlider:(float)current all:(float)all;

/*
 * 设置播放器样式
 */
- (instancetype)initWithFrame:(CGRect)frame controlStyle:(JJPlayerControlViewStyle)style;

/*
 * 设置视频标题
 */
- (void)setUpTitle:(NSString *)title;
@end
