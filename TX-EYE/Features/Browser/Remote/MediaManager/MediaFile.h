//
//  MediaFile.h
//  FTPtest
//
//  Created by CoreCat on 2017/7/8.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaFile : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) unsigned long long size;

@property (nonatomic, assign) BOOL isVideo;

@end
