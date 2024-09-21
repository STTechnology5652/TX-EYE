//
//  FreeSpaceMonitor.m
//  TX-EYE
//
//  Created by CoreCat on 2017/10/17.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "FreeSpaceMonitor.h"
#import "Utilities.h"

#define DEFAULT_THRESHOLD   (10 * 1024 * 1024)
#define MIN_THRESHOLD       (10 * 1024 * 1024)
#define DEFAULT_PERIOD      1.0
#define MIN_PERIOD          0.5

@interface FreeSpaceMonitor ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation FreeSpaceMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _threshold = DEFAULT_THRESHOLD;
        _period = DEFAULT_PERIOD;
    }
    return self;
}

- (instancetype)initWithThreshold:(long)threshold period:(long)period
{
    self = [super init];
    if (self) {
        _threshold = threshold;
        _period = period;
    }
    return self;
}

- (void)start
{
    [self stop];

    _timer = [NSTimer scheduledTimerWithTimeInterval:_period target:self selector:@selector(doCheckFreeSpace) userInfo:nil repeats:YES];
}

- (void)stop
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)doCheckFreeSpace
{
    if (![self checkFreeSpace])
        [_delegate freeSpaceThresholdExceeded:self];
}

- (BOOL)checkFreeSpace
{
//    NSLog(@"@@@ %lld (%d)", [Utilities freeDiskSpaceInBytes], [Utilities freeDiskSpaceInBytes] > _threshold);
    return [Utilities freeDiskSpaceInBytes] > _threshold;
}

#pragma mark getter and setter

- (void)setThreshold:(unsigned long long)threshold
{
    if (threshold < MIN_THRESHOLD)
        _threshold = MIN_THRESHOLD;
    else
        _threshold = threshold;
}

- (void)setPeriod:(NSTimeInterval)period
{
    if (period < MIN_PERIOD)
        _period = MIN_PERIOD;
    else
        _period = period;
}

@end
