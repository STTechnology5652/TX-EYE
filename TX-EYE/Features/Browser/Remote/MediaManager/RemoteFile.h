//
//  RemoteFile.h
//  FTPtest
//
//  Created by CoreCat on 2017/6/28.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "MediaFile.h"

typedef enum {
    RemoteFileTypeUnknown = 0,
    RemoteFileTypeDirectory = 1,
    RemoteFileTypeFile = 2,
} RemoteFileType;


@interface RemoteFile : MediaFile

@property (nonatomic, strong) NSDate *modified;
@property (nonatomic, assign) RemoteFileType type;

@property (nonatomic, assign) unsigned long long localSize;

@property (nonatomic, strong) NSString *storePath;
@property (nonatomic, strong) NSString *tempPath;

@property (nonatomic, strong) NSString *thumbPath;
@property (nonatomic, strong) NSString *webPath;

@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, assign) BOOL tempExist;

@property (nonatomic, assign) BOOL sizeMismatch;
@property (nonatomic, assign) BOOL resumeDownload;

@end
