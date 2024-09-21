//
//  MediaManager.m
//  FTPtest
//
//  Created by CoreCat on 2017/6/26.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "MediaManager.h"
#import "FTPManager.h"
#import "FTPHandle.h"
#import "NSError+BWSDK.h"
#import "Utilities.h"
#import "BWSocketWrapper.h"
#import "MediaManagerHelper.h"
#import <AVFoundation/AVFoundation.h>

#import "Config.h"

#define THUMBNAIL_DEFAULT_MAX_SIZE  (5 * 1000 * 1000)


@interface MediaManager ()

@property (nonatomic, assign) BOOL abortedDownload;

@end

@implementation MediaManager

+ (instancetype)sharedInstance
{
    __strong static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    return [self initWithThumbnailCacheNamespace:@"MediaManager"];
}

- (nonnull instancetype)initWithThumbnailCacheNamespace:(nonnull NSString *)namespace
{
    self = [super init];
    if (self) {
        self.thumbnailCache = [[SDImageCache alloc] initWithNamespace:namespace];
        self.thumbnailCache.config.maxDiskSize = THUMBNAIL_DEFAULT_MAX_SIZE;
    }
    return self;
}

#pragma mark - REMOTE LISTING

/**
 *  获取当前目录列表
 */
- (void)getRemoteFileListWithCompletion:(BWArrayCompletionBlock)completion
{
    [self getRemoteFileListWithSuffix:nil withCompletion:completion];
}

/**
 *  获取当前目录列表，带过滤器，Designated
 */
- (void)getRemoteFileListWithSuffix:(NSString *)suffix withCompletion:(BWArrayCompletionBlock)completion
{
    [FTPManager.sharedInstance listFilesWithSuffix:suffix withCompletion:^(NSArray * _Nullable array, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
        } else {
            // Translate FTPHandle(s) to RemoteFile(s)
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
            
            for (int i=0; i<array.count; i++) {
                FTPHandle *fFile = [array objectAtIndex:i];
                
                if (fFile.size == 0) continue;      // 过滤掉长度为0的文件
                
                RemoteFile *rFile = [[RemoteFile alloc] init];
                
                switch (fFile.type) {
                    case FTPHandleTypeFile:
                        rFile.type = RemoteFileTypeFile;
                        break;
                    case FTPHandleTypeDirectory:
                        rFile.type = RemoteFileTypeDirectory;
                        break;
                        
                    default:
                        rFile.type = RemoteFileTypeUnknown;
                        break;
                }
                rFile.name = fFile.name;
                rFile.modified = fFile.modified;
                rFile.size = fFile.size;
                
                [mutableArray addObject:rFile];
            }
            completion(mutableArray, nil);
        }
    }];
}

/**
 *  获取VIDEO列表
 */
- (void)getVideoFileListWithCompletion:(BWArrayCompletionBlock)completion
{
//    [BWSocketWrapper.sharedInstance stopRecordWithCompletion:^(NSError * _Nullable error) {
//        if (error) {
//            // 停止录制错误
//            completion(nil, error);
//        } else {    // 停止录制OK
            // 开始执行动作
            // 为了防止使用中断开再连接后当前目录重置的问题，每次先进入VIDEO目录，再LIST
            [FTPManager.sharedInstance changeToVideoDirectory:^(NSError * _Nullable error) {
                if (error) {
                    // 失败
                    completion(nil, error);
                } else {
                    // 获取VIDEO列表
                    [self getRemoteFileListWithSuffix:REMOTE_VIDEO_SUFFIX withCompletion:^(NSArray * _Nullable array, NSError * _Nullable error) {
                        if (error == nil) {
                            // 补全存储路径和临时路径
                            [MediaManagerHelper completePathForRemoteVideoFiles:array];
                        }
                        completion(array, error);
                    }];
                }
            }];
//        }
//    }];
}

/**
 *  获取IMAEG列表
 */
