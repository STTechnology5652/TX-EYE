//
//  BaseViewController.m
//  GoTrack
//
//  Created by CoreCat on 2018/5/21.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "BaseViewController.h"
#import "UIColor+Theme.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor themeBackgroundColor];
}

@end
