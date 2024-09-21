#import "Utilities.h"

@implementation Utilities

#define VIDEO_PATH  @"Video"
#define IMAGE_PATH  @"Image"

#define PHOTO_FILE_EXTENSION_1  @"png"
#define PHOTO_FILE_EXTENSION_2  @"jpg"
#define VIDEO_FILE_EXTENSION_1  @"mov"
#define VIDEO_FILE_EXTENSION_2  @"mp4"
#define VIDEO_FILE_EXTENSION_3  @"avi"

/**
 *  返回Bundle内文件的路径
 *
 *  @param fileName 文件名
 *
 *  @return 返回的路径
 */
+ (NSString *)bundlePath:(NSString *)fileName {
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

/**
 *  返回Document目录下文件路径
 *
 *  @param fileName 文件名
 *
 *  @return 返回的路径
 */
+ (NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

/**
 *  返回Document路径
 *
 *  @return Document路径
 */
+ (NSString *)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

/**
 *  返回以当天日期作为路径的目录名
 *  自动创建目录，成功返回目录名，不成功返回nil
 */
+ (NSString *)mediaDirPath
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dirName = [dateFormatter stringFromDate:date];
    NSString *dirPath = [[Utilities documentPath] stringByAppendingPathComponent:dirName];

    if ([[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil])
        return dirPath;

    return nil;
}

/**
 *  返回以时间作为路径的文件名
 */
+ (NSString *)mediaFileName
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmmssSSS"];
    NSString *fileName = [dateFormatter stringFromDate:date];

    return fileName;
}

/**
 *  返回路径下的目录列表
 *
 *  @param path 路径
 *
 *  @return 目录列表
 */
+ (NSArray *)directoriesAtPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    NSMutableArray *directoriesList = [NSMutableArray array];
    
    NSArray *tmpList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    tmpList = [[tmpList reverseObjectEnumerator] allObjects];
    for (NSString *pathName in tmpList) {
        NSString *fullPath = [path stringByAppendingPathComponent:pathName];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                [directoriesList addObject:pathName];
            }
        }
    }
    
    return directoriesList;
}

/**
 *  返回路径下的文件列表
 *
 *  @param path 路径
 *
 *  @return 文件列表
 */
+ (NSArray *)filesAtPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    NSMutableArray *filesList = [NSMutableArray array];
    
    NSArray *tmpList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    tmpList = [[tmpList reverseObjectEnumerator] allObjects];
    for (NSString *fileName in tmpList) {
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (!isDir) {
                [filesList addObject:fileName];
            }
        }
    }
    
    return filesList;
}

/**
 *  写数据到指定的文件中
 *
 *  @param data     数据
 *  @param fileName 文件名
 *  @param dirName  目录名
 *
 *  @return 是否成功写入
 */
+ (BOOL)writeData:(NSData *)data toFile:(NSString *)fileName inDocumentDir:(NSString *)dirName
{
    NSString *dirFullPath = [self documentsPath:dirName];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirFullPath isDirectory:&isDir]) {
        if (!isDir)
            return NO;
    }
    else {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dirFullPath withIntermediateDirectories:YES attributes:nil error:NULL])
            return NO;
    }
    
    NSString *fileFullPath = [dirFullPath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] createFileAtPath:fileFullPath contents:data attributes:nil])
        return NO;
    
    return YES;
}

/**
 *  返回指定文件的全路径
 *
 *  @param fileName 文件名
 *  @param dirName  目录名
 *
 *  @return 路径
 */
+ (NSString *)fullPathOfFile:(NSString *)fileName inDocumentDir:(NSString *)dirName
{
    NSString *dirFullPath = [self documentsPath:dirName];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirFullPath isDirectory:&isDir]) {
        if (!isDir)
            return nil;
    }
    else {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dirFullPath withIntermediateDirectories:YES attributes:nil error:NULL])
            return nil;
    }
    NSString *fileFullPath = [dirFullPath stringByAppendingPathComponent:fileName];
    
    return fileFullPath;
}

/**
 *  移除指定目录下的文件
 *
 *  @param fileName 文件名
 *  @param dirName  目录名
 *
 *  @return 是否成功删除文件
 */
+ (BOOL)removeFile:(NSString *)fileName inDocumentDir:(NSString *)dirName
{
    NSString *dirFullPath = [self documentsPath:dirName];
    NSString *fileFullPath = [dirFullPath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:NULL]) {
        return NO;
    }
    // delete empty dir
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirFullPath error:NULL];
    if (fileList.count == 0) {
        if (![[NSFileManager defaultManager] removeItemAtPath:dirFullPath error:NULL]) {
            return NO;
        }
    }
    return YES;
}

/**
 *  返回指定类型文件的列表
 *
 *  @param type 文件类型
 *
 *  @return 文件列表
 */