- (void)getImageFileListWithCompletion:(BWArrayCompletionBlock)completion
{
//    [BWSocketWrapper.sharedInstance stopRecordWithCompletion:^(NSError * _Nullable error) {
//        if (error) {
//            // 停止录制错误
//            completion(nil, error);
//        } else {    // 停止录制OK
            // 开始执行动作
            // 为了防止使用中断开再连接后当前目录重置的问题，每次先进入IMAGE目录，再LIST
            [FTPManager.sharedInstance changeToImageDirectory:^(NSError * _Nullable error) {
                if (error) {
                    // 失败
                    completion(nil, error);
                } else {
                    // 获取IMAGE列表
                    [self getRemoteFileListWithSuffix:REMOTE_IMAGE_SUFFIX withCompletion:^(NSArray * _Nullable array, NSError * _Nullable error) {
                        if (error == nil) {
                            // 补全存储路径和临时路径
                            [MediaManagerHelper completePathForRemoteImageFiles:array];
                        }
                        completion(array, error);
                    }];
                }
            }];
//        }
//    }];
}

#pragma mark - DELETE

/**
 *  删除多个视频文件，删除之前应该补全路径
 */
- (void)deleteRemoteVideoFiles:(NSArray<RemoteFile *> *)files
                       started:(void (^)(void))started
          withSingleCompletion:(void (^)(RemoteFile *, NSArray<RemoteFile *> *, NSError *_Nullable))singleCompletion
                withCompletion:(BWCompletionBlock)completion
{
//    [BWSocketWrapper.sharedInstance stopRecordWithCompletion:^(NSError * _Nullable error) {
//        if (error) {
//            // 停止录制错误
//            completion(error);
//        } else {    // 停止录制OK
            // 开始执行动作
            [FTPManager.sharedInstance changeToVideoDirectory:^(NSError * _Nullable error) {
                if (error) {
                    completion(error);
                } else {
                    started();
                    [self deleteRemoteFiles_internal:files withSigleCompletion:singleCompletion withCompletion:completion];
                }
            }];
//        }
//    }];
}

/**
 *  删除多个图像文件，删除之前应该补全路径
 */
- (void)deleteRemoteImageFiles:(NSArray<RemoteFile *> *)files
                       started:(void (^)(void))started
          withSingleCompletion:(void (^)(RemoteFile *, NSArray<RemoteFile *> *, NSError *_Nullable))singleCompletion
                withCompletion:(BWCompletionBlock)completion
{
//    [BWSocketWrapper.sharedInstance stopRecordWithCompletion:^(NSError * _Nullable error) {
//        if (error) {
//            // 停止录制错误
//            completion(error);
//        } else {    // 停止录制OK
            // 开始执行动作
            [FTPManager.sharedInstance changeToImageDirectory:^(NSError * _Nullable error) {
                if (error) {
                    completion(error);
                } else {
                    started();
                    [self deleteRemoteFiles_internal:files withSigleCompletion:singleCompletion withCompletion:completion];
                }
            }];
//        }
//    }];
}

/**
 *  删除多个文件，删除之前应该补全路径
 */
- (void)deleteRemoteFiles_internal:(NSArray<RemoteFile *> *)files
               withSigleCompletion:(void (^)(RemoteFile *remoteFile, NSArray<RemoteFile *> *remoteFiles, NSError *_Nullable error))singleCompletion
                    withCompletion:(BWCompletionBlock)completion
{
    // 如果数组文件为0，则返回
    if (files.count == 0) {
        completion(nil);
        return;
    }
    
    NSMutableArray *remoteFiles = [NSMutableArray arrayWithArray:files];
    RemoteFile *remoteFile = [remoteFiles firstObject];
    [remoteFiles removeObject:remoteFile];
    
    FTPHandle *handle = [FTPHandle handleAtPath:nil attributes:@{(id)kCFFTPResourceName:remoteFile.name, (id)kCFFTPResourceType:@(FTPHandleTypeFile)}];
    
    [FTPManager.sharedInstance deleteFile:handle withCompletion:^(NSError * _Nullable error) {
        if (error) {
            singleCompletion(remoteFile, remoteFiles, error);
        } else {
            singleCompletion(remoteFile, remoteFiles, nil);
        }
        // 不论是否发生错误，继续下一个删除任务，递归调用
        [self deleteRemoteFiles_internal:remoteFiles withSigleCompletion:singleCompletion withCompletion:completion];
    }];
}

#pragma mark - DOWNLOAD

/**
 *  下载多个视频文件，下载文件之前应该补全路径
 */
