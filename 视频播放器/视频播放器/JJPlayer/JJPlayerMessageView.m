//
//  JJPlayerMessageView.m
//  视频播放器
//
//  Created by 16 on 2018/6/14.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPlayerMessageView.h"

@interface JJPlayerMessageView ()

@property (nonatomic , strong) UIImageView *img;
@property (nonatomic , strong) UILabel *messageLab;
@end
@implementation JJPlayerMessageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self creatSubViews];
    }
    return self;
}
- (void)creatSubViews
{
    self.img = [[UIImageView alloc] init];
    [self addSubview:_img];
    self.messageLab = [[UILabel alloc] init];
    _messageLab.textAlignment = NSTextAlignmentCenter;
    _messageLab.textColor = [UIColor whiteColor];
    _messageLab.font = [UIFont systemFontOfSize:15];
    [self addSubview:_messageLab];
}
- (void)layoutSubviews
{
    self.img.frame = CGRectMake((self.frame.size.width-self.frame.size.height/2)/2, self.frame.size.height/6, self.frame.size.height/2, self.frame.size.height/3);
    self.messageLab.frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
}
- (void)updateImg:(NSString *)image
{
    self.img.image = [UIImage imageNamed:image];
}
- (void)updateMessage:(NSString *)message
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange range = [message rangeOfString:@"/"];
    //修改颜色
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, range.location)];
    
    self.messageLab.attributedText = string;
}
@end
