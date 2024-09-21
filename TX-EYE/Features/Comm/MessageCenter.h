//
//  MessageCenter.h
//  GoTrack
//
//  Created by CoreCat on 2018/12/15.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPMessage.h"

typedef void(^MessageDeliverBlock)(uint8_t messageId, NSData *data);

#define kMessageCenterMessageNotification       @"kMessageCenterMessageNotification"
#define kMessageCenterConnectedNotification     @"kMessageCenterConnectedNotification"
#define kMessageCenterDisconnectedNotification  @"kMessageCenterDisconnectedNotification"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCenter : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

- (void)sendMessage:(TCPMessage *)message;

- (void)sendMessage:(TCPMessage *)message withBlock:(__nullable MessageDeliverBlock)block;

/* Device Internal Status */

// Device Connection Status
@property (nonatomic, readonly) BOOL isDeviceConnected;

// 是否已接收到设备状态报告
// 设备支持的特性和设备状态，只在置真时有效
@property (nonatomic, readonly) BOOL reported;

// 保存设备支持的功能原始字节，reported置真有效
@property (nonatomic, readonly) UInt8 deviceFunctionByte;

// 设备支持的功能
// deviceFunctionBitPos，参考TCPMessage里DEVICE_FUNCTION_*
- (BOOL)isDeviceSupportFunction:(UInt8)deviceFunctionBitPos;

// Storage Card Status
typedef NS_OPTIONS(NSUInteger, CardStatus) {
    CardStatusNone,
    CardStatusOK,
    CardStatusUnformmatted,
};

@property (nonatomic, assign) CardStatus cardStatus;

/* Message Shortcut */

- (void)sendMessageTimeCalibration:(NSData *)data;

/* Preview */

- (void)sendMessagePreviewResolution:(uint8_t)value;

- (void)sendMessagePreviewQuality:(uint8_t)value;

- (void)sendMessagePreviewSound:(uint8_t)value;

/* Video */

- (void)sendMessageVideoResolution:(uint8_t)value;

- (void)sendMessageVideoQuality:(uint8_t)value;

- (void)sendMessageVideoSound:(BOOL)on;

- (void)sendMessageVideoCyclicRecord:(uint8_t)value;

/* Photo */

- (void)sendMessagePhotoResolution:(uint8_t)value;

- (void)sendMessagePhotoQuality:(uint8_t)value;

- (void)sendMessagePhotoBurst:(uint8_t)value;

- (void)sendMessagePhotoTimelapse:(uint8_t)value;

/* Visual Effect */

- (void)sendMessageWhiteBalance:(uint8_t)value;

- (void)sendMessageExposureCompensation:(uint8_t)value;

- (void)sendMessageSharpness:(uint8_t)value;

- (void)sendMessageISO:(uint8_t)value;

- (void)sendMessageAntiBanding:(uint8_t)value;

- (void)sendMessageWDR:(BOOL)on;

/* Control */

- (void)sendMessageRecordVideo:(uint8_t)value;

- (void)sendMessageTakePhoto;

/* Common */

- (void)sendMessageWiFiSettings:(NSData *)data;

- (void)sendMessageLanguage:(uint8_t)value;

- (void)sendMessageMotionDetection:(BOOL)on;

- (void)sendMessageAntiShake:(BOOL)on;

- (void)sendMessageDateStamp:(BOOL)on;

- (void)sendMessageScreenSaver:(uint8_t)value;

- (void)sendMessageRotation:(BOOL)on;

- (void)sendMessageAutoShutdown:(uint8_t)value;

- (void)sendMessageButtonSound:(BOOL)on;

- (void)sendMessageOSDMode:(BOOL)on;

- (void)sendMessageCarMode:(BOOL)on;

- (void)sendMessageFormatCard;

- (void)sendMessageFactoryReset;

@end

NS_ASSUME_NONNULL_END
