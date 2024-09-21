//
//  UIScreen+SafeArea.h
//  TX-EYE
//
//  Created by CoreCat on 2018/3/15.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (SafeArea)

- (CGFloat)topOfSafeArea;
- (CGFloat)leftOfSafeArea;
- (CGFloat)bottomOfSafeArea;
- (CGFloat)rightOfSafeArea;

- (CGFloat)widthOfSafeArea;
- (CGFloat)heightOfSafeArea;

@end
