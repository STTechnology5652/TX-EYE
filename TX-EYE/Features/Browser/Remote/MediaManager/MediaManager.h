//
//  MediaManager.h
//  FTPtest
//
//  Created by CoreCat on 2017/6/26.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWSDKFoundation.h"
#import "RemoteFile.h"
#import "LocalFile.h"
#import "SDImageCache.h"

@interface MediaManager : NSObject

// ----------------------------------------------------------------------------

/**
 *  单例
 */
+ (instancetype)sharedInstance;

// ----------------------------------------------------------------------------

/**
 *  获取远程视频文件列表
 */
- (void)getVideoFileListWithCompletion:(BWArrayCompletionBlock)completion;

/**
 *  获取远程图像文件列表
 */
- (void)getImageFileListWithCompletion:(BWArrayCompletionBlock)completion;

// ----------------------------------------------------------------------------

/**
 *  删除多个视频文件，删除之前应该补全路径
 */
- (void)deleteRemoteVideoFiles:(NSArray<RemoteFile *> *)files
                       started:(void (^)(void))started
          withSingleCompletion:(void (^)(RemoteFile *, NSArray<RemoteFile *> *, NSError *_Nullable))singleCompletion
                withCompletion:(BWCompletionBlock)completion;

/**
 *  删除多个图像文件，删除之前应该补全路径
 */
- (void)deleteRemoteImageFiles:(NSArray<RemoteFile *> *)files
                       started:(void (^)(void))started
          withSingleCompletion:(void (^)(RemoteFile *, NSArray<RemoteFile *> *, NSError *_Nullable))singleCompletion
                withCompletion:(BWCompletionBlock)completion;

// ----------------------------------------------------------------------------

/**
 *  下载多个视频文件，下载文件之前应该补全路径
 */
- (void)downloadRemoteVideoFiles:(NSArray<RemoteFile *> *)files
                         started:(void (^)(NSString *fileName))started
                        progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
                  withCompletion:(BWCompletionBlock)completion;

/**
 *  下载多个图像文件，下载文件之前应该补全路径
 */
- (void)downloadRemoteImageFiles:(NSArray<RemoteFile *> *)files
                         started:(void (^)(NSString *fileName))started
                        progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
                  withCompletion:(BWCompletionBlock)completion;

/**
 *  取消下载
 */
- (void)cancelDownload;

// ----------------------------------------------------------------------------

/**
 *  异步获取本地视频文件列表
 */
- (void)getAllLocalVideoFilesWithCompletion:(BWArrayCompletionBlock)completion;

/**
 *  同步获取本地视频文件列表
 */
- (NSArray<LocalFile *> *)getAllLocalVideoFiles;

/**
 *  异步获取本地图像文件列表
 */
- (void)getAllLocalImageFilesWithCompletion:(BWArrayCompletionBlock)completion;

/**
 *  同步获取本地图像文件列表
 */
- (NSArray<LocalFile *> *)getAllLocalImageFiles;

// ----------------------------------------------------------------------------

/* Thumbnail */

@property (nonatomic, strong) SDImageCache *thumbnailCache;

- (void)createImageThumbnailURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion;
- (void)createVideoThumbnailURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion;

@end