+ (NSArray *)loadListOfType:(MediaFileType)type
{
    NSString *documentPath = [self documentPath];
    NSArray *dirsList = [self directoriesAtPath:documentPath];
    
    NSMutableArray *dirItems = [NSMutableArray array];
    // 遍历目录
    for (NSString *dirName in dirsList) {
        NSString *fullDirPath = [documentPath stringByAppendingPathComponent:dirName];
        
        NSArray *filesList = [self filesAtPath:fullDirPath];
        
        NSMutableArray *fileItems = [NSMutableArray array];
        // 遍历文件
        if (type == MediaFileTypePhoto) {
            for (NSString *fileName in filesList) {
                NSString *fullFilePath = [fullDirPath stringByAppendingPathComponent:fileName];
                if (([[fileName pathExtension] caseInsensitiveCompare:PHOTO_FILE_EXTENSION_1] == NSOrderedSame)
                    || ([[fileName pathExtension] caseInsensitiveCompare:PHOTO_FILE_EXTENSION_2] == NSOrderedSame)) {
                    [fileItems addObject:@{@"FileName":fileName,
                                           @"FilePath":fullFilePath}];
                }
            }
        } else if (type == MediaFileTypeVideo) {
            for (NSString *fileName in filesList) {
                NSString *fullFilePath = [fullDirPath stringByAppendingPathComponent:fileName];
                if (([[fileName pathExtension] caseInsensitiveCompare:VIDEO_FILE_EXTENSION_1] == NSOrderedSame)
                    || ([[fileName pathExtension] caseInsensitiveCompare:VIDEO_FILE_EXTENSION_2] == NSOrderedSame)
                    || ([[fileName pathExtension] caseInsensitiveCompare:VIDEO_FILE_EXTENSION_3] == NSOrderedSame)) {
                    [fileItems addObject:@{@"FileName":fileName,
                                           @"FilePath":fullFilePath}];
                }
            }
        }
        // sort
        NSArray *sortedFileItems =
        [fileItems sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull item1, NSDictionary * _Nonnull item2) {
            NSString *fullFilePath1 = item1[@"FilePath"];
            NSString *fullFilePath2 = item2[@"FilePath"];
            NSDictionary *fileInfo1 = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath1 error:nil]; // 获取前一个文件信息
            NSDictionary *fileInfo2 = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath2 error:nil]; // 获取后一个文件信息
            NSDate *date1 = [fileInfo1 objectForKey:NSFileModificationDate]; // 获取前一个文件修改时间
            NSDate *date2 = [fileInfo2 objectForKey:NSFileModificationDate]; // 获取后一个文件修改时间
            return [date2 compare:date1]; // 降序
        }];
        // 如果文件数不为0，添加到目录项中
        if (fileItems.count > 0) {
            [dirItems addObject:@{@"DirName":dirName,
                                  @"DirPath":fullDirPath,
                                  @"FileItems":sortedFileItems}];
        }
    }
    
    return [dirItems sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull item1, NSDictionary * _Nonnull item2) {
        NSString *fullFilePath1 = item1[@"DirPath"];
        NSString *fullFilePath2 = item2[@"DirPath"];
        NSDictionary *fileInfo1 = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath1 error:nil]; // 获取前一个文件信息
        NSDictionary *fileInfo2 = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath2 error:nil]; // 获取后一个文件信息
        NSDate *date1 = [fileInfo1 objectForKey:NSFileModificationDate]; // 获取前一个文件修改时间
        NSDate *date2 = [fileInfo2 objectForKey:NSFileModificationDate]; // 获取后一个文件修改时间
        return [date2 compare:date1]; // 降序
    }];
}

#pragma mark - New path structure

/* 返回视频目录 */
+ (NSString *)fullPathOfVideoDirectory
{
    return [[self documentPath] stringByAppendingPathComponent:VIDEO_PATH];
}

/* 返回图像目录 */
+ (NSString *)fullPathOfImageDirectory
{
    return [[self documentPath] stringByAppendingPathComponent:IMAGE_PATH];
}

/* 返回视频目录，如果不存在则创建 */
+ (NSString *)createIfNotExistVideoDirectory
{
    NSString *videoDir = [self fullPathOfVideoDirectory];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoDir isDirectory:&isDir]) {
        //
    } else {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:NULL])
            return nil;
    }
    return videoDir;
}

/* 返回图像目录，如果不存在则创建 */
+ (NSString *)createIfNotExistImageDirectory
{
    NSString *imageDir = [self fullPathOfVideoDirectory];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageDir isDirectory:&isDir]) {
        //
    } else {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:NULL])
            return nil;
    }
    return imageDir;
}

