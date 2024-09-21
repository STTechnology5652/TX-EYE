//
//  UIAlertController+Window.h
//  GoTrack
//
//  Created by CoreCat on 2018/7/18.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Window)

- (void)show;
- (void)show:(BOOL)animated;

+ (void)showAlertDialogWithTitle:(NSString *)title message:(NSString *)message;

@end
