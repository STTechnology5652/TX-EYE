//
//  CommClient.m
//  TX-EYE
//
//  Created by CoreCat on 2021/11/28.
//  Copyright © 2021 CoreCat. All rights reserved.
//

#import "CommClient.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

@interface CommClient () <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpSocket;
}

@property (nonatomic, assign) NSTimeInterval timeout;

@end

@implementation CommClient

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout useTcp:(BOOL)useTcp
{
    self.timeout = timeout;
    
    NSError *error;
    if (useTcp) {
        tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("TCP connection", 0)];
        [tcpSocket connectToHost:host onPort:port withTimeout:timeout error:&error];
    } else {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("UDP connection", 0)];
        [udpSocket connectToHost:host onPort:port error:&error];
    }
    NSLog(@"connectToHost error = %@", error);
}

- (void)disconnect
{
    if (udpSocket) {
        [udpSocket close];
        udpSocket = nil;
    }
    
    if (tcpSocket) {
        [tcpSocket disconnect];
        tcpSocket = nil;
    }
}

- (void)sendData:(NSData *)data
{
    if (udpSocket) {
        [udpSocket sendData:data withTimeout:self.timeout tag:1];
    }
    
    if (tcpSocket && tcpSocket.isConnected) {
        [tcpSocket writeData:data withTimeout:self.timeout tag:1];
    }
}

#pragma mark - UDP

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSError *error;
    [sock beginReceiving:&error];
    NSLog(@"beginReceiving error = %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
                                             fromAddress:(NSData *)address
                                       withFilterContext:(nullable id)filterContext
{
//    NSLog(@"------ didReceiveData: %@", data);
    
    if ([_delegate respondsToSelector:@selector(client:onReceiveData:)]) {
        [_delegate client:self onReceiveData:data];
    }
}

#pragma mark - TCP

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [sock readDataWithTimeout:self.timeout tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"------ didReadData: %@", data);
    
    if ([_delegate respondsToSelector:@selector(client:onReceiveData:)]) {
        [_delegate client:self onReceiveData:data];
    }
    
    [sock readDataWithTimeout:self.timeout tag:0];
}

@end
