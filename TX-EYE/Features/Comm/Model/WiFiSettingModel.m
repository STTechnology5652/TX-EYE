//
//  WiFiSettingModel.m
//  GoTrack
//
//  Created by CoreCat on 2019/1/3.
//  Copyright © 2019年 CoreCat. All rights reserved.
//

#import "WiFiSettingModel.h"

@implementation WiFiSettingModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"wifiSSID": @"WIFISSID",
                                                                  @"wifiPassword": @"WIFIPW"
                                                                  }];
}

@end
