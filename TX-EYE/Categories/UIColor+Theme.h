//
//  UIColor+Theme.h
//  GoTrack
//
//  Created by CoreCat on 2018/5/22.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Theme)

+ (UIColor *)themeColor;
+ (UIColor *)themeBackgroundColor;

+ (UIColor *)navigationBarTintColor;
+ (UIColor *)navigationBarTitleColor;

+ (UIColor *)mainTextColor;
+ (UIColor *)detailedTextColor;
+ (UIColor *)subtitleTextColor;

@end
