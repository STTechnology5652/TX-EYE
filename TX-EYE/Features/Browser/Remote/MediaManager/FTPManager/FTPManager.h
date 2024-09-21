//
//  FTPManager.h
//  FTPtest
//
//  Created by CoreCat on 2017/6/26.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWSDKFoundation.h"
#import "FTPHandle.h"

/**
 * 对FTPKit框架的封装
 */

@interface FTPManager : NSObject

// ----------------------------------------------------------------------------

/**
 *  单例
 */
+ (instancetype)sharedInstance;

// ----------------------------------------------------------------------------

/**
 *  重置到根目录
 */
- (void)resetToRootDirectoryWithCompletion:(BWCompletionBlock)completion;

/**
 *  改变当前路径
 */
- (void)changeDirectoryToPath:(NSString *)path withCompletion:(BWCompletionBlock)completion;

/**
 *  进入视频目录
 */
- (void)changeToVideoDirectory:(BWCompletionBlock)completion;

/**
 *  进入图像目录
 */
- (void)changeToImageDirectory:(BWCompletionBlock)completion;

// ----------------------------------------------------------------------------

/**
 *  获取文件列表
 */
- (void)listFilesWithCompletion:(BWArrayCompletionBlock)completion;

/**
 *  获取文件列表（使用过滤器）
 */
- (void)listFilesWithSuffix:(NSString *)suffix withCompletion:(BWArrayCompletionBlock)completion;

// ----------------------------------------------------------------------------

/**
 *  下载单个文件
 */
- (void)downloadFile:(FTPHandle *)handle to:(NSString *)localFullPath
           restartAt:(unsigned long long)restartAt
            progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
      withCompletion:(BWCompletionBlock)completion;

// ----------------------------------------------------------------------------

/**
 *  删除单个文件
 */
- (void)deleteFile:(FTPHandle *)handle withCompletion:(BWCompletionBlock)completion;

@end
