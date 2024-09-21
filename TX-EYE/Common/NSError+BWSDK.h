//
//  NSError+BWSDK.h
//  FTPtest
//
//  Created by CoreCat on 2017/6/27.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Error Domains
/*********************************************************************************/


/**
 *  SDK common error domain.
 */
FOUNDATION_EXPORT NSString * _Nonnull const BWSDKErrorDomain;


/**
 *  SDK camera error domain.
 */
FOUNDATION_EXPORT NSString *_Nonnull const BWSDKFTPManagerErrorDomain;


/*********************************************************************************/
#pragma mark BWSDKError
/*********************************************************************************/


/**
 *  BW SDK Error.
 */
typedef NS_ENUM (NSInteger, BWSDKError){
    
    
    /**
     *  Feature not supported error.
     */
    BWSDKErrorSDKFeatureNotSupported = -1000L,
    
    
    /**
     *  Timeout error.
     */
    BWSDKErrorTimeout = -1003L,
    
    
    /**
     *  Parameters invalid error.
     */
    BWSDKErrorInvalidParameters = -1005L,
    
    
    /**
     *  Get parameter failed error.
     */
    BWSDKErrorParameterGetFailed = -1006L,
    
    
    /**
     *  Setting parameters operation failed.
     */
    BWSDKErrorParameterSetFailed = -1007L,
    
    
    /**
     *  Command execute failed error.
     */
    BWSDKErrorCommandExecutionFailed = -1008L,
    
    
    /**
     *  Send data failed error.
     */
    BWSDKErrorSendDataFailed = -1009L,
    
    
    /**
     *  The received data is invalid.
     */
    BWSDKErrorReceivedDataInvalid = -1016L,
    
    
    /**
     *  No data is received.
     */
    BWSDKErrorNoReceivedData = -1017L,
    
    
    /**
     *  Operation is cancelled.
     */
    BWSDKErrorOperationCancelled = -1019L,
    
    
    /**
     *  Not defined error.
     */
    BWSDKErrorNotDefined = -1999L,
};


/*********************************************************************************/
#pragma mark BWSDKFTPManagerError
/*********************************************************************************/


/**
 *  BW SDK FTPManager Error.
 */
typedef NS_ENUM (NSInteger, BWSDKFTPManagerError){
    
    
    /**
     *  Executed failed.
     */
    BWSDKFTPManagerErrorExecutedFailed = -3000L,
    
    
    /**
     *  No SD card.
     */
    BWSDKFTPManagerErrorSDCardNotInserted = -3004L,
    
    
    /**
     *  SD card full.
     */
    BWSDKFTPManagerErrorSDCardFull = -3005L,
    
    
    /**
     *  SD card error.
     */
    BWSDKFTPManagerErrorSDCardError = -3006L,
    
    
    /**
     *  The media file is not found in SD card.
     */
    BWSDKFTPManagerErrorNoSuchMediaFile = -3010L,
    
    
    /**
     *  The command is aborted unexpectedly.
     */
    BWSDKFTPManagerErrorMediaCommandAborted = -3011L,
    
    
    /**
     *  Data is corrupted during the file transmission.
     */
    BWSDKFTPManagerErrorMediaFileDataCorrupted = -3012L,
    
    
    /**
     *  The media command is invalid.
     */
    BWSDKFTPManagerErrorInvalidMediaCommand = -3013L,
    
    
    /**
     *  The download process of BWPlaybackManager is interrupted.
     */
    BWSDKFTPManagerErrorPlaybackDownloadInterruption = -3015L,
    
    
    /**
     *  There is no downloading files to stop.
     */
    BWSDKFTPManagerErrorPlaybackNoDownloadingFiles = -3016L,
    
    
    /**
     *  Media file is reset. The operation cannot be executed.
     */
    BWSDKFTPManagerErrorMediaFileReset = -3020L,
};


/*********************************************************************************/
#pragma mark BWSDKFTPManagerError
/*********************************************************************************/


/**
 *  BW SDK FTPManager Error.
 */
typedef NS_ENUM (NSInteger, BWSDKMediaManagerError){
    
    
    /**
     *  Executed failed.
     */
    BWSDKMediaManagerErrorExecutedFailed = -4000L,
    
    /**
     *  User Aborted.
     */
    BWSDKMediaManagerErrorUserAborted = -4001L
};


/*********************************************************************************/
#pragma mark BWSDKBWSoekctError
/*********************************************************************************/


/**
 *  BW SDK FTPManager Error.
 */
typedef NS_ENUM (NSInteger, BWSDKBWSoekctError){
    
    
    /**
     *  Connection failed.
     */
    BWSDKBWSoekctErrorConnectionFailed = -5000L,
    
    /**
     *  Fetch information failed.
     */
    BWSDKBWSoekctErrorInformationFetchFailed = -5001L
};


@interface NSError (BWSDK)


/**
 *  Get BWSDKError.
 *
 *  @param errorCode errorCode for `BWSDKError`.
 *
 *  @return An NSError object initialized with errorCode. If the errorCode was 0, returns nil.
 */
+ (_Nullable instancetype)BWSDKErrorForCode:(NSInteger)errorCode;


/**
 *  Get BWSDKFTPManagerError.
 *
 *  @param errorCode errorCode for `BWSDKFTPManagerError`.
 *
 *  @return An NSError object initialized with errorCode. If the errorCode was 0, returns nil.
 */
+ (_Nullable instancetype)BWSDKFTPManagerErrorForCode:(NSInteger)errorCode;


/**
 *  Get BWSDKMediaManagerError.
 *
 *  @param errorCode errorCode for `BWSDKMediaManagerError`.
 *
 *  @return An NSError object initialized with errorCode. If the errorCode was 0, returns nil.
 */
+ (_Nullable instancetype)BWSDKMediaManagerErrorForCode:(NSInteger)errorCode;


/**
 *  Get BWSDKBWSocketError.
 *
 *  @param errorCode errorCode for `BWSDKBWSocketError`.
 *
 *  @return An NSError object initialized with errorCode. If the errorCode was 0, returns nil.
 */
+ (_Nullable instancetype)BWSDKBWSocketErrorForCode:(NSInteger)errorCode;


/**
 *  Get BWSDKError.
 *
 *  @param errorCode Error code for `BWSDKError`.
 *  @param errorDomain Domain for `BWSDKError`.
 *  @param desc Description for `BWSDKError`.
 *
 *  @return An NSError object initialized with errorCode, errorDomain and desc.
 */
+ (_Nullable instancetype)BWSDKErrorForCode:(NSInteger)errorCode domain:(NSString *_Nonnull)errorDomain desc:(const NSString *_Nonnull)desc;

@end

NS_ASSUME_NONNULL_END
