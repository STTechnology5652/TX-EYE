//
//  MBProgressHUD+KeyWindow.h
//  TX-EYE
//
//  Created by CoreCat on 2017/11/9.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (KeyWindow)

+ (MBProgressHUD *)createIndeterminateProgressHUDAddedTo:(UIView *)view withTitle:(NSString *)title detail:(NSString *)detail;
+ (MBProgressHUD *)createDeterminateProgressHUDAddedTo:(UIView *)view withTitle:(NSString *)title detail:(NSString *)detail;

+ (MBProgressHUD *)createIndeterminateProgressHUDWithTitle:(NSString *)title detail:(NSString *)detail;
+ (MBProgressHUD *)createDeterminateProgressHUDWithTitle:(NSString *)title detail:(NSString *)detail;
+ (MBProgressHUD *)hudForKeyWindow;

@end
