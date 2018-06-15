//
//  JJPlayerManager.h
//  视频播放器
//
//  Created by 16 on 2018/6/7.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JJPlayerManagerPlayFinishedCallback)(void);
typedef NS_ENUM(NSInteger , JJ_PLayerType) {
    JJ_PLayerTypeTypeDefault = 0, // 基本播放器,可以全屏播放,有屏幕手势操作
    JJ_PLayerTypeTypeOnlyVideo = 1, // 只有图像,可以用作启动视频
    JJ_PLayerTypeTypeShortVideo = 2, // 短视频模式
};
@interface JJPlayerManager : UIView

@property (nonatomic , copy) JJPlayerManagerPlayFinishedCallback block;

/*
 * 添加视图
 */
+ (void)showOnView:(UIView *)view url:(NSURL *)url title:(NSString *)title type:(JJ_PLayerType)type complete:(JJPlayerManagerPlayFinishedCallback)complete;

/*
 * 转换父视图
 */
+ (void)showOnView:(UIView *)view type:(JJ_PLayerType)type;

/*
 * 播放器开始播放
 */
+ (void)play;

/*
 * 播放器停止播放
 */
+ (void)pause;

/*
 * 释放播放器
 */
+ (void)remove;

/*
 * 判断播放器是否在播放
 */
+ (BOOL)isPlaying;
@end
