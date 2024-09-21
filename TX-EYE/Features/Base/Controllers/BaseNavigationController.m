//
//  BaseNavigationController.m
//  GoTrack
//
//  Created by CoreCat on 2018/5/21.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "BaseNavigationController.h"
#import "UIColor+Theme.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 导航栏色调和背景颜色
    self.navigationBar.tintColor = [UIColor themeColor];
    self.navigationBar.barTintColor = [UIColor navigationBarTintColor];
    // 导航栏不透明
    self.navigationBar.translucent = NO;
    // 导航栏文字颜色
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor navigationBarTitleColor] };
}

@end
