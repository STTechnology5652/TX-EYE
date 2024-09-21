//
//  RudderView.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/15.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "RudderView.h"
#import "JoyStickView.h"
#import "HTrimView.h"
#import "VTrimView.h"
#import <CoreMotion/CoreMotion.h>
#import "Settings.h"

#define H_TRIM_SCALE_NUMBER     24
#define V_TRIM_SCALE_NUMBER     24

#define DEVICE_MOTION_UPDATE_INTERVAL   0.02    // 传感器更新时间间隔

@interface RudderView () <JoyStickViewDelegate, HTrimViewDelegate, VTrimViewDelegate>
@property (nonatomic, strong) JoyStickView *joyStickView;
@property (nonatomic, strong) HTrimView *hTrimView;
@property (nonatomic, strong) VTrimView *vTrimView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation RudderView

+ (SInt32)hScaleNum
{
    return H_TRIM_SCALE_NUMBER;
}

+ (SInt32)vScaleNum
{
    return V_TRIM_SCALE_NUMBER;
}

/**
 *  设置Rudder样式
 *
 *  @param rudderStyle 样式
 */
- (void)setRudderStyle:(RudderStyle)rudderStyle
{
    _rudderStyle = rudderStyle;
    
    // 根据选择的不同样式，做不同的设置
    if (_rudderStyle == RudderStylePower) {
        self.joyStickView.joyStickStyle = JoyStickStylePower;
        _vTrimView.hidden = YES;
        _trimPoint = CGPointMake(0, 0);
        _basePoint = CGPointMake(0, -1);
        [_joyStickView moveStickTo:_basePoint];
    } else if (_rudderStyle == RudderStyleRanger) {
        self.joyStickView.joyStickStyle = JoyStickStyleRanger;
        _vTrimView.hidden = NO;
        _trimPoint = CGPointMake(0, 0);
        _basePoint = CGPointMake(0, 0);
        [_joyStickView moveStickTo:_basePoint];
    }
}

/**
 *  使能/禁能重力控制
 *
 *  @param useGravity 重力控制开关
 */
- (void)setUseGravity:(BOOL)useGravity
{
    _useGravity = useGravity;
    
    if (useGravity) {
        [_joyStickView setUserInteractionEnabled:NO];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = DEVICE_MOTION_UPDATE_INTERVAL;
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (error == nil) {
                // convert to corresponding interface orientation
                // the max abs(value) is 0.75
                double gravityX = motion.gravity.x / 0.75;
                double gravityY = -motion.gravity.y / 0.75;
                double r = sqrtf(gravityX * gravityX + gravityY * gravityY);
                
                // solved transboundary
                if (r > 1.0) {
                    double scale = r / 1.0;
                    gravityX /= scale;
                    gravityY /= scale;
                }
                
//                NSLog(@"sqrt = %lf", sqrtf(gravityX * gravityX + gravityY * gravityY));
//                NSLog(@"x = %lf, y = %lf", gravityX, gravityY);
                
                float hBaseValue = gravityY;
                float vBaseValue = gravityX;
                // Adjust to device orientation
//                if (self.orientation == UIDeviceOrientationLandscapeLeft) {
//                    hBaseValue = -hBaseValue;
//                    vBaseValue = -vBaseValue;
//                }
                
//                NSLog(@"sqrt = %lf", sqrtf(hBaseValue * hBaseValue + vBaseValue * vBaseValue));
//                NSLog(@"x = %lf, y = %lf", hBaseValue, vBaseValue);
                
                // move point
                _basePoint = CGPointMake(hBaseValue, vBaseValue);
                [_joyStickView moveStickTo:_basePoint];
                
                // Delegate Method
                if ([(id)_delegate respondsToSelector:@selector(rudderView:basePointMovedTo:)]) {
                    [_delegate rudderView:self basePointMovedTo:_basePoint];
                }
            }
        }];
    } else {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
        [_joyStickView moveStickTo:CGPointMake(0, 0)];
        [_joyStickView setUserInteractionEnabled:YES];
        if ([(id)_delegate respondsToSelector:@selector(rudderView:basePointMovedTo:)]) {
            [_delegate rudderView:self basePointMovedTo:CGPointMake(0, 0)];
        }
    }
}

/**
 *  Power锁定模式
 */
