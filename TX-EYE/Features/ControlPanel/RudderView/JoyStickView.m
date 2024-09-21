//
//  VisualStickView.m
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import "JoyStickView.h"
#import "Config.h"

#define DIFF_R_IO                   12.0    // 内外径差
#define STICK_TRANSPARENT_R         4.0     // 小球边缘透明像素点
#define INCIRCLE_LEN                (minEdge / 2.)  // 内切圆半径
// 活动半径大小，除去内外径差、小球半径和小球图的透明像素，并考虑缩放后的内切圆半径
#define STICK_CENTER_TARGET_POS_LEN (INCIRCLE_LEN - (DIFF_R_IO + imgStick.size.width / 2. - STICK_TRANSPARENT_R) * scaleNum)

@implementation JoyStickView
{
    UIImageView *stickViewBase;
    UIImageView *stickView;
    
    UIImage *imgStick;
    
    UIImage *imgRudderPower;
    UIImage *imgRudderRanger;
    
    CGPoint mCenter;
    CGFloat minEdge;
    CGFloat scaleNum;
    
    CGPoint dtarget, dir;   // 前者是实际坐标点，内部使用；后者换算成单位坐标点，用作对外输出
    CGPoint lockedPoint;
    
    // 控制状态
    BOOL controlling;
    NSTimer *controlTimer;
}

/**
 *  设置joyStick样式
 *
 *  @param joyStickStyle joyStick样式
 */
- (void)setJoyStickStyle:(JoyStickStyle)joyStickStyle
{
    _joyStickStyle = joyStickStyle;
    // 根据不同的样式选择不同的背景图
    if (_joyStickStyle == JoyStickStylePower) {
        stickViewBase.image = imgRudderPower;
    } else if (_joyStickStyle == JoyStickStyleRanger) {
        stickViewBase.image = imgRudderRanger;
    }
}

/**
 *  设置锁定模式
 *
 *  @param lockMode 锁定模式开关
 */
- (void)setLockMode:(BOOL)lockMode
{
    _lockMode = lockMode;
    if (_lockMode) {
        // 设置锁定时的值
        lockedPoint = dir;
    }
}

/**
 *  设置轨迹模式
 *
 *  @param lockMode 轨迹模式开关
 */
- (void)setTrackMode:(BOOL)trackMode
{
    if (_joyStickStyle == JoyStickStyleRanger) {
        _trackMode = trackMode;
    }
}

/**
 *  设置摇杆
 */
-(void)initStick
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    // 取宽高的最小值，即所绘制的图像在一个正方形里边
    minEdge = width < height ? width : height;
    CGRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width = minEdge;
    rect.size.height = minEdge;
    
    // 计算中点
    mCenter.x = minEdge / 2.;
    mCenter.y = minEdge / 2.;
    
    // 设置控制盘图
    imgRudderPower = [UIImage imageNamed:@"rudder_power"];
    imgRudderRanger = [UIImage imageNamed:@"rudder_ranger"];
    
    // 设置背景图
    stickViewBase = [[UIImageView alloc] initWithFrame:rect];
    // 根据不同的样式选择不同的背景图
    if (_joyStickStyle == JoyStickStylePower) {
        stickViewBase.image = imgRudderPower;
    } else if (_joyStickStyle == JoyStickStyleRanger) {
        stickViewBase.image = imgRudderRanger;
    }
    [self addSubview:stickViewBase];
    // 计算缩放大小
    scaleNum = minEdge / stickViewBase.image.size.width;
    
    // 配置遥控小球
    imgStick = [UIImage imageNamed:@"bar"];
    CGRect stickBounds = CGRectMake(0, 0, imgStick.size.width * scaleNum, imgStick.size.height * scaleNum);
    stickView = [[UIImageView alloc] init];
    stickView.image = imgStick;
    stickView.bounds = stickBounds;
    stickView.center = mCenter;
    [self addSubview:stickView];
    
    controlling = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStick];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
        // Initialization code
        [self initStick];
    }
	
    return self;
}

/**
 *  调用委托，通知
 *
 *  @param pDir 坐标
 */
//- (void)notifyDir:(CGPoint)pDir
//{
//    // Notification
////    NSValue *vdir = [NSValue valueWithCGPoint:pDir];
////    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
////                              vdir, @"dir", nil];
//////    NSLog(@"%@", vdir);
////    
////    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
////    [notificationCenter postNotificationName:@"StickChanged" object:nil userInfo:userInfo];
//    
//    // Delegate Method
//    CGPoint pt = CGPointMake(pDir.x, -pDir.y);
//    if ([(id)_delegate respondsToSelector:@selector(joyStickView:moveToPoint:)]) {
//        [_delegate joyStickView:self moveToPoint:pt];
//    }
//}

/**
 *  调用委托通知
 *  使用实例变量dir
 */
- (void)notifyCoordinate
{
    CGPoint pt = CGPointMake(dir.x, -dir.y);
    if ([(id)_delegate respondsToSelector:@selector(joyStickView:moveToPoint:)]) {
        [_delegate joyStickView:self moveToPoint:pt];
    }
}

