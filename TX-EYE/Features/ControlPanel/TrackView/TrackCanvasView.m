//
//  TrackCanvasView.m
//  TX-EYE
//
//  Created by CoreCat on 2017/1/12.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "TrackCanvasView.h"

@interface TrackCanvasView ()
@property (nonatomic, strong) NSMutableArray<TouchPoint *> *points;
@property (nonatomic, assign) BOOL cancelled;
@end

@implementation TrackCanvasView

- (NSMutableArray<TouchPoint *> *)points
{
    if (_points == nil) {
        _points = [NSMutableArray array];
    }
    return _points;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 背景颜色
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat viewWidth = self.bounds.size.width;
        CGFloat viewHeight = self.bounds.size.height;
        
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.bounds = CGRectMake(0, 0, viewWidth, viewHeight);
        borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;
        borderLayer.lineWidth = 1.;
        // 虚线边框
        borderLayer.lineDashPattern = @[@4, @4];
        // 实线边框
//        borderLayer.lineDashPattern = nil;
        // 填充颜色
//        borderLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        // 边框颜色
        borderLayer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.8].CGColor;
        [self.layer addSublayer:borderLayer];
    }
    return self;
}

- (void)reset
{
    _points = [NSMutableArray array];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([touches count] != 1)
        return ;
    
    // 如果没点击在视图内，则不作任何处理
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return;
    
    // 预处理通知
    [self onCanvasViewWillDraw];
    
    // 如果点击在视图内，则获取触摸点坐标，并用于计算
    CGPoint touchPoint = [touch locationInView:view];
    
    _points = [NSMutableArray array];
    [_points addObject:[TouchPoint pointWithPoint:touchPoint]];
    
    _cancelled = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_cancelled == YES)
        return;
    
    if([touches count] != 1)
        return;
    
    // 如果没点击在视图内，则不作任何处理
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return;
    
    // 如果点击在视图内，则获取触摸点坐标，并用于计算
    CGPoint touchPoint = [touch locationInView:view];

    if (touchPoint.x < 0 || touchPoint.y < 0
        || touchPoint.x > self.bounds.size.width
        || touchPoint.y > self.bounds.size.height) {
        _cancelled = YES;
    }
    else {
        [_points addObject:[TouchPoint pointWithPoint:touchPoint]];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([touches count] != 1)
        return;
    
    if (_cancelled == NO && self.points.count > 1) {
        // 绘图结束，输出
        [self onDrawnPoints:self.points];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _cancelled = YES;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (_cancelled == YES)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0f);
    
    TouchPoint *lastPoint = nil;
    TouchPoint *currPoint = nil;
    for (TouchPoint *point in _points) {
        
        currPoint = point;
        if (lastPoint != nil) {
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);    // start at this point
            CGContextAddLineToPoint(context, currPoint.x, currPoint.y); // draw to this point
        }
        lastPoint = currPoint;
    }
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

- (void)onCanvasViewWillDraw
{
    if ([(id)_delegate respondsToSelector:@selector(trackCanvasViewWillDraw:)]) {
        [_delegate trackCanvasViewWillDraw:self];
    }
}

- (void)onDrawnPoints:(NSArray<TouchPoint *> *)points
{
    if ([(id)_delegate respondsToSelector:@selector(trackCanvasView:drawnPoints:)]) {
        [_delegate trackCanvasView:self drawnPoints:points];
    }
}

@end
