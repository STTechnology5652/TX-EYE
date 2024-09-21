//
//  UIColor+Theme.m
//  GoTrack
//
//  Created by CoreCat on 2018/5/22.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "UIColor+Theme.h"

#define RGB_COLOR(r, g, b)      [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:1.0]
#define RGBA_COLOR(r, g, b, a)  [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a/100.]

@implementation UIColor (Theme)

+ (UIColor *)themeColor
{
    return RGB_COLOR(0xEE, 0x50, 0x46);
}

+ (UIColor *)themeBackgroundColor
{
    return RGB_COLOR(0xFA, 0xFA, 0xFA);
}

+ (UIColor *)navigationBarTintColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)navigationBarTitleColor
{
    return RGB_COLOR(0x11, 0x10, 0x10);
}

+ (UIColor *)mainTextColor
{
    return RGB_COLOR(0x11, 0x10, 0x10);
}

+ (UIColor *)detailedTextColor
{
    return RGB_COLOR(0xAA, 0xB0, 0xB2);
}

+ (UIColor *)subtitleTextColor
{
    return RGB_COLOR(0x9C, 0x9C, 0x9C);
}

@end