- (void)downloadRemoteVideoFiles:(NSArray<RemoteFile *> *)files
                         started:(void (^)(NSString *fileName))started
                        progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
                  withCompletion:(BWCompletionBlock)completion
{
//    [BWSocketWrapper.sharedInstance stopRecordWithCompletion:^(NSError * _Nullable error) {
//        if (error) {
//            // 停止录制错误
//            completion(error);
//        } else {    // 停止录制OK
            // 开始执行动作
            [FTPManager.sharedInstance changeToVideoDirectory:^(NSError * _Nullable error) {
                if (error) {
                    completion(error);
                } else {
                    [self downloadRemoteFiles_internal:files
                                               started:started
                                              progress:progress
                                        withCompletion:completion];
                }
            }];
//        }
//    }];
}

/**
 *  下载多个图像文件，下载文件之前应该补全路径
 */
- (void)downloadRemoteImageFiles:(NSArray<RemoteFile *> *)files
                         started:(void (^)(NSString *fileName))started
                        progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
                  withCompletion:(BWCompletionBlock)completion
{
//    [BWSocketWrapper.sharedInstance stopRecordWithCompletion:^(NSError * _Nullable error) {
//        if (error) {
//            // 停止录制错误
//            completion(error);
//        } else {    // 停止录制OK
// 开始执行动作
            [FTPManager.sharedInstance changeToImageDirectory:^(NSError * _Nullable error) {
                if (error) {
                    completion(error);
                } else {
                    [self downloadRemoteFiles_internal:files
                                               started:started
                                              progress:progress
                                        withCompletion:completion];
                }
            }];
//        }
//    }];
}

/**
 *  下载多个文件，下载文件之前应该补全路径
 */
- (void)downloadRemoteFiles_internal:(NSArray<RemoteFile *> *)files
                             started:(void (^)(NSString *fileName))started
                            progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
                      withCompletion:(BWCompletionBlock)completion
{
    // 如果数组文件数为0，则返回
    if (files.count == 0) {
        completion(nil);
        return;
    }

    // 置中止标记
    _abortedDownload = NO;

    // 获取当前文件，并从队列中移除
    NSMutableArray *remoteFiles = [NSMutableArray arrayWithArray:files];
    RemoteFile *remoteFile = [remoteFiles firstObject];
    [remoteFiles removeObject:remoteFile];

    FTPHandle *handle = [FTPHandle handleAtPath:nil attributes:@{(id)kCFFTPResourceSize:@(remoteFile.size), (id)kCFFTPResourceName:remoteFile.name}];
    
    NSString *localFilePath = remoteFile.storePath;
    NSString *tempFilePath = remoteFile.tempPath;
    
    unsigned long long restartAt = remoteFile.resumeDownload ? remoteFile.localSize : 0;

    // If downloaded
    if (remoteFile.downloaded) {
//        // 删除本地已下载文件，后面会重新下载
//        [[NSFileManager defaultManager] removeItemAtPath:localFilePath error:nil];
        // or
        // 如果本地文件已经存在，继续下一个，递归调用
        [self downloadRemoteFiles_internal:remoteFiles
                                   started:started
                                  progress:progress
                            withCompletion:completion];
        return;
    }
    // If overwrite
    if (!remoteFile.resumeDownload) {
        // 删除临时文件
        [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
    }

    started(handle.name);
    [FTPManager.sharedInstance downloadFile:handle
                                         to:tempFilePath
                                  restartAt:restartAt
                                   progress:^BOOL(NSUInteger received, NSUInteger totalBytes) {

                                       // 这个逻辑可能还是需要修改一下
                                       if (self->_abortedDownload)
                                           totalBytes = 0;
                                       progress((NSUInteger)(restartAt + received), totalBytes);

                                       return !self->_abortedDownload;    // 返回是否继续下载
                                   }
                             withCompletion:^(NSError * _Nullable error) {

                                 // 如果用户中止，则返回
                                 if (self->_abortedDownload) {
                                     NSError *err = [NSError BWSDKMediaManagerErrorForCode:BWSDKMediaManagerErrorUserAborted];
                                     completion(err);
                                     return;
                                 } else {
                                     // 如果发生错误，则返回
                                     if (error) {
                                         completion(error);
                                     } else {
                                         // Rename to remove "~"
                                         NSError *error;
                                         if (![[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:localFilePath error:&error]) {
//                                             completion(error);   // TODO: 如果是重命名失败，再想想怎么处理，暂时不用这种方式结束
                                         }

                                         // 如果一个文件下载完毕，继续下一个，递归调用
                                         [self downloadRemoteFiles_internal:remoteFiles
                                                                    started:started
                                                                   progress:progress
                                                             withCompletion:completion];
                                     }
                                 }
                             }];
}

- (void)cancelDownload
{
    _abortedDownload = YES;
}

#pragma mark - LOCAL LISTING

- (void)getAllLocalVideoFilesWithCompletion:(BWArrayCompletionBlock)completion
{
    dispatch_async(dispatch_queue_create("GetLocalVideoFileList", 0), ^{
        NSArray<LocalFile *> *files = [self getAllLocalVideoFiles];
        completion(files, nil);
    });
}

- (NSArray<LocalFile *> *)getAllLocalVideoFiles
{
    NSString *videoDir = [Utilities videoDirPath];
    NSArray<LocalFile *> *filesList = [self getAllLocalFilesInPath:videoDir withExtName:LOCAL_VIDEO_SUFFIX];
    
    for (LocalFile *localFile in filesList) {
        localFile.isVideo = YES;
    }
    
    return filesList;
}

- (void)getAllLocalImageFilesWithCompletion:(BWArrayCompletionBlock)completion
{
    dispatch_async(dispatch_queue_create("GetLocalImageFileList", 0), ^{
        NSArray<LocalFile *> *files = [self getAllLocalImageFiles];
        completion(files, nil);
    });
}

- (NSArray<LocalFile *> *)getAllLocalImageFiles
{
    NSString *imageDir = [Utilities photoDirPath];
    NSArray<LocalFile *> *filesList = [self getAllLocalFilesInPath:imageDir withExtName:LOCAL_IMAGE_SUFFIX];
    
    for (LocalFile *localFile in filesList) {
        localFile.isVideo = NO;
    }
    
    return filesList;
}

- (NSArray<LocalFile *> *)getAllLocalFilesInPath:(NSString *)dirPath withExtName:(NSString *)extName
{
    NSMutableArray *filesList = [NSMutableArray array];
    
    NSString *cardMediaDir = dirPath;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cardMediaDir error:nil];
    
    // Filter
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[cd] %@", extName];
    files = [files filteredArrayUsingPredicate:predicate];
    
    for (NSString *fileName in files) {
        NSString *fullPath = [cardMediaDir stringByAppendingPathComponent:fileName];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (!isDir) {
                LocalFile *file = [[LocalFile alloc] init];
                file.name = fileName;
                file.fullPath = fullPath;
                
                NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
                if (attrs)
                    file.size = [attrs fileSize];
                
                [filesList addObject:file];
            }
        }
    }
    
    return filesList;
}

