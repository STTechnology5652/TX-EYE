//
//  ObjectTracker.h
//  VisionProc
//
//  Copyright © 2022 TaiXin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectTracker : NSObject

/**
 * 重置，清除掉以前的状态
 */
- (void)reset;

/**
 * 检测物体，返回角点坐标
 * <NSValue *>内含CGPoint
 */
- (NSArray<NSValue *> *)detectObjectWithCVMat:(void *)mat;
- (NSArray<NSValue *> *)detectObjectWithData:(void *)data width:(int)width height:(int)height type:(int)type;
- (NSArray<NSValue *> *)detectObjectWithYUV420p:(void *)data width:(int)width height:(int)height;

/**
 * 检测物体，返回运动方向
 * <NSValue *>内含CGVector
 */
- (NSValue *)trackObjectWithCVMat:(void *)mat;
- (NSValue *)trackObjectWithData:(void *)data width:(int)width height:(int)height type:(int)type;
- (NSValue *)trackObjectWithYUV420p:(void *)data width:(int)width height:(int)height;

@end

NS_ASSUME_NONNULL_END
