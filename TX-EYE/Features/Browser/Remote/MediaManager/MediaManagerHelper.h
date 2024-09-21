//
//  MediaManagerHelper.h
//  FTPtest
//
//  Created by CoreCat on 2017/7/5.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteFile.h"
#import "BWSDKFoundation.h"

/**
 *  目前有保存并对比远程文件和本地文件大小的功能，以判断是否是同一个文件（这个方法比较简单，看看以后还有什么好的方法可以使用不）
 */

@interface MediaManagerHelper : NSObject

+ (instancetype)sharedInstance;

/* Naming */

/* 获取存储文件名 */
+ (NSString *)getLocalFileNameFromRemoteFile:(RemoteFile *)remoteFile;
/* 获取临时文件名 */
+ (NSString *)getTempFileNameFromRemoteFile:(RemoteFile *)remoteFile;

/* Path */

/* 补全视频文件路径 */
+ (void)completePathForRemoteVideoFile:(RemoteFile *)remoteFile;
/* 补全多个视频文件路径 */
+ (void)completePathForRemoteVideoFiles:(NSArray<RemoteFile *> *)remoteFiles;

/* 获取视频存储路径 */
+ (NSString *)getVideoLocalFilePathFromRemoteFile:(RemoteFile *)remoteFile;
/* 获取视频临时路径 */
+ (NSString *)getVideoTempFilePathFromRemoteFile:(RemoteFile *)remoteFile;

/* 补全图像文件路径 */
+ (void)completePathForRemoteImageFile:(RemoteFile *)remoteFile;
/* 补全多个图像文件路径 */
+ (void)completePathForRemoteImageFiles:(NSArray<RemoteFile *> *)remoteFiles;

/* 获取图像存储路径 */
+ (NSString *)getPhotoLocalFilePathFromRemoteFile:(RemoteFile *)remoteFile;
/* 获取图像临时路径 */
+ (NSString *)getPhotoTempFilePathFromRemoteFile:(RemoteFile *)remoteFile;

/* Methods */

/* 检查存储文件/临时文件是否已经存在，大小是否匹配 */
+ (void)checkRemoteFiles:(NSArray<RemoteFile *> *)remoteFiles withCompletion:(BWCompletionBlock)completion;

@end
