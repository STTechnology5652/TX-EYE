//
//  TCPClient.m
//  GoTrack
//
//  Created by CoreCat on 2018/12/17.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "TCPClient.h"
#import "TCPHelper.h"

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "Config.h"

@interface TCPClient () <GCDAsyncSocketDelegate>
{
    BOOL _manuallyDisconnect;
}

@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation TCPClient

- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port
{
    _host = host;
    _port = port;
    
    self = [super init];
    if (self) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithHost:TCP_SERVER_HOST port:TCP_SERVER_PORT];
}

- (BOOL)isConnected
{
    return self.socket.isConnected;
}

#pragma mark - Actions

- (void)connect
{
    NSError *error = nil;
    if (![self.socket connectToHost:_host onPort:_port error:&error]) {
        NSLog(@"Error: %@", error);
    }
}

- (void)disconnect
{
    _manuallyDisconnect = YES;
    [self.socket disconnect];
}

- (void)sendData:(NSData *)data
{
    NSMutableData *sendData = [[NSMutableData alloc] init];
    [sendData appendData:[TCPHelper headerWithLength:[data length]]];
    [sendData appendData:data];
    [self.socket writeData:sendData withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    _manuallyDisconnect = NO;
    
    if ([self.delegate respondsToSelector:@selector(didConnectSuccess)]) {
        [self.delegate didConnectSuccess];
    }
    // 前两字节表示BODY长度，大端
    [self.socket readDataToLength:TCP_HEADER_SIZE withTimeout:-1 tag:TCP_TAG_HEADER];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    /* !!! 注意：connect连接不上也会调用，不只是连接后断开才会调用 !!! */
    
    // 通知已断开
    if ([self.delegate respondsToSelector:@selector(didDisconnect)]) {
        [self.delegate didDisconnect];
    }
    
    if (_manuallyDisconnect) {
        // 手动断开
    } else {
        // 异常断开，重连
        __weak typeof (self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TCP_RECONNECTION_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf connect];
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == TCP_TAG_HEADER) {
        NSUInteger length = [TCPHelper lengthWithHeader:data];
        [self.socket readDataToLength:length withTimeout:-1 tag:TCP_TAG_BODY];
    } else if (tag == TCP_TAG_BODY) {
        if ([self.delegate respondsToSelector:@selector(didReadData:)]) {
            [self.delegate didReadData:data];
        }
        
        [self.socket readDataToLength:TCP_HEADER_SIZE withTimeout:-1 tag:TCP_TAG_HEADER];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if ([self.delegate respondsToSelector:@selector(didWriteData)]) {
        [self.delegate didWriteData];
    }
}

@end
