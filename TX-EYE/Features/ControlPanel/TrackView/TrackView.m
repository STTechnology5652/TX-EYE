//
//  TrackView.m
//  TX-EYE
//
//  Created by CoreCat on 2017/1/3.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "TrackView.h"
#import "TrackCanvasView.h"
#import "TouchPointPU.h"
#import "TrackPoint.h"
#import "Config.h"

#define TRACK_UPDATE_INTERVAL   CONTROL_INTERVAL    // 飞机轨迹更新间隔，现在使用和飞控指令一样的间隔

@interface TrackView () <TrackCanvasViewDelegate, TouchPointPUDelegate>
@property (nonatomic, strong) TrackCanvasView *canvasView;
@property (nonatomic, strong) TouchPointPU *touchPointPU;
@property (nonatomic, strong) UIView *aircraftView;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, strong) NSTimer *taskTimer;
@property (nonatomic, assign) int index;
@end

@implementation TrackView

- (void)setSpeedLevel:(int)speedLevel
{
    NSAssert(speedLevel >= 0 && speedLevel <= 2, @"TrackView: speedLevel is not in [0, 2]");
    
    _speedLevel = speedLevel;
    
    int flyTime;
    switch (_speedLevel) {
        case 0: // 30%
            flyTime = 10;
            break;
        case 1: // 60%
            flyTime = 6;
            break;
        case 2: // 100%
            flyTime = 4;
            break;
            
        default:
            flyTime = 10;
            break;
    }
    
    CGFloat perUnitLength = _canvasView.frame.size.width / flyTime * TRACK_UPDATE_INTERVAL;
    [_touchPointPU setPerUnitLength:perUnitLength];
    
    NSLog(@"TrackView: setSpeedLevel: %d, flyTime: %d, unit: %f", _speedLevel, flyTime, perUnitLength);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 画布
        CGFloat minEdge = MIN(frame.size.width, frame.size.height);
        CGFloat cx = (frame.size.width - minEdge) / 2.0;
        CGFloat cy = (frame.size.height - minEdge) / 2.0;
        CGRect canvasFrame = CGRectMake(cx, cy, minEdge, minEdge);
        _canvasView = [[TrackCanvasView alloc] initWithFrame:canvasFrame];
        [self addSubview:_canvasView];
        _canvasView.delegate = self;
        
        // 数据处理单元
        _touchPointPU = [[TouchPointPU alloc] init];
        _touchPointPU.delegate = self;
        
        // Aircraft
        _aircraftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _aircraftView.backgroundColor = [UIColor redColor];
        [self addSubview:_aircraftView];
        _aircraftView.layer.cornerRadius = 5;
        [_aircraftView setHidden:YES];
        
        // 范围外的图形不显示
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)reset
{
    // 重置，清除当前轨迹
    if (_taskTimer != nil) {
        [_taskTimer invalidate];
        _taskTimer = nil;
    }
    [_aircraftView setHidden:YES];
    [_canvasView reset];
    // 代理通知，完成输出
    [self onFinishOutput];
}

- (void)onBeginOutput
{
    if ([(id)_delegate respondsToSelector:@selector(trackViewBeginOutput:)]) {
        [_delegate trackViewBeginOutput:self];
    }
}

- (void)onOutputPoint:(CGPoint)point
{
    if ([(id)_delegate respondsToSelector:@selector(trackView:outputPoint:)]) {
        [_delegate trackView:self outputPoint:point];
    }
}

- (void)onFinishOutput
{
    if ([(id)_delegate respondsToSelector:@selector(trackViewFinishOutput:)]) {
        [_delegate trackViewFinishOutput:self];
    }
}

#pragma mark - TrackCanvasView Delegate

- (void)trackCanvasViewWillDraw:(TrackCanvasView *)canvasView
{
    // 准备开始新的轨迹，清除当前轨迹
    [self reset];
}

- (void)trackCanvasView:(TrackCanvasView *)canvasView
            drawnPoints:(NSArray<TouchPoint *> *)points
{
    // 开始处理触摸点
    [_touchPointPU processTouchPoints:points];
}

#pragma mark - TouchPointPU Delegate

- (void)beginProcessingPoint:(TouchPointPU *)ppu
{
    // 代理通知，准备输出
    [self onBeginOutput];
    
    // 先放到一个看不见的地方
    _aircraftView.center = CGPointMake(-20, -20);
    [_aircraftView setHidden:NO];
    
    // 输出定时器
    _taskTimer = [NSTimer scheduledTimerWithTimeInterval:TRACK_UPDATE_INTERVAL
                                                  target:self
                                                selector:@selector(timerTask:)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - Timer Task

- (void)timerTask:(NSTimer *)timer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        TrackPoint *currentPoint = [_touchPointPU dequeueTrackPoint];
        if (currentPoint != nil) {
            // 飞行器显示的位置
            CGFloat lx = _canvasView.frame.origin.x + currentPoint.x;
            CGFloat ly = _canvasView.frame.origin.y + currentPoint.y;
            _aircraftView.center = CGPointMake(lx, ly);
            
            //        NSLog(@">>> ux = %f, uy = %f", currentPoint.ux, currentPoint.uy);
            
            CGPoint point = CGPointMake(currentPoint.ux, currentPoint.uy);
            [self onOutputPoint:point];
        }
        else {
            // 完成当前轨迹飞行，清除当前轨迹
            [self reset];
        }
    });
}

@end