- (void)lockToHalfPowerMode
{
    if (self.rudderStyle == RudderStylePower) {
        _basePoint = CGPointMake(0, 0);
        [_joyStickView moveStickTo:_basePoint];
        if ([(id)_delegate respondsToSelector:@selector(rudderView:basePointMovedTo:)]) {
            [_delegate rudderView:self basePointMovedTo:_basePoint];
        }
        [_joyStickView setLockMode:YES];
    }
}

/**
 *  取消锁定Power
 */
- (void)unlockHalfPowerMode
{
    if (self.rudderStyle == RudderStylePower) {
        _basePoint = CGPointMake(0, -1);
        [_joyStickView moveStickTo:_basePoint];
        if ([(id)_delegate respondsToSelector:@selector(rudderView:basePointMovedTo:)]) {
            [_delegate rudderView:self basePointMovedTo:_basePoint];
        }
        [_joyStickView setLockMode:NO];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initRudder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        // Initialization code
        [self initRudder];
    }
    
    return self;
}

/**
 *  初始化Rudder
 */
- (void)initRudder
{
    CGFloat frameWidth = self.frame.size.width;
    CGFloat frameHeight = self.frame.size.height;
    // 取最小边，做正方形
    CGFloat minEdge = frameWidth < frameHeight ? frameWidth : frameHeight;
    
    CGRect joystickFrame;
    joystickFrame.size.width = minEdge;
    joystickFrame.size.height = minEdge;
    
    // 保留一些空间给微调使用
#define BLANK_EDGE      70.0   // 上下左右各留一半
#define BLANK_EDGE_2    (BLANK_EDGE / 2.0)
    if (minEdge > BLANK_EDGE) {
        joystickFrame.size.width = minEdge - BLANK_EDGE;
        joystickFrame.size.height = minEdge - BLANK_EDGE;
    }
    joystickFrame.origin.x = (frameWidth - joystickFrame.size.width) / 2.0;
    joystickFrame.origin.y = (frameHeight - joystickFrame.size.height) / 2.0;
    
    // 根据是否使用右手模式，做不同的配置
    BOOL isRightHandMode = [Settings getParameterForRightHandMode];
    CGRect hTrimViewFrame, vTrimViewFrame;
    
    hTrimViewFrame = CGRectMake(joystickFrame.origin.x, (frameHeight + joystickFrame.size.height) / 2.0, joystickFrame.size.width, BLANK_EDGE_2);
    if (isRightHandMode) {
        vTrimViewFrame = CGRectMake(joystickFrame.origin.x - BLANK_EDGE_2, (frameHeight - joystickFrame.size.height) / 2.0, BLANK_EDGE_2, joystickFrame.size.height);
    } else {
        vTrimViewFrame = CGRectMake(joystickFrame.origin.x + joystickFrame.size.width, (frameHeight - joystickFrame.size.height) / 2.0, BLANK_EDGE_2, joystickFrame.size.height);
    }
    
    // 配置操纵杆控件
    _joyStickView = [[JoyStickView alloc] initWithFrame:joystickFrame];
    _joyStickView.delegate = self;
    [self addSubview:_joyStickView];
    
    // 添加横向微调控件
    _hTrimView = [[HTrimView alloc] initWithFrame:hTrimViewFrame];
    _hTrimView.scaleNum = [self class].hScaleNum;
    _hTrimView.delegate = self;
    [self addSubview:_hTrimView];
    
    // 添加纵向微调控件
    _vTrimView = [[VTrimView alloc] initWithFrame:vTrimViewFrame];
    _vTrimView.scaleNum = [self class].vScaleNum;
    _vTrimView.delegate = self;
    [self addSubview:_vTrimView];
}

#pragma mark - JoyStickView Delegate

/**
 *  移动操纵杆的委托方法
 *
 *  @param joyStickView 操纵杆
 *  @param point        移动到的点
 */
- (void)joyStickView:(JoyStickView *)joyStickView moveToPoint:(CGPoint)point
{
    _basePoint = point;
    
    if ([(id)_delegate respondsToSelector:@selector(rudderView:hBaseValueChanged:)]) {
        [_delegate rudderView:self hBaseValueChanged:_basePoint.x];
    }
    if ([(id)_delegate respondsToSelector:@selector(rudderView:vBaseValueChanged:)]) {
        [_delegate rudderView:self vBaseValueChanged:_basePoint.y];
    }
    if ([(id)_delegate respondsToSelector:@selector(rudderView:basePointMovedTo:)]) {
        [_delegate rudderView:self basePointMovedTo:_basePoint];
    }
}

#pragma mark - TrimView Delegate

