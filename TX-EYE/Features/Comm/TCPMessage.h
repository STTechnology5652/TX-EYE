//
//  TCPMessage.h
//  GoTrack
//
//  Created by CoreCat on 2018/12/17.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCPMessage : NSObject

// 消息ID
@property (nonatomic, assign, readonly) uint8_t messageId;
// 会话ID
@property (nonatomic, assign) uint8_t sessionId;
// 消息内容
@property (nonatomic, strong, readonly) NSData *content;

// 用以发送的内容
@property (nonatomic, strong, readonly) NSData *sendableData;

/**
 * 消息ID，用以表明消息用途
 */

// !!! This section sync with Firmware and Android !!!

/* System */    /* 0x00-0x07 */

#define MSG_ID_HEARTBEAT            0x00    // empty body

#define MSG_ID_REQUEST_REPORT       0x01

#define MSG_ID_REPORT               0x02    // One ID one value

#define MSG_ID_DEVICE_STATUS        0x03
#define     DEVICE_STATUS_DISCONNECTED  0x00
#define     DEVICE_STATUS_IDLE          0x01
#define     DEVICE_STATUS_BUSY          0x02
#define     DEVICE_STATUS_NO_CARD       0x03
#define     DEVICE_STATUS_INSUFFICIENT_STORAGE 0x04

#define MSG_ID_CARD_STATUS          0x04
#define     CARD_STATUS_NONE            0x00
#define     CARD_STATUS_OK              0x01
#define     CARD_STATUS_UNFORMMATTED    0x02

#define MSG_ID_TIME_CALIBRATION     0x05    // Year/Month/Day Hour:Minute:Second, 1 byte per field, Year from 2000

#define MSG_ID_DEVICE_FUNCTION      0x06    // Bit processing
#define     DEVICE_FUNCTION_CARD_PHOTO  0x00
#define     DEVICE_FUNCTION_CARD_VIDEO  0x01

/* Preview */    /* 0x08-0x0F */

#define MSG_ID_PREVIEW_RESOLUTION   0x08
#define     PREVIEW_RESOLUTION_SD       0x00
#define     PREVIEW_RESOLUTION_HD       0x01
#define     PREVIEW_RESOLUTION_FHD      0x02

#define MSG_ID_PREVIEW_QUALITY      0x09
#define     PREVIEW_QUALITY_LOW         0x00
#define     PREVIEW_QUALITY_MID         0x01
#define     PREVIEW_QUALITY_HIGH        0x02

#define MSG_ID_PREVIEW_SOUND        0x0A
#define     PREVIEW_SOUND_TOGGLE        0x00
#define     PREVIEW_SOUND_OFF           0x01
#define     PREVIEW_SOUND_ON            0x02

/* Video */    /* 0x10-0x17 */

#define MSG_ID_VIDEO_RESOLUTION     0x10
#define     VIDEO_RESOLUTION_SD         0x00
#define     VIDEO_RESOLUTION_HD         0x01
#define     VIDEO_RESOLUTION_FHD        0x02

#define MSG_ID_VIDEO_QUALITY        0x11
#define     VIDEO_QUALITY_LOW           0x00
#define     VIDEO_QUALITY_MID           0x01
#define     VIDEO_QUALITY_HIGH          0x02

#define MSG_ID_VIDEO_SOUND          0x12
#define     VIDEO_SOUND_OFF             0x00
#define     VIDEO_SOUND_ON              0x01

#define MSG_ID_VIDEO_CYCLIC_RECORD  0x13
#define     VIDEO_CYCLIC_RECORD_OFF     0x00
#define     VIDEO_CYCLIC_RECORD_1MIN    0x01
#define     VIDEO_CYCLIC_RECORD_2MIN    0x02
#define     VIDEO_CYCLIC_RECORD_3MIN    0x03
#define     VIDEO_CYCLIC_RECORD_4MIN    0x04
#define     VIDEO_CYCLIC_RECORD_5MIN    0x05

/* Photo */    /* 0x18-0x1F */

#define MSG_ID_PHOTO_RESOLUTION     0x18
#define     PHOTO_RESOLUTION_SD         0x00
#define     PHOTO_RESOLUTION_HD         0x01
#define     PHOTO_RESOLUTION_FHD        0x02
#define     PHOTO_RESOLUTION_QHD        0x03
#define     PHOTO_RESOLUTION_UHD        0x04

#define MSG_ID_PHOTO_QUALITY        0x19
#define     PHOTO_QUALITY_LOW           0x00
#define     PHOTO_QUALITY_MID           0x01
#define     PHOTO_QUALITY_HIGH          0x02

#define MSG_ID_PHOTO_BURST          0x1A
#define     PHOTO_BURST_OFF             0x00
#define     PHOTO_BURST_2               0x01
#define     PHOTO_BURST_3               0x02
#define     PHOTO_BURST_5               0x03
#define     PHOTO_BURST_10              0x04

#define MSG_ID_PHOTO_TIMELAPSE      0x1B
#define     PHOTO_TIMELAPSE_OFF         0x00
#define     PHOTO_TIMELAPSE_2           0x01
#define     PHOTO_TIMELAPSE_3           0x02
#define     PHOTO_TIMELAPSE_5           0x03
#define     PHOTO_TIMELAPSE_10          0x04
#define     PHOTO_TIMELAPSE_15          0x05
#define     PHOTO_TIMELAPSE_20          0x06
#define     PHOTO_TIMELAPSE_25          0x07
#define     PHOTO_TIMELAPSE_30          0x08

