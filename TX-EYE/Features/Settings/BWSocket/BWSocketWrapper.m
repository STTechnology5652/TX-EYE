//
//  BWSocketWrapper.m
//  TX-EYE
//
//  Created by CoreCat on 2017/7/14.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "BWSocketWrapper.h"
#import "BWSocket.h"
#import "NSError+BWSDK.h"

#define REQUEST_START_RECORD    1
#define REQUEST_STOP_RECORD     2

@interface BWSocketWrapper () <BWSocketDelegate>

@property (nonatomic, strong) BWSocket *bwSocket;
@property (nonatomic, assign) BOOL connected;

@property (nonatomic, assign) int requestCode;
@property (nonatomic, assign) BOOL requestOK;

@property (nonatomic, strong) BWCompletionBlock completion;

@end

@implementation BWSocketWrapper

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    __strong static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BWSocketWrapper alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bwSocket = [BWSocket sharedSocket];
        self.bwSocket.delegate = self;
    }
    return self;
}

#pragma mark - Methods

- (void)startRecordWithCompletion:(BWCompletionBlock)completion
{
    [self doRequest:REQUEST_START_RECORD withCompletion:completion];
}

- (void)stopRecordWithCompletion:(BWCompletionBlock)completion
{
    [self doRequest:REQUEST_STOP_RECORD withCompletion:completion];
}

- (void)doRequest:(int)requestCode withCompletion:(BWCompletionBlock)completion
{
    NSLog(@"doRequest: %d", requestCode);
    
    self.completion = completion;
    self.requestCode = requestCode;
    
    [self.bwSocket connectToHostwithError:nil];
}

#pragma mark - BWSocketDelegate

- (void)socketDidConnect:(BWSocket *)sock
{
    self.connected = YES;
    
    // 执行相应的操作
    switch (self.requestCode) {
        case REQUEST_START_RECORD:
            NSLog(@"socketDidConnect: Do remote start record");
            [self.bwSocket startRecord];
            break;
        case REQUEST_STOP_RECORD:
            NSLog(@"socketDidConnect: Do remote stop record");
            [self.bwSocket stopRecord];
            break;
            
        default:
            // 断开连接
            NSLog(@"socketDidConnect: No request, disconnect");
            [self.bwSocket disconnect];
            break;
    }
}

- (void)socketDidDisconnect:(BWSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect: %d, %d", self.connected, self.requestOK);
    
    if (self.connected) {
        // 网络已经连接，判断动作有没有执行成功
        if (self.requestOK) {
            // 动作执行成功
            if (self.completion)
                self.completion(nil);
        } else {
            // 动作执行失败
            if (self.completion)
                self.completion([NSError BWSDKBWSocketErrorForCode:BWSDKBWSoekctErrorInformationFetchFailed]);
        }
    } else {
        // 如果没有成功Connected就进入到这里，说明网络没有连接上
        if (self.completion)
            self.completion([NSError BWSDKBWSocketErrorForCode:BWSDKBWSoekctErrorConnectionFailed]);
    }
    
    // 重置状态
    self.connected = NO;
    self.requestOK = NO;
    self.completion = nil;
}

- (void)socket:(BWSocket *)sock didGetInformation:(NSDictionary *)info withAction:(SocketAction)action
{
    NSLog(@"didGetInformation: %@", info);
    
    NSString *statusCode = info[kKeyStatusCode];
    NSString *method = info[kKeyMethod];
    NSString *desiredMethod = nil;
    
    // 如果状态码存在，且等于200
    if ([statusCode isEqualToString:kStatusCodeOK]) {
        
        switch (self.requestCode) {
            case REQUEST_START_RECORD:
                desiredMethod = kCommandRecordStart;
                break;
            case REQUEST_STOP_RECORD:
                desiredMethod = kCommandRecordStop;
                break;
                
            default:
                break;
        }
        
        // 如果返回符合预期
        if ([method isEqualToString:desiredMethod])
            self.requestOK = YES;
    }
    
    // 断开连接
    [self.bwSocket disconnect];
}

@end
