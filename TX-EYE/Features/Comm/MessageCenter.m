//
//  MessageCenter.m
//  GoTrack
//
//  Created by CoreCat on 2018/12/15.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "MessageCenter.h"
#import "TCPClient.h"
#import "Config.h"

@interface MessageCenter () <TCPClientDelegate>

@property (nonatomic, strong) TCPClient *client;
@property (nonatomic, strong) NSTimer *keepAliveTimer;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MessageDeliverBlock> *postmen;
@property (nonatomic, assign) uint8_t latestSessionId;

@end

@implementation MessageCenter

+ (instancetype)sharedInstance
{
    static MessageCenter *messageCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageCenter = [[MessageCenter alloc] init];
    });
    return messageCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _client = [[TCPClient alloc] init];
        _client.delegate = self;
    }
    return self;
}

- (BOOL)isDeviceConnected
{
    return self.client.isConnected;
}

- (NSMutableDictionary *)postmen
{
    if (_postmen == nil) {
        _postmen = [NSMutableDictionary new];
    }
    return _postmen;
}

- (uint8_t)latestSessionId
{
    return ++_latestSessionId;
}

- (NSString *)keyOfSessionId:(uint8_t)sessionId
{
    return [NSString stringWithFormat:@"%d", sessionId];
}

- (void)start
{
    [_client connect];
}

- (void)stop
{
    [_client disconnect];
}

- (void)sendMessage:(TCPMessage *)message
{
    [self sendMessage:message withBlock:nil];
}

- (void)sendMessage:(TCPMessage *)message withBlock:(MessageDeliverBlock)block
{
    uint8_t sessionId = self.latestSessionId;
    NSString *keySessionId = [self keyOfSessionId:sessionId];
    if (block) {
        [self.postmen addEntriesFromDictionary:@{ keySessionId: block }];
    } else {
        // 如果没有提供block，则移除相同SessionID的block
        [self.postmen removeObjectForKey:keySessionId];
    }
    
    message.sessionId = sessionId;
    [self.client sendData:[message sendableData]];
}

- (void)sendKeepAlive
{
    [self sendMessage:[TCPMessage aliveMessage]];
}

#pragma mark - Message Shortcut

- (void)sendMessageTimeCalibration:(NSData *)data
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_TIME_CALIBRATION data:data];
    [self sendMessage:message];
}

/* Preview */

- (void)sendMessagePreviewResolution:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PREVIEW_RESOLUTION value:value];
    [self sendMessage:message];
}

- (void)sendMessagePreviewQuality:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PREVIEW_QUALITY value:value];
    [self sendMessage:message];
}

- (void)sendMessagePreviewSound:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PREVIEW_SOUND value:value];
    [self sendMessage:message];
}

/* Video */

- (void)sendMessageVideoResolution:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_VIDEO_RESOLUTION value:value];
    [self sendMessage:message];
}

- (void)sendMessageVideoQuality:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_VIDEO_QUALITY value:value];
    [self sendMessage:message];
}

- (void)sendMessageVideoSound:(BOOL)on
{
    uint8_t value = on ? VIDEO_SOUND_ON : VIDEO_SOUND_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_VIDEO_SOUND value:value];
    [self sendMessage:message];
}

- (void)sendMessageVideoCyclicRecord:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_VIDEO_CYCLIC_RECORD value:value];
    [self sendMessage:message];
}

/* Photo */

- (void)sendMessagePhotoResolution:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PHOTO_RESOLUTION value:value];
    [self sendMessage:message];
}

- (void)sendMessagePhotoQuality:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PHOTO_QUALITY value:value];
    [self sendMessage:message];
}

- (void)sendMessagePhotoBurst:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PHOTO_BURST value:value];
    [self sendMessage:message];
}

- (void)sendMessagePhotoTimelapse:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_PHOTO_TIMELAPSE value:value];
    [self sendMessage:message];
}

/* Visual Effect */

- (void)sendMessageWhiteBalance:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_WHITE_BALANCE value:value];
    [self sendMessage:message];
}

- (void)sendMessageExposureCompensation:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_EXPOSURE_COMPENSATION value:value];
    [self sendMessage:message];
}

- (void)sendMessageSharpness:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_SHARPNESS value:value];
    [self sendMessage:message];
}

- (void)sendMessageISO:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_ISO value:value];
    [self sendMessage:message];
}

- (void)sendMessageAntiBanding:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_ANTI_BANDING value:value];
    [self sendMessage:message];
}

- (void)sendMessageWDR:(BOOL)on
{
    uint8_t value = on ? WDR_ON : WDR_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_WDR value:value];
    [self sendMessage:message];
}

/* Control */

- (void)sendMessageRecordVideo:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_RECORD_VIDEO value:value];
    [self sendMessage:message];
}

- (void)sendMessageTakePhoto
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_TAKE_PHOTO data:nil];
    [self sendMessage:message];
}

/* Common */

- (void)sendMessageWiFiSettings:(NSData *)data
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_WIFI_SETTINGS data:data];
    [self sendMessage:message];
}

- (void)sendMessageLanguage:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_LANGUAGE value:value];
    [self sendMessage:message];
}

- (void)sendMessageMotionDetection:(BOOL)on
{
    uint8_t value = on ? MOTION_DETECTION_ON : MOTION_DETECTION_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_MOTION_DETECTION value:value];
    [self sendMessage:message];
}

- (void)sendMessageAntiShake:(BOOL)on
{
    uint8_t value = on ? ANTI_SHAKE_ON : ANTI_SHAKE_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_ANTI_SHAKE value:value];
    [self sendMessage:message];
}

