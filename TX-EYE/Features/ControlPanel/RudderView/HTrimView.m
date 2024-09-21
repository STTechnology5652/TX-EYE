//
//  HTrimView.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/18.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "HTrimView.h"
#import <AudioToolbox/AudioToolbox.h>

// 因为要计算缩放，所以使用了素材的一些宽高值
//#define Background_Width    204
//#define Blank_Width         0
//#define Blank_Height        0
//#define Trim_Width          16
//#define Sign_Width          27
//#define Original_Width      (Trim_Width * 2 + Background_Width + Blank_Width * 2)
//#define Original_Height     (24)

#define Default_ScaleNum    24  // 左右的刻度数

@implementation HTrimView
{
    UIImageView *trimBackgroundView;
    UIImageView *trimSignView;
    
    UIImage *trimBackgroundImage;
    UIImage *trimSignImage;
    
    CGFloat scale;
    
    CGFloat barX;
    CGFloat barY;
    CGFloat offsetPerScale;
}

/**
 *  设置当前刻度值
 *
 *  @param scaleValue 需要设置的刻度值
 */
- (void)setScaleValue:(SInt32)scaleValue
{
    _scaleValue = scaleValue;
    // 检查越界
    if (_scaleValue > _scaleNum) _scaleValue = _scaleNum;
    if (_scaleValue < -_scaleNum) _scaleValue = -_scaleNum;
    // 绘图
    [self pointToScaleValue:_scaleValue];
    
    [self updateView];
}

/**
 *  获取当前值[-1, 1]
 *
 *  @return 当前值
 */
- (float)value
{
    return (float)_scaleValue / (float)_scaleNum;
}

/**
 *  设置刻度数
 *
 *  @param scaleNum 刻度数
 */
- (void)setScaleNum:(SInt32)scaleNum
{
    _scaleNum = scaleNum;
    
    offsetPerScale = trimBackgroundImage.size.width * scale / (scaleNum * 2);
    [self pointToScaleValue:(_scaleValue = 0)];
}

/**
 *  初始化微调控件
 */
- (void)initTrim
{
    CGFloat frameWidth = self.bounds.size.width;
    CGFloat frameHeight = self.bounds.size.height;
    
    // 载入控件图像
    trimBackgroundImage = [UIImage imageNamed:@"hslider"];
    trimSignImage = [UIImage imageNamed:@"bar"];
    // 根据background和bar确定算出最大的尺寸，用来计算缩放
    CGFloat backgroundWidth = trimBackgroundImage.size.width;
    CGFloat backgroundheight = trimBackgroundImage.size.height;
    CGFloat barWidth = trimSignImage.size.width;
    CGFloat barHeight = trimSignImage.size.height;
    CGFloat maxWidth = backgroundWidth + barWidth;
    CGFloat maxHeight = backgroundheight > barHeight ? backgroundheight : barHeight;
    
    // 计算宽高的缩放
    CGFloat widthScale = frameWidth / maxWidth;
    CGFloat heightScale = frameHeight / maxHeight;
    scale = widthScale < heightScale ? widthScale : heightScale;
    
    // 进行缩放后的background和bar的尺寸
    backgroundWidth *= scale;
    backgroundheight *= scale;
    barWidth *= scale;
    barHeight *= scale;
    
    // 设置微调背景
    trimBackgroundView = [[UIImageView alloc] initWithImage:trimBackgroundImage];
    trimBackgroundView.frame = CGRectMake((frameWidth - backgroundWidth) / 2.0, (frameHeight - backgroundheight) / 2.0, backgroundWidth, backgroundheight);
    
    // 设置微调标记
    barX = (frameWidth - barWidth) / 2;
    barY = (frameHeight - barHeight) / 2;
    trimSignView = [[UIImageView alloc] initWithImage:trimSignImage];
    trimSignView.frame = CGRectMake(barX, barY, barWidth, barHeight);
    
    // 添加到视图中
    [self addSubview:trimBackgroundView];
    [self addSubview:trimSignView];
    
    // 为了去掉左右微调按钮添加的
    trimBackgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *r = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [trimBackgroundView addGestureRecognizer:r];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTrim];
        self.scaleNum = Default_ScaleNum;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/**
 *  移动微调标记
 *
 *  @param scaleValue 当前刻度值
 */
- (void)pointToScaleValue:(SInt32)scaleValue
{
    CGFloat offset = offsetPerScale * scaleValue;
    
    CGRect frame = trimSignView.frame;
    frame.origin.x = barX + offset;
    trimSignView.frame = frame;
}

/**
 *  点击事件
 *
 *  @param r UITapGestureRecognizer
 */
- (void)tapGesture:(UITapGestureRecognizer *)r
{
    CGFloat locX = [r locationInView:trimBackgroundView].x;
    CGFloat width2 = trimBackgroundView.bounds.size.width / 2.0;
    if (locX < width2) {
        // 判断是否越界
        if (_scaleValue > -_scaleNum) {
            _scaleValue--;
        }
    } else {
        // 判断是否越界
        if (_scaleValue < _scaleNum) {
            _scaleValue++;
        }
    }
    
    [self updateView];
    [self playSound];
}

- (void)updateView
{
    // 移动微调标记
    [self pointToScaleValue:_scaleValue];
    
    // 调用代理方法
    if ([(id)_delegate respondsToSelector:@selector(hTrimView:valueChanged:)]) {
        [_delegate hTrimView:self valueChanged:self.value];
    }
}

- (void)playSound
{
    // 根据微调标记的位置，播放不同的声音
    if (_scaleValue == 0 || _scaleValue == -_scaleNum || _scaleValue == _scaleNum) {
        // Play do-doh sound
        AudioServicesPlaySystemSound(1255);
    } else {
        // Play tweet sound
        AudioServicesPlaySystemSound(1016);
    }
}

@end