/* 返回path路径中，type类型的文件 */
+ (NSArray *)loadListOfType:(MediaFileType)type atPath:(NSString *)path
{
    NSArray *filesList = [self filesAtPath:path];

    NSMutableArray *fileItems = [NSMutableArray array];
    // 遍历文件
    if (type == MediaFileTypePhoto) {
        for (NSString *fileName in filesList) {
            NSString *fullFilePath = [path stringByAppendingPathComponent:fileName];
            if ([[fileName pathExtension] isEqualToString:PHOTO_FILE_EXTENSION_1]
                || [[fileName pathExtension] isEqualToString:PHOTO_FILE_EXTENSION_2]) {
                [fileItems addObject:@{@"FileName":fileName,
                                       @"FilePath":fullFilePath}];
            }
        }
    } else if (type == MediaFileTypeVideo) {
        for (NSString *fileName in filesList) {
            NSString *fullFilePath = [path stringByAppendingPathComponent:fileName];
            if ([[fileName pathExtension] isEqualToString:VIDEO_FILE_EXTENSION_1]
                || [[fileName pathExtension] isEqualToString:VIDEO_FILE_EXTENSION_2]
                || [[fileName pathExtension] isEqualToString:VIDEO_FILE_EXTENSION_3]) {
                [fileItems addObject:@{@"FileName":fileName,
                                       @"FilePath":fullFilePath}];
            }
        }
    }

    return [fileItems sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull item1, NSDictionary * _Nonnull item2) {
        NSString *fullFilePath1 = item1[@"FilePath"];
        NSString *fullFilePath2 = item2[@"FilePath"];
        NSDictionary *fileInfo1 = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath1 error:nil]; // 获取前一个文件信息
        NSDictionary *fileInfo2 = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath2 error:nil]; // 获取后一个文件信息
        NSDate *date1 = [fileInfo1 objectForKey:NSFileModificationDate]; // 获取前一个文件修改时间
        NSDate *date2 = [fileInfo2 objectForKey:NSFileModificationDate]; // 获取后一个文件修改时间
        return [date2 compare:date1]; // 降序
    }];
}

/**
 *  本地视频目录路径
 */
+ (NSString *)videoDirPath
{
    NSString *dirPath = [[self documentPath] stringByAppendingPathComponent:VIDEO_PATH];
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil])
    return dirPath;
    
    return nil;
}

+ (NSString *)fullPathInVideoDir:(NSString *)fileName
{
    return [[self mediaDirPath] stringByAppendingPathComponent:fileName];
}

/**
 *  本地照片目录路径
 */
+ (NSString *)photoDirPath
{
    NSString *dirPath = [[self documentPath] stringByAppendingPathComponent:IMAGE_PATH];
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil])
    return dirPath;
    
    return nil;
}

+ (NSString *)fullPathInPhotoDir:(NSString *)fileName
{
    return [[self mediaDirPath] stringByAppendingPathComponent:fileName];
}

/* File manager */

/**
 *  移除指定目录下的文件
 *
 *  @param filePath 文件路径
 *
 *  @return 是否成功删除文件
 */
+ (BOOL)removeFile:(NSString *)filePath
{
    NSString *fileFullPath = filePath;
    
    if (![[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:NULL]) {
        return NO;
    }
    return YES;
}

/* Disk space */

#pragma mark - Disk space

+ (NSString *)memoryFormatter:(unsigned long long)diskSpace
{
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double kilobytes = bytes / 1024;
    double megabytes = bytes / (1024 * 1024);
    double gigabytes = bytes / (1024 * 1024 * 1024);
    if (gigabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else if (kilobytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f KB", kilobytes];
    else
        formatted = [NSString stringWithFormat:@"%.0f bytes", bytes];
    
    return formatted;
}

+ (NSString *)totalDiskSpace
{
    return [self memoryFormatter:[self totalDiskSpaceInBytes]];
}

+ (NSString *)freeDiskSpace
{
    return [self memoryFormatter:[self freeDiskSpaceInBytes]];
}

+ (NSString *)usedDiskSpace
{
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (unsigned long long)totalDiskSpaceInBytes
{
    unsigned long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] unsignedLongLongValue];
    return space;
}

+ (unsigned long long)freeDiskSpaceInBytes
{
    unsigned long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    return freeSpace;
}

+ (unsigned long long)usedDiskSpaceInBytes
{
    long long usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}

#pragma mark - Main bundle

+ (NSString *)getAppName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

#pragma mark - File properties

+ (unsigned long long)getFileSizeAtPath:(NSString *)filePath
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    return attributes.fileSize;
}

#pragma mark - Screen

+ (void)keepScreenOn:(BOOL)on
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (on) {
            // 禁用自动锁屏
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        } else {
            // 恢复自动锁屏
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
    });
}

@end
