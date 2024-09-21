//
//  UIImage+Transform.h
//  DriverBuddy
//
//  Created by CoreCat on 15/12/30.
//  Copyright © 2015年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Transform)

- (UIImage *)resizeToScale:(float)scaleSize;

- (UIImage *)resizeToSize:(CGSize)resize;

- (UIImage *)captureView:(UIView *)theView;

@end
