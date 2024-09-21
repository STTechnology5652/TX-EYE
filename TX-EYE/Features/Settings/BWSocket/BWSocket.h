//
//  BWSocket.h
//  TX-EYE
//
//  Created by CoreCat on 2016/10/12.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Key status
extern NSString *kKeyProtocol;
extern NSString *kKeyProtocolVersion;
extern NSString *kKeyStatusCode;
extern NSString *kKeyStatus;
// Status Code
extern NSString *kStatusCodeOK;
// Key info
extern NSString *kKeyMethod;
extern NSString *kKeySSID;
extern NSString *kKeyChip;
extern NSString *kKeyVendor;
extern NSString *kKeyVersion;
// Method
extern NSString *kCommandUndefined;
extern NSString *kCommandGetInfo;
extern NSString *kCommandSetSSID;
extern NSString *kCommandSetPassword;
extern NSString *kCommandResetNet;
extern NSString *kCommandRecordStart;
extern NSString *kCommandRecordStop;

typedef NS_OPTIONS(NSInteger, SocketAction) {
    SocketActionIdle,
    SocketActionConnecting,
    SocketActionDisconnecting,
    SocketActionGetInfo,
    SocketActionSetSSID,
    SocketActionSetPassword,
    SocketActionResetBoard,
    SocketActionStartRecord,
    SocketActionStopRecord,
};

@protocol BWSocketDelegate;

//typedef void (^succeedBlock)(NSDictionary *info, SocketAction action);
//typedef void (^failedBlock)(NSError *error);

@interface BWSocket : NSObject
+ (instancetype)sharedSocket;

@property (atomic, weak, readwrite, nullable) id<BWSocketDelegate> delegate;

@property (atomic, readonly) BOOL isDisconnected;
@property (atomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) SocketAction action;

- (BOOL)connectToHostwithError:(NSError **)errPtr;
- (void)disconnect;

- (void)getInfo;
- (void)setSSID:(NSString *)ssid;
//- (void)setPassword:(NSString *)password;
- (void)resetBoard;

- (void)startRecord;
- (void)stopRecord;

@end

@protocol BWSocketDelegate
@optional

- (void)socketDidConnect:(BWSocket *)sock;
- (void)socketDidDisconnect:(BWSocket *)sock withError:(NSError *)err;
- (void)socket:(BWSocket *)sock didGetInformation:(NSDictionary *)info withAction:(SocketAction)action;

@end

NS_ASSUME_NONNULL_END
