//
//  TouchPointPU.m
//  TX-EYE
//
//  Created by CoreCat on 2017/1/12.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "TouchPointPU.h"

@interface TouchPointPU ()
@property (nonatomic, strong) NSMutableArray<TrackPoint *> *trackPoints;
@property (nonatomic, strong) TrackPoint *currentPoint;
@end

@implementation TouchPointPU

- (void)processTouchPoints:(NSArray<TouchPoint *> *)points
{
    _currentPoint = nil;
    
    _trackPoints = [NSMutableArray array];
    for (TouchPoint *point in points) {
        TrackPoint *trackPoint = [[TrackPoint alloc] init];
        
        trackPoint.x = point.x;
        trackPoint.y = point.y;
        [_trackPoints addObject:trackPoint];
    }
    
    [self onBeginProcessingPoint];
}

- (TrackPoint *)dequeueTrackPoint
{
    // 如果剩下的点数量为0，则返回nil
    if (_trackPoints.count == 0)
        return nil;
    
    // 如果currentPoint不为空，表示已经处理第一点
    if (_currentPoint != nil) {
        TrackPoint *p1 = nil;
        TrackPoint *p2 = _currentPoint;
        
        CGFloat p1x;
        CGFloat p1y;
        CGFloat p2x;
        CGFloat p2y;
        
        CGFloat pul = self.perUnitLength;   // 单位长度
        CGFloat ppLen = 0;                  // 点到点路径长度
        
        do {
            p1 = p2;
            p2 = [_trackPoints firstObject];
            
            if ([_trackPoints containsObject:p1])
                [_trackPoints removeObject:p1];
            
            p1x = p1.x;
            p1y = p1.y;
            p2x = p2.x;
            p2y = p2.y;
            
            // 计算点点路径长度
            ppLen += sqrt(powf(p2x - p1x, 2) + powf(p2y - p1y, 2));
        } while(ppLen < pul && _trackPoints.count != 0);
        
        // 计算单位坐标（角度计算）
        CGFloat ur = atan2(p2.y - _currentPoint.y, p2.x - _currentPoint.x);
        CGFloat ux = 1.0 * cos(ur);
        CGFloat uy = 1.0 * sin(ur);
        _currentPoint.ux = ux;
        _currentPoint.uy = -uy; // 显示坐标与单位坐标相反
        
        // 计算新的当前点的显示坐标
        CGFloat r = atan2(p1y - p2y, p1x - p2x);
        CGFloat deltaX = (ppLen - pul) * cos(r);
        CGFloat deltaY = (ppLen - pul) * sin(r);
        CGFloat newX = p2x + deltaX;
        CGFloat newY = p2y + deltaY;
        
        _currentPoint.x = newX;
        _currentPoint.y = newY;
    }
    // 处理第一点
    else {
        _currentPoint = [_trackPoints firstObject];
        [_trackPoints removeObjectAtIndex:0];
        
        _currentPoint.ux = 0;
        _currentPoint.uy = 0;
    }
    
    return _currentPoint;
}

- (void)onBeginProcessingPoint
{
    if ([(id)_delegate respondsToSelector:@selector(beginProcessingPoint:)]) {
        [_delegate beginProcessingPoint:self];
    }
}

@end
