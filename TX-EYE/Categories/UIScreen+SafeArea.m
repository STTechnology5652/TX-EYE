//
//  UIScreen+SafeArea.m
//  TX-EYE
//
//  Created by CoreCat on 2018/3/15.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "UIScreen+SafeArea.h"

@implementation UIScreen (SafeArea)

- (CGFloat)topOfSafeArea
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    if (@available(iOS 11.0, *)) {
        return rootView.safeAreaInsets.top;
    } else {
        return 0;
    }
}

- (CGFloat)leftOfSafeArea
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    if (@available(iOS 11.0, *)) {
        return rootView.safeAreaInsets.left;
    } else {
        return 0;
    }
}

- (CGFloat)bottomOfSafeArea
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    if (@available(iOS 11.0, *)) {
        return rootView.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}

- (CGFloat)rightOfSafeArea
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    if (@available(iOS 11.0, *)) {
        return rootView.safeAreaInsets.right;
    } else {
        return 0;
    }
}

- (CGFloat)widthOfSafeArea
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    if (@available(iOS 11.0, *)) {
        CGFloat leftInset = rootView.safeAreaInsets.left;
        CGFloat rightInset = rootView.safeAreaInsets.right;
        
        return rootView.bounds.size.width - leftInset - rightInset;
    } else {
        return rootView.bounds.size.width;
    }
}

- (CGFloat)heightOfSafeArea
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    if (@available(iOS 11.0, *)) {
        CGFloat topInset = rootView.safeAreaInsets.top;
        CGFloat bottomInset = rootView.safeAreaInsets.bottom;
        
        return rootView.bounds.size.height - topInset - bottomInset;
    } else {
        return rootView.bounds.size.height;
    }
}

@end
