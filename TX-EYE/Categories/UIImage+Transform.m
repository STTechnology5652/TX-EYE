//
//  UIImage+Transform.m
//  DriverBuddy
//
//  Created by CoreCat on 15/12/30.
//  Copyright © 2015年 CoreCat. All rights reserved.
//

#import "UIImage+Transform.h"

@implementation UIImage (Transform)

- (UIImage *)resizeToScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize));
    [self drawInRect:CGRectMake(0, 0, self.size.width * scaleSize, self.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)resizeToSize:(CGSize)resize
{
    UIGraphicsBeginImageContext(CGSizeMake(resize.width, resize.height));
    [self drawInRect:CGRectMake(0, 0, resize.width, resize.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizeImage;
}

- (UIImage *)captureView:(UIView *)theView
{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
