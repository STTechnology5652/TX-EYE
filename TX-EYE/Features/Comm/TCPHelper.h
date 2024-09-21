//
//  TCPHelper.h
//  GoTrack
//
//  Created by CoreCat on 2018/12/17.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCPHelper : NSObject

+ (NSData *)headerWithLength:(NSUInteger)length;

+ (NSUInteger)lengthWithHeader:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
