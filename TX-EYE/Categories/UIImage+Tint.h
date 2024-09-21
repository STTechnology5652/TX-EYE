//
//  UIImage+Tint.h
//  Power LED Light
//
//  Created by CoreCat on 15/9/30.
//  Copyright (c) 2015年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *) grayImage;

@end
