//
//  UIDevice+JJOrientation.h
//  视频播放器
//
//  Created by 16 on 2018/6/12.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (JJOrientation)

/**
 *  强制旋转设备
 *  orientation : 旋转方向
 */
+ (void)setOrientation:(UIInterfaceOrientation)orientation;
@end
