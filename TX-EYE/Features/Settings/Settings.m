//
//  Settings.m
//  TX-EYE
//
//  Created by CoreCat on 16/7/23.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "Settings.h"

static NSString *SETTINGS_PARAMETERS_AUTOSAVE   = @"ParametersAutosave";    // Default is YES
static NSString *SETTINGS_RIGHTHAND_MODE        = @"RighthandMode";         // Default is NO
static NSString *SETTINGS_TRIM_RUDD             = @"TrimRUDD";              // Default is 0
static NSString *SETTINGS_TRIM_ELE              = @"TrimELE";               // Default is 0
static NSString *SETTINGS_TRIM_AIL              = @"TrimAIL";               // Default is 0
static NSString *SETTINGS_ALTITUDE_HOLD         = @"AltitudeHold";          // Default is NO
static NSString *SETTINGS_SPEEDLIMIT            = @"SpeedLimit";            // Default is 0

@implementation Settings

#pragma mark - Reset settings

+ (void)resetSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
//    [defaults setBool:YES forKey:SETTINGS_PARAMETERS_AUTOSAVE];
//    [defaults setBool:NO forKey:SETTINGS_RIGHTHAND_MODE];
    
    [defaults setInteger:0 forKey:SETTINGS_TRIM_RUDD];
    [defaults setInteger:0 forKey:SETTINGS_TRIM_ELE];
    [defaults setInteger:0 forKey:SETTINGS_TRIM_AIL];
    
    [defaults setBool:NO forKey:SETTINGS_ALTITUDE_HOLD];
    
    [defaults setInteger:0 forKey:SETTINGS_SPEEDLIMIT];
    
//    [defaults synchronize];   // No need to do this
}

#pragma mark - Set value

+ (void)setBool:(BOOL)b forKey:(NSString *)k
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:b forKey:k];
//    [defaults synchronize];   // No need to do this
}

+ (void)setInteger:(NSInteger)i forKey:(NSString *)k
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:i forKey:k];
//    [defaults synchronize];   // No need to do this
}

#pragma mark -

+ (void)saveParameterForAutosave:(BOOL)b
{
    [self setBool:b forKey:SETTINGS_PARAMETERS_AUTOSAVE];
}

+ (void)saveParameterForRightHandMode:(BOOL)b
{
    [self setBool:b forKey:SETTINGS_RIGHTHAND_MODE];
}

+ (void)saveParameterForTrimRUDD:(NSInteger)trimValue
{
    [self setInteger:trimValue forKey:SETTINGS_TRIM_RUDD];
}

+ (void)saveParameterForTrimELE:(NSInteger)trimValue
{
    [self setInteger:trimValue forKey:SETTINGS_TRIM_ELE];
}

+ (void)saveParameterForTrimAIL:(NSInteger)trimValue
{
    [self setInteger:trimValue forKey:SETTINGS_TRIM_AIL];
}

+ (void)saveParameterForAltitudeHold:(BOOL)b
{
    [self setBool:b forKey:SETTINGS_ALTITUDE_HOLD];
}

+ (void)saveParameterForSpeedLimit:(NSInteger)speedLimitValue
{
    [self setInteger:speedLimitValue forKey:SETTINGS_SPEEDLIMIT];
}

#pragma mark - Get value

+ (BOOL)getBoolforKey:(NSString *)k
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:k];
}

+ (NSInteger)getIntegerForKey:(NSString *)k
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:k];
}

#pragma mark -

+ (BOOL)getParameterForAutosave
{
//    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PARAMETERS_AUTOSAVE];
//    if (obj != nil) {
//        return [self getBoolforKey:SETTINGS_PARAMETERS_AUTOSAVE];
//    }
////    return YES;     // Default is YES
//    return NO;     // Default is NO
    
    return [self getBoolforKey:@"pref.key_auto_save_parameters"];
}

+ (BOOL)getParameterForRightHandMode
{
//    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_RIGHTHAND_MODE];
//    if (obj != nil) {
//        return [self getBoolforKey:SETTINGS_RIGHTHAND_MODE];
//    }
//    return NO;      // Default is NO
    
    return [self getBoolforKey:@"pref.key_right_hand_mode"];
}

+ (NSInteger)getParameterForTrimRUDD
{
    return [self getIntegerForKey:SETTINGS_TRIM_RUDD];
}

+ (NSInteger)getParameterForTrimELE
{
    return [self getIntegerForKey:SETTINGS_TRIM_ELE];
}

+ (NSInteger)getParameterForTrimAIL
{
    return [self getIntegerForKey:SETTINGS_TRIM_AIL];
}

+ (BOOL)getParameterForAltitudeHold
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_ALTITUDE_HOLD];
    if (obj != nil) {
        return [self getBoolforKey:SETTINGS_ALTITUDE_HOLD];
    }
    return NO;      // Default is NO
}

+ (NSInteger)getParameterForSpeedLimit
{
    return [self getIntegerForKey:SETTINGS_SPEEDLIMIT];
}

// ================================================================

+ (void)regiserdDebugDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"pref.key_debug_on" : @(YES),
                                                               @"pref.key_show_hud" : @(YES),
                                                               @"pref.key_net_protocol" : @(NO),
                                                               @"pref.key_tcp_timeout" : @(10000),
                                                               @"pref.key_net_port" : @(8082),
                                                               @"pref.key_send_time_switch" : @(NO),
                                                               @"pref.key_send_time" : @(0),
                                                               @"pref.key_send_period_switch" : @(NO),
                                                               @"pref.key_send_period" : @(1000),
                                                               @"pref.key_debug_string" : @"GO GO GO",
                                                            }];
}

// ================================================================

+ (void)setDebugString:(NSString *)debugString
{
    [[NSUserDefaults standardUserDefaults] setObject:debugString forKey:@"pref.key_debug_string"];
}

// ================================================================

+ (BOOL)getDebugOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pref.key_debug_on"];
}

+ (BOOL)isHudOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pref.key_show_hud"];
}

+ (BOOL)isDebugOverTCP
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pref.key_net_protocol"];
}

+ (NSInteger)getDebugTcpTimeout
{
    NSInteger timeout = [[NSUserDefaults standardUserDefaults] integerForKey:@"pref.key_tcp_timeout"];
    return timeout != 0 ? timeout : 10000;
}

+ (NSInteger)getDebugPort
{
    NSInteger port = [[NSUserDefaults standardUserDefaults] integerForKey:@"pref.key_net_port"];
    return port != 0 ? port : 8082;
}

+ (BOOL)getDebugSendTimeSwitch
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pref.key_send_time_switch"];
}

+ (NSInteger)getDebugSendTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"pref.key_send_time"];
}

+ (BOOL)getDebugSendPeriodSwitch
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pref.key_send_period_switch"];
}

+ (NSInteger)getDebugSendPeriod
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"pref.key_send_period"];
}

+ (NSString *)getDebugString
{
    NSString *debugString = [[NSUserDefaults standardUserDefaults] stringForKey:@"pref.key_debug_string"];
    if (debugString == nil || [debugString isEqualToString:@""]) {
        return @"GO GO GO";
    }
    return debugString;
}

@end
