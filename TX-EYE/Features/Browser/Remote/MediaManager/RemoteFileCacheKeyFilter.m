//
//  RemoteFileCacheKeyFilter.m
//  GoTrack
//
//  Created by CoreCat on 2019/3/12.
//  Copyright © 2019年 CoreCat. All rights reserved.
//

#import "RemoteFileCacheKeyFilter.h"

@interface RemoteFileCacheKeyFilter ()

@property (nonatomic, strong) RemoteFile *remoteFile;

@end

@implementation RemoteFileCacheKeyFilter

- (nonnull instancetype)initWithRemoteFile:(RemoteFile *)remoteFile
{
    self = [super init];
    if (self) {
        self.remoteFile = remoteFile;
    }
    return self;
}

+ (nonnull instancetype)cacheKeyFilterWithRemoteFile:(RemoteFile *)remoteFile
{
    RemoteFileCacheKeyFilter *cacheKeyFilter = [[RemoteFileCacheKeyFilter alloc] initWithRemoteFile:remoteFile];
    return cacheKeyFilter;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    NSString *cacheKey = [NSString stringWithFormat:@"%@?size=%llu", url.absoluteString, self.remoteFile.size];
    return cacheKey;
}

@end
