//
//  FTPManager.m
//  FTPtest
//
//  Created by CoreCat on 2017/6/26.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "FTPManager.h"
#import "FTPKit.h"
#import "ftplib.h"
#import "NSError+BWSDK.h"
#import "Config.h"


@interface FTPManager ()

@property (nonatomic, strong) FTPClient *ftpClient;

/** Queue used to enforce requests to process in synchronous order. */
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation FTPManager

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
    self = [super init];
    if (self) {
        FTPCredentials *credential = [[FTPCredentials alloc] initWithHost:FTP_HOST
                                                                     port:FTP_PORT
                                                                 username:FTP_USERNAME
                                                                 password:FTP_PASSWORD];
        self.ftpClient = [[FTPClient alloc] initWithCredentials:credential];
        // FTP settings, set as default
        self.ftpClient.accessType = FTPAccessTypeAuto;
        self.ftpClient.connectionMode = FTPConnectionModePassive;
        // For callback use
        self.ftpClient.idleTime = FTP_IDLETIME;
        self.ftpClient.cbBytes = FTP_CBBYTES;
        // Dispatch queue
        self.queue = dispatch_queue_create("FTPManagerQueue", DISPATCH_QUEUE_SERIAL);
        
        // ******************* DEBUG **********************
        ftplib_debug = 0;   // 0 to none, 3 to all
        // ******************* DEBUG **********************
    }
    return self;
}

#pragma mark - CHANGE DIR

/**
 *  Prepare to work
 */
- (void)resetToRootDirectoryWithCompletion:(BWCompletionBlock)completion
{
    dispatch_async(_queue, ^{
        // Adapt to Firmware
        BOOL s = [self.ftpClient changeDirectoryToPath:FTP_ROOT_DIR];
        
        if (completion) {
            if (s) {
                completion(nil);
            } else {
                NSError *error = [NSError BWSDKFTPManagerErrorForCode:BWSDKFTPManagerErrorExecutedFailed];
                completion(error);
            }
        }
    });
}

/**
 *  Change to Path
 */
- (void)changeDirectoryToPath:(NSString *)path withCompletion:(BWCompletionBlock)completion
{
    dispatch_async(_queue, ^{
        // Firmware don't reset directory to root, do it manually
        BOOL s = [self.ftpClient changeDirectoryToPath:FTP_ROOT_DIR];
        if (s) {
            s = [self.ftpClient changeDirectoryToPath:path];
        }
        
        if (completion) {
            if (s) {
                completion(nil);
            } else {
                NSError *error = [NSError BWSDKFTPManagerErrorForCode:BWSDKFTPManagerErrorExecutedFailed];
                completion(error);
            }
        }
    });
}

/**
 *  Change to Video Directory
 */
- (void)changeToVideoDirectory:(BWCompletionBlock)completion
{
    [self changeDirectoryToPath:VIDEO_PATH withCompletion:completion];
}

/**
 *  Change to Image Directory
 */
- (void)changeToImageDirectory:(BWCompletionBlock)completion
{
    [self changeDirectoryToPath:IMAGE_PATH withCompletion:completion];
}

#pragma mark - LISTING

/**
 *  List Files
 */
- (void)listFilesWithCompletion:(BWArrayCompletionBlock)completion
{
    [self listFilesWithSuffix:nil withCompletion:completion];
}

/**
 *  List Files with filter
 */
- (void)listFilesWithSuffix:(NSString *)suffix withCompletion:(BWArrayCompletionBlock)completion
{
    dispatch_async(_queue, ^{
        
        NSArray *files = [self.ftpClient listContentsAtPath:@"/" showHiddenFiles:NO];
        
        if (files) {
            if (suffix) {
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name ENDSWITH[cd] %@", suffix];
                NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1]];
                NSArray *filteredFiles = [files filteredArrayUsingPredicate:compoundPredicate];
                completion(filteredFiles, nil);
            } else {
                completion(files, nil);
            }
        } else {
            NSError *error = [NSError BWSDKFTPManagerErrorForCode:BWSDKFTPManagerErrorExecutedFailed];
            completion(nil, error);
        }
    });
}

#pragma mark - DOWNLOAD

/**
 *  Download a single file
 */
- (void)downloadFile:(FTPHandle *)handle to:(NSString *)localFullPath
           restartAt:(unsigned long long)restartAt
            progress:(BOOL (^)(NSUInteger received, NSUInteger totalBytes))progress
      withCompletion:(BWCompletionBlock)completion
{
    dispatch_async(_queue, ^{
        
        BOOL s = [self.ftpClient downloadHandle:handle to:localFullPath restartAt:restartAt progress:^BOOL(NSUInteger received, NSUInteger totalBytes) {
            if (progress)
                return progress(received, totalBytes);
            return YES;
        }];
        
        if (s) {
            completion(nil);
        } else {
            NSError *error = [NSError BWSDKFTPManagerErrorForCode:BWSDKFTPManagerErrorExecutedFailed];
            completion(error);
        }
    });
}

#pragma mark - DELETE

/**
 *  Delete a single file
 */
- (void)deleteFile:(FTPHandle *)handle withCompletion:(BWCompletionBlock)completion
{
    dispatch_async(_queue, ^{
        
        [self.ftpClient deleteHandle:handle success:^{
            completion(nil);
        } failure:^(NSError *error) {
            completion(error);
        }];
    });
}

@end
