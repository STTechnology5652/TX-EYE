//
//  BWSocketWrapper.h
//  TX-EYE
//
//  Created by CoreCat on 2017/7/14.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWSDKFoundation.h"

@interface BWSocketWrapper : NSObject

+ (instancetype)sharedInstance;

- (void)startRecordWithCompletion:(BWCompletionBlock)completion;
- (void)stopRecordWithCompletion:(BWCompletionBlock)completion;

@end
