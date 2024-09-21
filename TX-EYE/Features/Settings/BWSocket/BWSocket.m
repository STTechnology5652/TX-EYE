//
//  BWSocket.m
//  TX-EYE
//
//  Created by CoreCat on 2016/10/12.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "BWSocket.h"
#import "Config.h"

@import CocoaAsyncSocket;

// Key status
NSString *kKeyProtocol          = @"protocol";
NSString *kKeyProtocolVersion   = @"protocolVersion";
NSString *kKeyStatusCode        = @"statusCode";
NSString *kKeyStatus            = @"status";
// Status Code
NSString *kStatusCodeOK         = @"200";
// Key info
NSString *kKeyMethod            = @"METHOD";
NSString *kKeySSID              = @"SSID";
NSString *kKeyChip              = @"CHIP";
NSString *kKeyVendor            = @"VENDOR";
NSString *kKeyVersion           = @"VERSION";
// Method
NSString *kCommandUndefined     = @"Undefined";
NSString *kCommandGetInfo       = @"GETINFO";
NSString *kCommandSetSSID       = @"SETSSID";
NSString *kCommandSetPassword   = @"SETPW";         ///////////// TODO: modify it
NSString *kCommandResetNet      = @"RESETNET";

NSString *kCommandRecordStart   = @"RECSTART";
NSString *kCommandRecordStop    = @"RECSTOP";
// Others...
NSString *kCommandPath              = @"/webcam";
NSString *kCommandProtocol          = @"APPO";
NSString *kCommandProtocolVersion   = @"1.0";

@interface BWSocket () <GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@end

@implementation BWSocket

+ (instancetype)sharedSocket
{
    static BWSocket *socket;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[self alloc] init];
    });
    return socket;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                  delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _action = SocketActionIdle;
    }
    return self;
}

/*
 * 连接到主机
 */

- (BOOL)connectToHostwithError:(NSError **)errPtr
{
    _action = SocketActionConnecting;
    return [self connectToHost:SOCKET_HOST onPort:SOCKET_PORT withTimeout:SOCKET_TIMEOUT error:errPtr];
}

- (BOOL)connectToHost:(NSString *)host
               onPort:(uint16_t)port
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr
{
    return [_asyncSocket connectToHost:host
                                onPort:port
                           withTimeout:timeout
                                 error:errPtr];
}

/*
 * 断开连接
 */
- (void)disconnect
{
    _action = SocketActionDisconnecting;
    [_asyncSocket disconnect];
}

/*
 * 连接状态
 */
- (BOOL)isConnected
{
    return [_asyncSocket isConnected];
}

/*
 * 断开状态
 */
- (BOOL)isDisconnected
{
    return [_asyncSocket isDisconnected];
}

/*
 * 发送字符串
 */
- (void)sendString:(NSString *)string withTag:(long)tag
{
    [self sendData:[string dataUsingEncoding:NSUTF8StringEncoding] withTag:tag];
}

/*
 * 发送数据
 */
- (void)sendData:(NSData *)data withTag:(long)tag
{
    [_asyncSocket writeData:data withTimeout:SOCKET_TIMEOUT tag:tag];
}

/*
 * 获取基本命令（不包含参数的命令）
 */
