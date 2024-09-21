//
//  CommClient.h
//  TX-EYE
//
//  Created by CoreCat on 2021/11/28.
//  Copyright © 2021 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CommClient;

@protocol CommDelegate <NSObject>

- (void)client:(CommClient *)client onReceiveData:(NSData *)data;

@end

@interface CommClient : NSObject

@property (nonatomic, weak) id <CommDelegate>delegate;

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout useTcp:(BOOL)useTcp;
- (void)disconnect;
- (void)sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
