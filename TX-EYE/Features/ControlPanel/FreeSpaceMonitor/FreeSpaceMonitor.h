//
//  FreeSpaceMonitor.h
//  TX-EYE
//
//  Created by CoreCat on 2017/10/17.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FreeSpaceMonitor;

@protocol FreeSpaceMonitorDelegate <NSObject>
- (void)freeSpaceThresholdExceeded:(FreeSpaceMonitor*)monitor;
@end

@interface FreeSpaceMonitor : NSObject

@property (nonatomic, assign) unsigned long long threshold;
@property (nonatomic, assign) NSTimeInterval period;
@property (nonatomic, weak) id<FreeSpaceMonitorDelegate> delegate;

- (instancetype)initWithThreshold:(long)threshold period:(long)period;
- (void)start;
- (void)stop;
- (BOOL)checkFreeSpace;

@end