- (void)sendMessageDateStamp:(BOOL)on
{
    uint8_t value = on ? DATE_STAMP_ON : DATE_STAMP_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_DATE_STAMP value:value];
    [self sendMessage:message];
}

- (void)sendMessageScreenSaver:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_SCREEN_SAVER value:value];
    [self sendMessage:message];
}

- (void)sendMessageRotation:(BOOL)on
{
    uint8_t value = on ? ROTATION_ON : ROTATION_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_ROTATION value:value];
    [self sendMessage:message];
}

- (void)sendMessageAutoShutdown:(uint8_t)value
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_AUTO_SHUTDOWN value:value];
    [self sendMessage:message];
}

- (void)sendMessageButtonSound:(BOOL)on
{
    uint8_t value = on ? BUTTON_SOUND_ON : BUTTON_SOUND_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_BUTTON_SOUND value:value];
    [self sendMessage:message];
}

- (void)sendMessageOSDMode:(BOOL)on
{
    uint8_t value = on ? OSD_MODE_ON : OSD_MODE_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_OSD_MODE value:value];
    [self sendMessage:message];
}

- (void)sendMessageCarMode:(BOOL)on
{
    uint8_t value = on ? CAR_MODE_ON : CAR_MODE_OFF;
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_CAR_MODE value:value];
    [self sendMessage:message];
}

- (void)sendMessageFormatCard
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_FORMAT_CARD data:nil];
    [self sendMessage:message];
}

- (void)sendMessageFactoryReset
{
    TCPMessage *message = [TCPMessage messageWithId:MSG_ID_FACTORY_RESET data:nil];
    [self sendMessage:message];
}

#pragma mark - Device Internal Message

/**
 * 处理设备报告
 * @param content 报告内容
 */
- (void)processReport:(NSData *)content
{
    // 目前一个ID对应的设置值均为1Byte，所以这里固定按照两个字节分离
    if ([content length] > 1) {
        uint8_t *contentBytes = (uint8_t *)[content bytes];
        uint8_t messageId = contentBytes[0];
        NSData *contentData = [content subdataWithRange:NSMakeRange(1, 1)];
        [self processInternalMessageWithId:messageId andContent:contentData];
        
        // 递归调用
        NSData *subData = [content subdataWithRange:NSMakeRange(2, [content length] - 2)];
        [self processReport:subData];
    }
    // 表明已经接收到设备状态报告
    _reported = YES;
}

/**
 * 处理内部消息，包括设备和卡状态
 * @return 是否已处理
 */
- (BOOL)processInternalMessageWithId:(uint8_t)messageId andContent:(NSData *)contentData
{
    if ([contentData length] == 0) return NO;
    
    uint8_t *contentBytes = (uint8_t *)[contentData bytes];
    
    switch (messageId) {
        case MSG_ID_CARD_STATUS:
        {
            uint8_t status = contentBytes[0];
            if (status == CARD_STATUS_OK) {
                _cardStatus = CardStatusOK;
            } else if (status == CARD_STATUS_UNFORMMATTED) {
                _cardStatus = CardStatusUnformmatted;
            } else {
                // 默认状态用None
                 _cardStatus = CardStatusNone;
            }
            return YES;
        }
        case MSG_ID_DEVICE_FUNCTION:
        {
            _deviceFunctionByte = contentBytes[0];
            return YES;
        }
            
        default:
            break;
    }
    
    return NO;
}

#pragma mark - Device function

- (BOOL)isDeviceSupportFunction:(UInt8)deviceFunctionBitPos
{
    return (_deviceFunctionByte & (1 << deviceFunctionBitPos)) != 0;
}

#pragma mark - TCPClientDelegate

- (void)didConnectSuccess
{
//    NSLog(@"====== Message Center connected");
    
    // 发送连接通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageCenterConnectedNotification object:nil];
    
    // 开始心跳包定时器
    self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:TCP_ALIVE_INTERVAL target:self selector:@selector(sendKeepAlive) userInfo:nil repeats:YES];
}

- (void)didDisconnect
{
//    NSLog(@"====== Message Center disconnected");
    
    /* !!! 注意：connect连接不上也会调用，不只是连接后断开才会调用 !!! */
    
    // 发送断开通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageCenterDisconnectedNotification object:nil];
    
    // 停止心跳包定时器
    [self.keepAliveTimer invalidate];
    
    // 重置设备状态报告
    _reported = NO;
    _deviceFunctionByte = 0;
}

- (void)didReadData:(NSData *)data
{
    if (data.length >= TCP_CONTENT_HEADER_SIZE) {
        uint8_t *bytes = (uint8_t *)[data bytes];
        uint8_t messageId = bytes[0];
//        uint8_t sessionId = bytes[1];
        NSData *infoData = [data subdataWithRange:NSMakeRange(TCP_CONTENT_HEADER_SIZE, data.length - TCP_CONTENT_HEADER_SIZE)];
        
        if (messageId == MSG_ID_REPORT) {
            [self processReport:infoData];
        } else {
            // 处理单独的内部消息
            if ([self processInternalMessageWithId:messageId andContent:infoData]) {
                // 如果已经处理过了，返回
                return;
            }
        }
        
        // 用于每个发送的回调
//        NSString *keySessionId = [self keyOfSessionId:sessionId];
//        MessageDeliverBlock block = [self.postmen objectForKey:keySessionId];
//        if (block) {
//            block(messageId, infoData);
//        }
        
        // Post message
        TCPMessage *message = [TCPMessage messageWithId:messageId data:infoData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageCenterMessageNotification object:message];
    } else {
        NSLog(@"didReadData: the length of message is too short!");
    }
}

@end
