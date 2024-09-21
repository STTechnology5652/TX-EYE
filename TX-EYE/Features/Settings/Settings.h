//
//  Settings.h
//  TX-EYE
//
//  Created by CoreCat on 16/7/23.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (void)resetSettings;

+ (void)saveParameterForAutosave:(BOOL)b;
+ (void)saveParameterForRightHandMode:(BOOL)b;
+ (void)saveParameterForTrimRUDD:(NSInteger)trimValue;
+ (void)saveParameterForTrimELE:(NSInteger)trimValue;
+ (void)saveParameterForTrimAIL:(NSInteger)trimValue;
+ (void)saveParameterForAltitudeHold:(BOOL)b;
+ (void)saveParameterForSpeedLimit:(NSInteger)speedLimitValue;

+ (BOOL)getParameterForAutosave;
+ (BOOL)getParameterForRightHandMode;
+ (NSInteger)getParameterForTrimRUDD;
+ (NSInteger)getParameterForTrimELE;
+ (NSInteger)getParameterForTrimAIL;
+ (BOOL)getParameterForAltitudeHold;
+ (NSInteger)getParameterForSpeedLimit;

// ================================================================

+ (void)regiserdDebugDefaults;

// ================================================================

+ (void)setDebugString:(NSString *)debugString;

// ================================================================

+ (BOOL)getDebugOn;
+ (BOOL)isHudOn;
+ (BOOL)isDebugOverTCP;
+ (NSInteger)getDebugTcpTimeout;
+ (NSInteger)getDebugPort;
+ (BOOL)getDebugSendTimeSwitch;
+ (NSInteger)getDebugSendTime;
+ (BOOL)getDebugSendPeriodSwitch;
+ (NSInteger)getDebugSendPeriod;
+ (NSString *)getDebugString;

@end
