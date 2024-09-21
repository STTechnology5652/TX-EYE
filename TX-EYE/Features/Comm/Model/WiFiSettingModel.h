//
//  WiFiSettingModel.h
//  GoTrack
//
//  Created by CoreCat on 2019/1/3.
//  Copyright © 2019年 CoreCat. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface WiFiSettingModel : JSONModel

@property (nonatomic) NSString *wifiSSID;
@property (nonatomic) NSString *wifiPassword;

@end

NS_ASSUME_NONNULL_END
