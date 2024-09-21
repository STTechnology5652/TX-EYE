//
//  TouchPoint.m
//  TX-EYE
//
//  Created by CoreCat on 2017/1/12.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "TouchPoint.h"

@implementation TouchPoint

- (instancetype)initWithX:(float)x andY:(float)y
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

+ (instancetype)pointWithX:(float)x andY:(float)y
{
    return [[[self class] alloc] initWithX:x andY:y];
}

+ (instancetype)pointWithPoint:(CGPoint)point
{
    return [[[self class] alloc] initWithX:point.x andY:point.y];
}

@end
