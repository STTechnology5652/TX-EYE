//
//  TCPHelper.m
//  GoTrack
//
//  Created by CoreCat on 2018/12/17.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "TCPHelper.h"
#import "Config.h"

@implementation TCPHelper

+ (NSData *)headerWithLength:(NSUInteger)length
{
    unsigned char header[TCP_HEADER_SIZE];
    *(unsigned char*)(header + 0) = (unsigned char)((length >> 24) & 0xff);
    *(unsigned char*)(header + 1) = (unsigned char)((length >> 16) & 0xff);
    *(unsigned char*)(header + 2) = (unsigned char)((length >> 8) & 0xff);
    *(unsigned char*)(header + 3) = (unsigned char)((length >> 0) & 0xff);
    NSData *data = [NSData dataWithBytes:header length:TCP_HEADER_SIZE];
    return data;
}

+ (NSUInteger)lengthWithHeader:(NSData *)data
{
    unsigned char header[TCP_HEADER_SIZE];
    [data getBytes:header length:TCP_HEADER_SIZE];
    NSUInteger length =
        ((unsigned int)(*(header + 0)) << 24) |
        ((unsigned int)(*(header + 1)) << 16) |
        ((unsigned int)(*(header + 2)) << 8) |
        ((unsigned int)(*(header + 3)) << 0);
    return length;
}

@end
