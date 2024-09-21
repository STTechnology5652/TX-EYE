//
//  MBProgressHUD+KeyWindow.m
//  TX-EYE
//
//  Created by CoreCat on 2017/11/9.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "MBProgressHUD+KeyWindow.h"

@implementation MBProgressHUD (KeyWindow)

+ (MBProgressHUD *)createIndeterminateProgressHUDAddedTo:(UIView *)view withTitle:(NSString *)title detail:(NSString *)detail
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = title;
    hud.detailsLabel.text = detail;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:.3f];
    
    return hud;
}

+ (MBProgressHUD *)createDeterminateProgressHUDAddedTo:(UIView *)view withTitle:(NSString *)title detail:(NSString *)detail
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = title;
    hud.detailsLabel.text = detail;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:.3f];
    
    return hud;
}

+ (MBProgressHUD *)createIndeterminateProgressHUDWithTitle:(NSString *)title detail:(NSString *)detail
{
    return [self createIndeterminateProgressHUDAddedTo:[self keyWindow] withTitle:title detail:detail];
}

+ (MBProgressHUD *)createDeterminateProgressHUDWithTitle:(NSString *)title detail:(NSString *)detail
{
    return [self createDeterminateProgressHUDAddedTo:[self keyWindow] withTitle:title detail:detail];
}

+ (MBProgressHUD *)hudForKeyWindow
{
    return [MBProgressHUD HUDForView:[self keyWindow]];
}

+ (UIView *)keyWindow
{
//    return [[[UIApplication sharedApplication] windows] firstObject];
    return [[UIApplication sharedApplication] keyWindow];
}

@end
