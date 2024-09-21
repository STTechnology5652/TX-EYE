//
//  BWSDKFoundation.h
//
//  Created by CoreCat on 2017/6/27.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#ifndef BWSDKFoundation_h
#define BWSDKFoundation_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define BW_API_EXTERN       extern "C" __attribute__((visibility("default")))
#else
#define BW_API_EXTERN       extern __attribute__((visibility("default")))
#endif

#define BW_API_DEPRECATED(_msg_) __attribute__((deprecated(_msg_)))

typedef void(^_Nullable BWCompletionBlock)(NSError *_Nullable error);

typedef void(^_Nullable BWBooleanCompletionBlock)(BOOL boolean, NSError *_Nullable error);

typedef void(^_Nullable BWFloatCompletionBlock)(float floatValue, NSError *_Nullable error);

typedef void(^_Nullable BWArrayCompletionBlock)(NSArray * _Nullable array, NSError *_Nullable error);

#endif /* BWSDKFoundation_h */
