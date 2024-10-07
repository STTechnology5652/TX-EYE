//
//  ObjectDetector.h
//  VisionProc
//
//  Copyright © 2022 TaiXin. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define OBJECT_LABEL_FACE       1
#define OBJECT_LABEL_OK         2
#define OBJECT_LABEL_YES        3
#define OBJECT_LABEL_PALM       4

@interface DetectedObject : NSObject

@property (nonatomic, assign) int label;
@property (nonatomic, assign) float prob;

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGPoint center;

@end

@interface ObjectDetector : NSObject

/**
 * 是否正在忙碌（检测）状态
 */
@property (nonatomic, assign) BOOL isBusy;

/**
 * 检测的最小间隔时间，单位秒，默认0.1s
 */
@property (nonatomic, assign) NSTimeInterval minTimeInterval;

/**
 * 检测cv::Mat图像中物体
 * @mat 指针，指向cv:Mat
 * @return 包含CGRect的NSValue数组
 */
- (NSArray<DetectedObject *> *)detectObjectWithCVMat:(void *)mat;

/**
 * 检测cv::Mat图像中物体
 * @data    数据指针，指向图像数据
 * @width   列数，图像宽度
 * @height  行数，图像高度
 * @type    图像类型，定义同OpenCV
 * 所有参数定义同cv::Mat
 * @return 包含CGRect的NSValue数组
 */
- (NSArray<DetectedObject *> *)detectObjectWithData:(void *)data width:(int)width height:(int)height type:(int)type;

/**
 * 检测YUV420p图像中物体
 * @data    数据指针，指向图像数据
 * @width   列数，图像宽度
 * @height  行数，图像高度
 * @return 包含CGRect的NSValue数组
 */
- (NSArray<DetectedObject *> *)detectObjectWithYUV420p:(void *)data width:(int)width height:(int)height;

@end

NS_ASSUME_NONNULL_END
