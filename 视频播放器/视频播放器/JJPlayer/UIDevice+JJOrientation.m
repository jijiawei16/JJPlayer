//
//  UIDevice+JJOrientation.m
//  视频播放器
//
//  Created by 16 on 2018/6/12.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "UIDevice+JJOrientation.h"

@implementation UIDevice (JJOrientation)

//调用私有方法实现
+ (void)setOrientation:(UIInterfaceOrientation)orientation {
    
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[self currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}

@end
