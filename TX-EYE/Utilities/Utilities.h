#import <UIKit/UIKit.h>

// 判断是否是iPhone X
#define is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

typedef NS_OPTIONS(NSUInteger, MediaFileType) {
    MediaFileTypePhoto = 1 << 0,
    MediaFileTypeVideo = 1 << 1,
};

@interface Utilities : NSObject

+ (NSString *)bundlePath:(NSString *)fileName;
+ (NSString *)documentsPath:(NSString *)fileName;

+ (NSString *)documentPath;
+ (NSString *)mediaDirPath;
+ (NSString *)mediaFileName;
+ (NSArray *)directoriesAtPath:(NSString *)path;
+ (NSArray *)filesAtPath:(NSString *)path;
+ (BOOL)writeData:(NSData *)data toFile:(NSString *)fileName inDocumentDir:(NSString *)dirName;
+ (NSString *)fullPathOfFile:(NSString *)fileName inDocumentDir:(NSString *)dirName;
+ (BOOL)removeFile:(NSString *)fileName inDocumentDir:(NSString *)dirName;
+ (NSArray *)loadListOfType:(MediaFileType)type;

/* NEW PATH STRUCTURE */

/* 返回视频目录 */
+ (NSString *)fullPathOfVideoDirectory;
/* 返回图像目录 */
+ (NSString *)fullPathOfImageDirectory;
/* 返回视频目录，如果不存在则创建 */
+ (NSString *)createIfNotExistVideoDirectory;
/* 返回图像目录，如果不存在则创建 */
+ (NSString *)createIfNotExistImageDirectory;
/* 返回path路径中，type类型的文件 */
+ (NSArray *)loadListOfType:(MediaFileType)type atPath:(NSString *)path;

/**
 *  本地视频目录路径
 */
+ (NSString *)videoDirPath;
+ (NSString *)fullPathInVideoDir:(NSString *)fileName;

/**
 *  本地照片目录路径
 */
+ (NSString *)photoDirPath;
+ (NSString *)fullPathInPhotoDir:(NSString *)fileName;

// ----------------------------------------------------------------------------
/* File manager */

+ (BOOL)removeFile:(NSString *)filePath;

/* Disk space */

+ (NSString *)memoryFormatter:(unsigned long long)diskSpace;
+ (NSString *)totalDiskSpace;
+ (NSString *)freeDiskSpace;
+ (NSString *)usedDiskSpace;
+ (unsigned long long)totalDiskSpaceInBytes;
+ (unsigned long long)freeDiskSpaceInBytes;
+ (unsigned long long)usedDiskSpaceInBytes;

/* Main bundle */
+ (NSString *)getAppName;

/* File properties */
+ (unsigned long long)getFileSizeAtPath:(NSString *)filePath;

// ----------------------------------------------------------------------------
/* Screen */

+ (void)keepScreenOn:(BOOL)on;

@end