/* Visual Effect */    /* 0x20-0x3F */

#define MSG_ID_WHITE_BALANCE        0x20
#define     WHITE_BALANCE_AUTO          0x00
#define     WHITE_BALANCE_DAYLIGHT      0x01
#define     WHITE_BALANCE_CLOUDY        0x02
#define     WHITE_BALANCE_SHADE         0x03
#define     WHITE_BALANCE_FLASH         0x04
#define     WHITE_BALANCE_TUNGSTEN      0x05
#define     WHITE_BALANCE_FLUORESCENT   0x06

#define MSG_ID_EXPOSURE_COMPENSATION 0x21
#define     EXPOSURE_COMPENSATION_1     0x00
#define     EXPOSURE_COMPENSATION_2     0x01
#define     EXPOSURE_COMPENSATION_3     0x02
#define     EXPOSURE_COMPENSATION_4     0x03
#define     EXPOSURE_COMPENSATION_5     0x04

#define MSG_ID_SHARPNESS            0x22
#define     SHARPNESS_SOFT              0x00
#define     SHARPNESS_NORMAL            0x01
#define     SHARPNESS_STRONG            0x02

#define MSG_ID_ISO                  0x23        // todo: define

#define MSG_ID_ANTI_BANDING         0x24
#define     ANTI_BANDING_OFF            0x00
#define     ANTI_BANDING_50HZ           0x01
#define     ANTI_BANDING_60HZ           0x02
#define     ANTI_BANDING_AUTO           0x03

#define MSG_ID_WDR                  0x25
#define     WDR_OFF                     0x00
#define     WDR_ON                      0x01

/* Control */   /* 0x40-0x4F */

#define MSG_ID_RECORD_VIDEO         0x40        // Device
#define     RECORD_VIDEO_TOGGLE         0x00
#define     RECORD_VIDEO_START          0x01
#define     RECORD_VIDEO_STOP           0x02

#define MSG_ID_TAKE_PHOTO           0x41    // Device, 0 = Took, x = Countdown

#define MSG_ID_RECORD_VIDEO_ON_PHONE 0x48    // App

#define MSG_ID_TAKE_PHOTO_ON_PHONE  0x49    // App

/* Common */    /* 0x50-0x7F */

#define MSG_ID_WIFI_SETTINGS        0x50    // JSON

#define MSG_ID_LANGUAGE             0x51
#define     LANGUAGE_EN_US              0x00
#define     LANGUAGE_ZH_CN              0x01
#define     LANGUAGE_ZH_TW              0x02
#define     LANGUAGE_JA_JP              0x03

#define MSG_ID_MOTION_DETECTION     0x52
#define     MOTION_DETECTION_OFF        0x00
#define     MOTION_DETECTION_ON         0x01

#define MSG_ID_ANTI_SHAKE           0x53
#define     ANTI_SHAKE_OFF              0x00
#define     ANTI_SHAKE_ON               0x01

#define MSG_ID_DATE_STAMP           0x54
#define     DATE_STAMP_OFF              0x00
#define     DATE_STAMP_ON               0x01

#define MSG_ID_SCREEN_SAVER         0x55
#define     SCREEN_SAVER_OFF            0x00
#define     SCREEN_SAVER_1MIN           0x01
#define     SCREEN_SAVER_3MIN           0x02
#define     SCREEN_SAVER_5MIN           0x03

#define MSG_ID_ROTATION             0x56
#define     ROTATION_OFF                0x00
#define     ROTATION_ON                 0x01

#define MSG_ID_AUTO_SHUTDOWN        0x57
#define     AUTO_SHUTDOWN_OFF           0x00
#define     AUTO_SHUTDOWN_1MIN          0x01
#define     AUTO_SHUTDOWN_3MIN          0x02
#define     AUTO_SHUTDOWN_5MIN          0x03

#define MSG_ID_BUTTON_SOUND         0x58
#define     BUTTON_SOUND_OFF            0x00
#define     BUTTON_SOUND_ON             0x01

#define MSG_ID_OSD_MODE             0x59
#define     OSD_MODE_OFF                0x00
#define     OSD_MODE_ON                 0x01

#define MSG_ID_CAR_MODE             0x5A
#define     CAR_MODE_OFF                0x00
#define     CAR_MODE_ON                 0x01

#define MSG_ID_FORMAT_CARD          0x5B    // empty body

#define MSG_ID_FACTORY_RESET        0x5C    // empty body

#define MSG_ID_BATTERY              0x5D


/**
 * 生成消息，包含ID
 * @param mid   消息ID，用于区分消息用途
 * @param data  消息体
 */
+ (TCPMessage *)messageWithId:(uint8_t)mid data:(NSData * _Nullable)data;

/**
 * 生成消息，包含ID
 * @param mid   消息ID，用于区分消息用途
 * @param value 消息值
 */
+ (TCPMessage *)messageWithId:(uint8_t)mid value:(uint8_t)value;

/**
 * 心跳包
 */
+ (TCPMessage *)aliveMessage;

@end

NS_ASSUME_NONNULL_END
