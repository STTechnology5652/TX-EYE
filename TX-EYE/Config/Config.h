//
//  Config.h
//  GoTrack
//
//  Created by CoreCat on 2018/5/14.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#ifndef Config_h
#define Config_h

// ----------------------------------------------------------------------------
/* 远程主机 */

#define REMOTE_HOST     @"192.168.1.1"
#define REMOTE_PORT     7070

// ----------------------------------------------------------------------------
/* RTSP路径 */

// RTSP文件路径
#define RTSP_PATH(FILE) [NSString stringWithFormat:@"rtsp://%@:%d/%@", REMOTE_HOST, REMOTE_PORT, FILE]

// ----------------------------------------------------------------------------
/* 预览 */

// 视频预览地址
#define PREVIEW_ADDRESS    RTSP_PATH(@"webcam")

// 断线重连时间间隔，单位s
#define RECONNECTION_INTERVAL  0.5

// ----------------------------------------------------------------------------
/* 飞控控制 */

#define CONTROL_INTERVAL    0.04    // 控制命令发送间隔, 40ms

// ----------------------------------------------------------------------------
/* Socket(Old) */

#define SOCKET_HOST     REMOTE_HOST
#define SOCKET_PORT     REMOTE_PORT
#define SOCKET_TIMEOUT  3.0

// ----------------------------------------------------------------------------
/* Comm(New) */

#define TCP_SERVER_HOST     REMOTE_HOST
#define TCP_SERVER_PORT     5000

#define TCP_HEADER_SIZE             4   // LENGTH
#define TCP_CONTENT_HEADER_SIZE     4   // MessageID(1) + SessionID(2) + Reserved(2)
#define TCP_TAG_HEADER              0x5A5A
#define TCP_TAG_BODY                0xA5A5

#define TCP_ALIVE_INTERVAL          5
#define TCP_RECONNECTION_INTERVAL   1

// ----------------------------------------------------------------------------
/* FTP Information */

#define FTP_HOST        REMOTE_HOST
#define FTP_PORT        21
#define FTP_USERNAME    @"ftp"
#define FTP_PASSWORD    @"ftp"
#define FTP_IDLETIME    10000           // ms，经测试1秒有时候还是容易断线，3秒也有断线
#define FTP_CBBYTES     (5 * 1024)      // Bytes

// ----------------------------------------------------------------------------
/* FTP Path */

#define FTP_ROOT_DIR    @"/0/"

#define VIDEO_PATH      @"DCIM"
#define IMAGE_PATH      @"PHOTO"

// ----------------------------------------------------------------------------
/* 文件管理 */

//#define REMOTE_MEDIA_DIR        @"..."
#define REMOTE_VIDEO_SUFFIX     @".avi"
#define REMOTE_IMAGE_SUFFIX     @".jpg"

#define LOCAL_VIDEO_SUFFIX      REMOTE_VIDEO_SUFFIX
#define LOCAL_IMAGE_SUFFIX      REMOTE_IMAGE_SUFFIX

// ----------------------------------------------------------------------------
/* Web路径 */

// 视频缩略图路径
#define VIDEO_THUMB_PATH(FILE)  [NSString stringWithFormat:@"http://%@/%@/%@", REMOTE_HOST, VIDEO_PATH, FILE]
// 视频路径
#define VIDEO_LIVE_PATH(FILE)   [NSString stringWithFormat:@"rtsp://%@:%d/file/%@/%@", REMOTE_HOST, REMOTE_PORT, VIDEO_PATH, FILE]

// 照片缩略图路径
#define PHOTO_THUMB_PATH(FILE)  [NSString stringWithFormat:@"http://%@/%@/T/%@", REMOTE_HOST, IMAGE_PATH, FILE]
// 照片路径
#define PHOTO_HTTP_PATH(FILE)   [NSString stringWithFormat:@"http://%@/%@/O/%@", REMOTE_HOST, IMAGE_PATH, FILE]

#endif /* Config_h */
