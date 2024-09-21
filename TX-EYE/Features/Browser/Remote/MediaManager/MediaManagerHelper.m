//
//  MediaManagerHelper.m
//  FTPtest
//
//  Created by CoreCat on 2017/7/5.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "MediaManagerHelper.h"
#import "Utilities.h"
#import "Config.h"


@implementation MediaManagerHelper

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    __strong static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Naming

// 本地文件名=“文件_长度.扩展名”
+ (NSString *)getLocalFileNameFromRemoteFile:(RemoteFile *)remoteFile
{
    NSString *localFileNamePrefix = [remoteFile.name stringByDeletingPathExtension];
    NSString *localFileNameExtension = [remoteFile.name pathExtension];
    NSString *localFileName = [NSString stringWithFormat:@"%@_%llu.%@", localFileNamePrefix, remoteFile.size, localFileNameExtension];
    
    return localFileName;
}

// 临时文件名="最终文件名"+"~"
+ (NSString *)getTempFileNameFromRemoteFile:(RemoteFile *)remoteFile
{
    NSString *localFileName = [self getLocalFileNameFromRemoteFile:remoteFile];
    NSString *tempFileName = [localFileName stringByAppendingString:@"~"];
    
    return tempFileName;
}

#pragma mark - Path

/* 填充视频本地和网络路径 */
+ (void)completePathForRemoteVideoFile:(RemoteFile *)remoteFile
{
    remoteFile.isVideo = YES;
    
    NSString *localFileName = [self getLocalFileNameFromRemoteFile:remoteFile];
    NSString *localFilePath = [Utilities fullPathInVideoDir:localFileName];
    remoteFile.storePath = localFilePath;
    
    NSString *tempFileName = [self getTempFileNameFromRemoteFile:remoteFile];
    NSString *tempFilePath = [Utilities fullPathInVideoDir:tempFileName];
    remoteFile.tempPath = tempFilePath;
    
    remoteFile.thumbPath = VIDEO_THUMB_PATH(remoteFile.name);
    remoteFile.webPath = VIDEO_LIVE_PATH(remoteFile.name);
}

+ (void)completePathForRemoteVideoFiles:(NSArray<RemoteFile *> *)remoteFiles
{
    for (RemoteFile *remoteFile in remoteFiles) {
        [self completePathForRemoteVideoFile:remoteFile];
    }
}

/* 获取视频存储路径 */
+ (NSString *)getVideoLocalFilePathFromRemoteFile:(RemoteFile *)remoteFile
{
    if (remoteFile.storePath == nil) {
        [self completePathForRemoteVideoFile:remoteFile];
    }
    return remoteFile.storePath;
}

/* 获取视频临时路径 */
+ (NSString *)getVideoTempFilePathFromRemoteFile:(RemoteFile *)remoteFile
{
    if (remoteFile.tempPath == nil) {
        [self completePathForRemoteVideoFile:remoteFile];
    }
    return remoteFile.tempPath;
}

/* 填充照片本地和网络路径 */
+ (void)completePathForRemoteImageFile:(RemoteFile *)remoteFile
{
    remoteFile.isVideo = NO;
    
    NSString *localFileName = [self getLocalFileNameFromRemoteFile:remoteFile];
    NSString *localFilePath = [Utilities fullPathInPhotoDir:localFileName];
    remoteFile.storePath = localFilePath;
    
    NSString *tempFileName = [self getTempFileNameFromRemoteFile:remoteFile];
    NSString *tempFilePath = [Utilities fullPathInPhotoDir:tempFileName];
    remoteFile.tempPath = tempFilePath;
    
    remoteFile.thumbPath = PHOTO_THUMB_PATH(remoteFile.name);
    remoteFile.webPath = PHOTO_HTTP_PATH(remoteFile.name);
}

+ (void)completePathForRemoteImageFiles:(NSArray<RemoteFile *> *)remoteFiles
{
    for (RemoteFile *remoteFile in remoteFiles) {
        [self completePathForRemoteImageFile:remoteFile];
    }
}

/* 获取照片存储路径 */
+ (NSString *)getPhotoLocalFilePathFromRemoteFile:(RemoteFile *)remoteFile
{
    if (remoteFile.storePath == nil) {
        [self completePathForRemoteImageFile:remoteFile];
    }
    return remoteFile.storePath;
}

/* 获取照片临时路径 */
+ (NSString *)getPhotoTempFilePathFromRemoteFile:(RemoteFile *)remoteFile
{
    if (remoteFile.tempPath == nil) {
        [self completePathForRemoteImageFile:remoteFile];
    }
    return remoteFile.tempPath;
}

#pragma mark - Methods

+ (void)checkRemoteFiles:(NSArray<RemoteFile *> *)remoteFiles withCompletion:(BWCompletionBlock)completion
{
    dispatch_async(dispatch_queue_create("MediaManagerHelper.checkRemoteFiles", NULL), ^{
        for (RemoteFile *remoteFile in remoteFiles) {
            [self checkRemoteFile:remoteFile];
        }
        completion(nil);
    });
}

/**
 * 目前只能通过文件名+长度判断是否是同一个文件
 * 所以，下载的文件命名方式为“文件_长度.扩展名”，下载的临时文件命名为“文件_长度.扩展名~”
 * 通过这样的文件名判断是否是同一个文件
 */
+ (void)checkRemoteFile:(RemoteFile *)remoteFile
{
    NSString *localFilePath = remoteFile.storePath;
    NSString *tempFilePath = remoteFile.tempPath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:localFilePath]) {
        [remoteFile setDownloaded:YES];

        NSDictionary *attrs = [fileManager attributesOfItemAtPath:localFilePath error:NULL];
        if (attrs) {
            unsigned long long fileSize = [attrs fileSize];
            [remoteFile setLocalSize:fileSize];
            [remoteFile setSizeMismatch:fileSize != remoteFile.size];
        }
    } else if ([fileManager fileExistsAtPath:tempFilePath]) {
        [remoteFile setTempExist:YES];

        NSDictionary *attrs = [fileManager attributesOfItemAtPath:tempFilePath error:NULL];
        if (attrs) {
            unsigned long long fileSize = [attrs fileSize];
            [remoteFile setLocalSize:fileSize];
            [remoteFile setSizeMismatch:fileSize != remoteFile.size];
        }
    }
}

@end
