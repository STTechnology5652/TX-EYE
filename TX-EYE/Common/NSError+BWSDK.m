//
//  NSError+BWSDK.m
//  FTPtest
//
//  Created by CoreCat on 2017/6/27.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "NSError+BWSDK.h"

NSString * const BWSDKErrorDomain = @"sky.error";
NSString * const BWSDKFTPManagerErrorDomain = @"sky.error.ftpmanager";
NSString * const BWSDKMediaManagerErrorDomain = @"sky.error.mediamanager";

@implementation NSError (BWSDK)

+ (_Nullable instancetype)BWSDKErrorForCode:(NSInteger)errorCode
{
    NSString *desc = nil;
    
    switch (errorCode) {
        case BWSDKErrorTimeout:
            desc = @"Time out";
            break;
            
        default:
            desc = @"Unknown error";
            break;
    }
    
    return [self BWSDKErrorForCode:errorCode domain:BWSDKErrorDomain desc:desc];
}

+ (_Nullable instancetype)BWSDKFTPManagerErrorForCode:(NSInteger)errorCode
{
    NSString *desc = nil;
    
    switch (errorCode) {
        case BWSDKFTPManagerErrorExecutedFailed:
            desc = @"Executed failed";
            break;
            
        default:
            desc = @"Unknown error";
            break;
    }
    
    return [self BWSDKErrorForCode:errorCode domain:BWSDKFTPManagerErrorDomain desc:desc];
}

+ (_Nullable instancetype)BWSDKMediaManagerErrorForCode:(NSInteger)errorCode
{
    NSString *desc = nil;
    
    switch (errorCode) {
        case BWSDKMediaManagerErrorExecutedFailed:
            desc = @"Executed failed";
            break;
        case BWSDKMediaManagerErrorUserAborted:
            desc = @"User aborted";
            break;
            
        default:
            desc = @"Unknown error";
            break;
    }
    
    return [self BWSDKErrorForCode:errorCode domain:BWSDKMediaManagerErrorDomain desc:desc];
}

+ (_Nullable instancetype)BWSDKBWSocketErrorForCode:(NSInteger)errorCode
{
    NSString *desc = nil;
    
    switch (errorCode) {
        case BWSDKBWSoekctErrorConnectionFailed:
            desc = @"Connection failed";
            break;
        case BWSDKBWSoekctErrorInformationFetchFailed:
            desc = @"Fetch information failed";
            break;
            
        default:
            desc = @"Unknown error";
            break;
    }
    
    return [self BWSDKErrorForCode:errorCode domain:BWSDKMediaManagerErrorDomain desc:desc];
}

+ (_Nullable instancetype)BWSDKErrorForCode:(NSInteger)errorCode domain:(NSString *_Nonnull)errorDomain desc:(const NSString *_Nonnull)desc
{
    return [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:desc}];
}

@end
