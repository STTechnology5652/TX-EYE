//
//  TouchPoint.h
//  TX-EYE
//
//  Created by CoreCat on 2017/1/12.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TouchPoint : NSObject

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;

- (instancetype)initWithX:(float)x andY:(float)y;
+ (instancetype)pointWithX:(float)x andY:(float)y;
+ (instancetype)pointWithPoint:(CGPoint)point;

@end
