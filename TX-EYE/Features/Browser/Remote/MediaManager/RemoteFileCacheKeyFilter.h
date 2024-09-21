//
//  RemoteFileCacheKeyFilter.h
//  GoTrack
//
//  Created by CoreCat on 2019/3/12.
//  Copyright © 2019年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImage.h>
#import "RemoteFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface RemoteFileCacheKeyFilter : NSObject <SDWebImageCacheKeyFilter>

- (nonnull instancetype)initWithRemoteFile:(RemoteFile *)remoteFile;
+ (nonnull instancetype)cacheKeyFilterWithRemoteFile:(RemoteFile *)remoteFile;

@end

NS_ASSUME_NONNULL_END
