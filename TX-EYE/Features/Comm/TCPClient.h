//
//  TCPClient.h
//  GoTrack
//
//  Created by CoreCat on 2018/12/17.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCPClientDelegate <NSObject>
@optional

- (void)didConnectSuccess;

- (void)didDisconnect;

- (void)didReadData:(NSData *)data;

- (void)didWriteData;

@end

@interface TCPClient : NSObject

@property (nonatomic, readonly) BOOL isConnected;

@property (nonatomic, strong) id<TCPClientDelegate> delegate;

- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port;
- (instancetype)init;

- (void)connect;
- (void)disconnect;

- (void)sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
