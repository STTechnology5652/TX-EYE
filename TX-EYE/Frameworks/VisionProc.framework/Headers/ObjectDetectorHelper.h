//
//  ObjectDetectorHelper.h
//  VisionProc
//
//  Copyright © 2022 TaiXin. All rights reserved.
//

#import "ObjectDetector.h"

NS_ASSUME_NONNULL_BEGIN

@interface ObjectDetectorHelper : NSObject

+ (instancetype)sharedInstance;

/**
 * 脸部判断识别成功的阈值，[0, 1.0]，默认0.95
 * 因为脸部识别比其他识别复杂，所以脸部阈值与probThreshold分开设置
 */
@property (nonatomic, assign) float faceProbThreshold;

/**
 * 判断识别除脸部外物体成功的阈值，[0, 1.0]，默认0.99
 */
@property (nonatomic, assign) float probThreshold;

/**
 * 触发需要的检测次数，默认2
 */
@property (nonatomic, assign) int triggerCount;

/* findObject，每次选用一种 */

- (BOOL)findObject:(int)objectLabel inObjects:(NSArray<DetectedObject *> *)objects;

- (BOOL)findObjectWithFace:(int)objectLabel inObjects:(NSArray<DetectedObject *> *)objects;

@end

NS_ASSUME_NONNULL_END