/**
 *  横向微调控件的委托方法
 *
 *  @param hTrimView 横向微调控件
 *  @param value     微调值
 */
- (void)hTrimView:(HTrimView *)hTrimView valueChanged:(float)value
{
    _trimPoint.x = value;
    
    if ([(id)_delegate respondsToSelector:@selector(rudderView:hTrimValueChanged:)]) {
        [_delegate rudderView:self hTrimValueChanged:value];
    }
    if ([(id)_delegate respondsToSelector:@selector(rudderView:trimPointMovedTo:)]) {
        [_delegate rudderView:self trimPointMovedTo:_trimPoint];
    }
    
    // Parameter Autosave
    BOOL autosave = [Settings getParameterForAutosave];
    if (autosave) {
        // 不同样式下重置为不同值
        if (self.rudderStyle == RudderStylePower) {
            [Settings saveParameterForTrimRUDD:hTrimView.scaleValue];
        }
        else if (self.rudderStyle == RudderStyleRanger) {
            [Settings saveParameterForTrimAIL:hTrimView.scaleValue];
        }
    }
}

/**
 *  纵向微调控件的委托方法
 *
 *  @param vTrimView 纵向微调控件
 *  @param value     微调值
 */
- (void)vTrimView:(VTrimView *)vTrimView valueChanged:(float)value
{
    _trimPoint.y = value;
    
    if ([(id)_delegate respondsToSelector:@selector(rudderView:vTrimValueChanged:)]) {
        [_delegate rudderView:self vTrimValueChanged:value];
    }
    if ([(id)_delegate respondsToSelector:@selector(rudderView:trimPointMovedTo:)]) {
        [_delegate rudderView:self trimPointMovedTo:_trimPoint];
    }
    
    // Parameter Autosave
    BOOL autosave = [Settings getParameterForAutosave];
    if (autosave) {
        // 不同样式下重置为不同值
        if (self.rudderStyle == RudderStyleRanger) {
            [Settings saveParameterForTrimELE:vTrimView.scaleValue];
        }
    }
}

#pragma mark - Reset

/**
 *  重置操纵杆
 */
- (void)reset
{
    // 不同样式下重置为不同值
    if (self.rudderStyle == RudderStylePower) {
        if (_joyStickView.lockMode) {
            _basePoint = CGPointMake(0, 0);
        } else {
            _basePoint = CGPointMake(0, -1);
        }
    }
    else if (self.rudderStyle == RudderStyleRanger) {
        _basePoint = CGPointMake(0, 0);
    }
    // 移动摇杆
    [_joyStickView moveStickTo:_basePoint];
    // 调用Rudder委托方法
    if ([(id)_delegate respondsToSelector:@selector(rudderView:basePointMovedTo:)]) {
        [_delegate rudderView:self basePointMovedTo:_basePoint];
    }
    if ([(id)_delegate respondsToSelector:@selector(rudderView:hBaseValueChanged:)]) {
        [_delegate rudderView:self hBaseValueChanged:_basePoint.x];
    }
    if ([(id)_delegate respondsToSelector:@selector(rudderView:vBaseValueChanged:)]) {
        [_delegate rudderView:self vBaseValueChanged:_basePoint.y];
    }
    
    // 复位TrimValue
    NSInteger hTrimValue = 0;
    NSInteger vTrimValue = 0;
    // Parameter Autosave
    BOOL autosave = [Settings getParameterForAutosave];
    if (autosave) {
        // 不同样式下重置为不同值
        if (self.rudderStyle == RudderStylePower) {
            hTrimValue = [Settings getParameterForTrimRUDD];
        }
        else if (self.rudderStyle == RudderStyleRanger) {
            hTrimValue = [Settings getParameterForTrimAIL];
            vTrimValue = [Settings getParameterForTrimELE];
        }
    }
    [_hTrimView setScaleValue:(SInt32)hTrimValue];
    [_vTrimView setScaleValue:(SInt32)vTrimValue];
}

#pragma mark - Move stick (public)

- (void)moveStickTo:(CGPoint)deltaToCenter
{
    CGFloat x = deltaToCenter.x;
    CGFloat y = deltaToCenter.y;
    
    if ((x >= -1.0 && x <= 1.0)
        && (y >= -1.0 && y <= 1.0)) {
        [self joyStickView:nil moveToPoint:deltaToCenter];
        [_joyStickView moveStickTo:deltaToCenter];
    }
}

@end
