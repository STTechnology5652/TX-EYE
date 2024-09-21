//
//  TrackPoint.h
//  TX-EYE
//
//  Created by CoreCat on 2017/1/3.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TrackPoint : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

// ux, uy, 根据角度算出单位长度，飞控输出使用，范围[-1, 1]
@property (nonatomic, assign) CGFloat ux;
@property (nonatomic, assign) CGFloat uy;

@end
