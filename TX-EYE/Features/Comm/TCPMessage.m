//
//  TCPMessage.m
//  GoTrack
//
//  Created by CoreCat on 2018/12/17.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "TCPMessage.h"
#import "Config.h"

@interface TCPMessage ()

@property (nonatomic, assign, readwrite) uint8_t messageId;
@property (nonatomic, strong, readwrite) NSData *content;

@end

@implementation TCPMessage

- (NSData *)sendableData
{
    uint8_t contentHeader[TCP_CONTENT_HEADER_SIZE];
    contentHeader[0] = _messageId;
    contentHeader[1] = _sessionId;
    contentHeader[2] = 0; // reserved
    contentHeader[3] = 0; // reserved
    
    NSMutableData *msgData = [[NSMutableData alloc] initWithBytes:contentHeader length:TCP_CONTENT_HEADER_SIZE];
    if (_content) {
        [msgData appendData:_content];
    }
    
    return msgData;
}

+ (TCPMessage *)messageWithId:(uint8_t)mid data:(NSData * _Nullable)data
{
    TCPMessage *message = [[TCPMessage alloc] init];
    
    message.messageId = mid;
    message.content = data;
    
    return message;
}

+ (TCPMessage *)messageWithId:(uint8_t)mid value:(uint8_t)value
{
    uint8_t valueBytes[1];
    valueBytes[0] = value;
    NSData *valueData = [NSData dataWithBytes:valueBytes length:1];
    
    return [self messageWithId:mid data:valueData];
}

+ (TCPMessage *)aliveMessage
{
    return [self messageWithId:MSG_ID_HEARTBEAT data:nil];
}

@end