- (NSString *)baseCommandWithAction:(SocketAction)action
{
    NSString *strCommand;
    NSString *strPath = kCommandPath;
    NSString *strProtocol = [NSString stringWithFormat:@"%@/%@", kCommandProtocol, kCommandProtocolVersion];
    
    switch (action) {
        case SocketActionGetInfo:
            strCommand = kCommandGetInfo;
            break;
        case SocketActionSetSSID:
            strCommand = kCommandSetSSID;
            break;
        case SocketActionSetPassword:
            strCommand = kCommandSetPassword;
            break;
        case SocketActionResetBoard:
            strCommand = kCommandResetNet;
            break;
        case SocketActionStartRecord:
            strCommand = kCommandRecordStart;
            break;
        case SocketActionStopRecord:
            strCommand = kCommandRecordStop;
            break;
            
        default:
            strCommand = kCommandUndefined;
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", strCommand, strPath, strProtocol];
}

/*
 * 字符串后添加终止符
 */
- (NSString *)appendingTerminalSign:(NSString *)string
{
    return [NSString stringWithFormat:@"%@\r\n\r\n", string];
}

//- (void)getInfoSucceedBlock:(succeedBlock)succeedBlock
//                failedBlock:(failedBlock)failedBlock
//{
//    
//}

/*
 * 获取设备信息
 */
- (void)getInfo
{
    NSLog(@"Get Info");
    
    _action = SocketActionGetInfo;
    NSString *wrString = [self baseCommandWithAction:_action];
    wrString = [self appendingTerminalSign:wrString];
    [self sendString:wrString withTag:_action];
}

/*
 * 设置SSID
 */
- (void)setSSID:(NSString *)ssid
{
    NSLog(@"Set SSID");
    
    _action = SocketActionSetSSID;
    NSString *wrString = [self baseCommandWithAction:_action];
    wrString = [wrString stringByAppendingFormat:@"%@\r\nssid:%@", wrString, ssid];
    wrString = [self appendingTerminalSign:wrString];
    NSLog(@"[%@]", wrString);
    [self sendString:wrString withTag:_action];
}

/*
 * 设置密码
 */
- (void)setPassword:(NSString *)password
{
    NSLog(@"Set password");
    
//    _action = SocketActionSetPassword;
//    NSString *wrString = [self baseCommandWithAction:_action];
//    wrString = [self appendingTerminalSign:wrString];
//    [self sendString:wrString withTag:_action];
}

/*
 * 重置设备
 */
- (void)resetBoard
{
    NSLog(@"Reset board");
    
    _action = SocketActionResetBoard;
    NSString *wrString = [self baseCommandWithAction:_action];
    wrString = [self appendingTerminalSign:wrString];
    [self sendString:wrString withTag:_action];
}

- (void)startRecord
{
    _action = SocketActionStartRecord;
    NSString *wrString = [self baseCommandWithAction:_action];
    wrString = [self appendingTerminalSign:wrString];
    [self sendString:wrString withTag:_action];
}

- (void)stopRecord
{
    _action = SocketActionStopRecord;
    NSString *wrString = [self baseCommandWithAction:_action];
    wrString = [self appendingTerminalSign:wrString];
    [self sendString:wrString withTag:_action];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"didConnectToHost: %@(%d)", host, port);
    
    if ([(id)_delegate respondsToSelector:@selector(socketDidConnect:)]) {
        [_delegate socketDidConnect:self];
    }
    
    _action = SocketActionIdle;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect: %@", err);
    
    if ([(id)_delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]) {
        [_delegate socketDidDisconnect:self withError:err];
    }
    
    _action = SocketActionIdle;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag: %ld", tag);
    
    switch (tag) {
        case SocketActionGetInfo:
        case SocketActionSetSSID:
        case SocketActionSetPassword:
        case SocketActionResetBoard:
        case SocketActionStartRecord:
        case SocketActionStopRecord:
            [sock readDataWithTimeout:SOCKET_TIMEOUT tag:tag];
            break;
            
        default:
            [sock disconnect];
            break;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"didReadData(%ld):\n%@", tag, responseString);
    
    SocketAction action = tag;
    NSDictionary *dict = [self parseResponseString:responseString];
    
//    NSLog(@"Response: %@", dict);
    
    if ([(id)_delegate respondsToSelector:@selector(socket:didGetInformation:withAction:)]) {
        [_delegate socket:self didGetInformation:dict withAction:action];
    }
    
    _action = SocketActionIdle;
}

#pragma mark - Parse Response

- (NSDictionary *)parseResponseString:(NSString *)responseString
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    NSArray *stringArray = [responseString componentsSeparatedByString:@"\r\n"];
    
    if (stringArray.count >= 1) {
        NSString *statusString = [stringArray objectAtIndex:0];
        
        // Parse status
        NSArray *statusArray = [statusString componentsSeparatedByString:@" "];
        if (statusArray.count >= 3) {
            NSString *protocolVersionString = [statusArray objectAtIndex:0];
            NSString *statusCodeString = [statusArray objectAtIndex:1];
            
            // Parse protocol version
            NSArray *protocolVersionArray = [protocolVersionString componentsSeparatedByString:@"/"];
            if (protocolVersionArray.count == 2) {
                [mutableDict addEntriesFromDictionary:@{@"protocol":protocolVersionArray[0]}];
                [mutableDict addEntriesFromDictionary:@{@"protocolVersion":protocolVersionArray[1]}];
            }
            
            [mutableDict addEntriesFromDictionary:@{@"statusCode":statusCodeString}];
            
            NSString *statusString = @"";
            NSUInteger count = statusArray.count;
            for (NSUInteger i = 2; i < count; i++) {
                NSString *format;
                if (i == count - 1)
                    format = @"%@";
                else
                    format = @"%@ ";
                statusString = [statusString stringByAppendingFormat:format, [statusArray objectAtIndex:i]];
            }
            [mutableDict addEntriesFromDictionary:@{@"status":statusString}];
        }
    }
    
    if (stringArray.count >= 2) {
        NSString *methodString = [stringArray objectAtIndex:1];
        
        // Parse method
        methodString = [methodString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *methodArray = [methodString componentsSeparatedByString:@":"];
        if (methodArray.count == 2) {
            [mutableDict addEntriesFromDictionary:@{methodArray[0]:methodArray[1]}];
        }
    }
    
    for (NSUInteger i = 2; i < stringArray.count; i++) {
        NSString *infoString = [stringArray objectAtIndex:i];
        
        // Parse info
        infoString = [infoString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *infoArray = [infoString componentsSeparatedByString:@":"];
        if (infoArray.count == 2) {
            [mutableDict addEntriesFromDictionary:@{infoArray[0]:infoArray[1]}];
        }
    }
    
    return mutableDict;
}

@end
