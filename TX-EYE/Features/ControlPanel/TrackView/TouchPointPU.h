//
//  TouchPointPU.h
//  TX-EYE
//
//  Created by CoreCat on 2017/1/12.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchPoint.h"
#import "TrackPoint.h"

@class TouchPointPU;

@protocol TouchPointPUDelegate

@optional
// 开始处理点
- (void)beginProcessingPoint:(TouchPointPU *)ppu;

@end


@interface TouchPointPU : NSObject

@property (nonatomic, assign) CGFloat perUnitLength;

@property (nonatomic, weak) id<TouchPointPUDelegate> delegate;

- (void)processTouchPoints:(NSArray<TouchPoint *> *)points;

- (TrackPoint *)dequeueTrackPoint;

@end