/**
 *  Move stick to point
 *
 *  @param deltaToCenter Point
 */
- (void)stickMoveTo:(CGPoint)deltaToCenter
{
    CGPoint pt = stickView.center;
    pt.x = deltaToCenter.x + mCenter.x;
    pt.y = deltaToCenter.y + mCenter.y;
    stickView.center = pt;
}

/**
 *  触摸事件处理
 *
 *  @param touches 触摸集合
 */
- (void)touchEvent:(NSSet *)touches
{
    if([touches count] != 1)
        return ;
    
    // 如果没点击在视图内，则不作任何处理
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    // 如果点击在视图内，则获取触摸点坐标，并用于计算
    CGPoint touchPoint = [touch locationInView:view];
    dir.x = touchPoint.x - mCenter.x;   // offset x
    dir.y = touchPoint.y - mCenter.y;   // offset y
    dtarget.x = dir.x;
    dtarget.y = dir.y;
    double len = sqrt(dir.x * dir.x + dir.y * dir.y);
    
    // 如果第一次TouchDown触摸范围不在圆内，则不处理
    if (len > minEdge / 2. && controlling == NO) {
        if (controlTimer != nil) {
            [controlTimer invalidate];
            controlTimer = nil;
        }
        return;
    }
    controlling = YES;
    
    double len_inv = (1.0 / len);
    CGFloat xScale = dir.x * len_inv;
    CGFloat yScale = dir.y * len_inv;
    
    // 越界检查
    if (len > STICK_CENTER_TARGET_POS_LEN || len < -STICK_CENTER_TARGET_POS_LEN) {
        dtarget.x = xScale * STICK_CENTER_TARGET_POS_LEN;
        dtarget.y = yScale * STICK_CENTER_TARGET_POS_LEN;
        dir.x /= len;
        dir.y /= len;
    }
    else {
        dir.x /= STICK_CENTER_TARGET_POS_LEN;
        dir.y /= STICK_CENTER_TARGET_POS_LEN;
    }
    
    // 轨迹模式下处理方法
//    BOOL pointInCenter = (dtarget.x < 1.0 && dtarget.y < 1.0);  // 1个点的容差
//    if (_trackMode == YES && !pointInCenter
//        && _joyStickStyle == JoyStickStyleRanger) {
//        float x = dtarget.x;
//        float y = -dtarget.y;
//        float r = atan2(y, x);
//        if (r < 0) r += (M_PI * 2); // (-π, π] -> [0, 2π)
//        float c = cos(r);
//        float s = sin(r);
////        NSLog(@"rrrrrrrr: atan2 = %f, cos = %f, sin = %f", r, c, s);
//        
//        // 控件输出
//        dir.x = c;
//        dir.y = s;
//        // 控件图像绘制使用
//        dtarget.x = STICK_CENTER_TARGET_POS_LEN * c;
//        dtarget.y = -STICK_CENTER_TARGET_POS_LEN * s;
//    }
    
    // 移动摇杆小圆球
    [self stickMoveTo:dtarget];
    
    // 通知
//    [self notifyDir:dir];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (controlTimer == nil) {
        controlTimer = [NSTimer scheduledTimerWithTimeInterval:CONTROL_INTERVAL     // 输出间隔，与飞控输出同步好了
                                                        target:self
                                                      selector:@selector(notifyCoordinate)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    
    [self touchEvent:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (controlling)
        [self touchEvent:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self finishTouch];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self finishTouch];
}

- (void)finishTouch
{
    if (controlTimer != nil) {
        [controlTimer invalidate];
        controlTimer = nil;
    }
    
    if (!controlling)
        return;
    
    controlling = NO;
    
    // 根据不同的样式，在触摸结束后，复位不同的摇杆方向
    dir.x = dtarget.x = 0.0;
    if (_joyStickStyle == JoyStickStyleRanger) {
        dir.y = dtarget.y = 0.0;
    }
    if (_joyStickStyle == JoyStickStylePower) {
        if (self.lockMode) {
            dir.y = dtarget.y = 0.0;
        }
    }
    // 移动摇杆小圆球
    [self stickMoveTo:dtarget];
    
    // 通知
//    [self notifyDir:dir];
    [self notifyCoordinate];
}

#pragma mark - Public Interface

/**
 *  Move stick according to scale
 *  y取反是因为图像布局上为小，而相对操控界面为大，正好相反
 *
 *  @param deltaToCenter Scale
 */
- (void)moveStickTo:(CGPoint)deltaToCenter
{
    CGPoint pt = stickView.center;
    CGPoint deltaPoint = deltaToCenter;
    pt.x = deltaPoint.x * STICK_CENTER_TARGET_POS_LEN + mCenter.x;
    pt.y = -deltaPoint.y * STICK_CENTER_TARGET_POS_LEN + mCenter.y;
    stickView.center = pt;
}

@end