#pragma mark - Thumbnail

- (void)createImageThumbnailURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion
{
    UIImage *image = [self.thumbnailCache imageFromDiskCacheForKey:urlString];
    if (image) {
        completion(image, nil);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *srcImage = [UIImage imageWithContentsOfFile:urlString];
            
            float newWidth = 320;
            float oldWidth = srcImage.size.width;
            float scaleFactor = newWidth / oldWidth;
            float newHeight = srcImage.size.height * scaleFactor;
            
            UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
            [srcImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (image != nil) {
                [self.thumbnailCache storeImage:image
                                         forKey:urlString
                                     completion:^{
                                         completion(image, nil);
                                     }];
            }
        });
    }
}

- (void)createVideoThumbnailURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion
{
    UIImage *image = [self.thumbnailCache imageFromDiskCacheForKey:urlString];
    if (image) {
        completion(image, nil);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL fileURLWithPath:urlString];
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
            
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generator.maximumSize = CGSizeMake(320, 320);
            generator.appliesPreferredTrackTransform = YES;
            CMTime thumbnaiTime = CMTimeMakeWithSeconds(0, 30);
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                
                if (result != AVAssetImageGeneratorSucceeded || im == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        completion(nil, error);
                    });
                } else {
                    UIImage *image = [UIImage imageWithCGImage:im];
                    if (image != nil) {
                        [self.thumbnailCache storeImage:image
                                                 forKey:urlString
                                             completion:^{
                                                 completion(image, nil);
                                             }];
                    }
                }
            };
            
            [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbnaiTime]]
                                            completionHandler:handler];
        });
    }
}

@end
