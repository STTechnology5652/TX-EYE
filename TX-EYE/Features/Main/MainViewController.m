//
//  MainViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/11.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "MainViewController.h"
#import "ControlPanelViewController.h"
#import "HelpPageViewController.h"
//#import "SettingViewController.h"
#import "SettingsViewController.h"
#import "Config.h"

@import Masonry;

#import "MessageCenter.h"

@interface MainViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *helpButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIImageView *aircraftImageView;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set background image
    self.view.backgroundColor = [UIColor whiteColor];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_bg"]];
    [self.view addSubview:self.backgroundImageView];
    // layout constraint
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];

    // set aircraft image
    self.aircraftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aircraft"]];
    [self.view addSubview:self.aircraftImageView];
    // layout constraint
    [self.aircraftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(33.0);
        make.right.equalTo(self.view).with.offset(-33.0);
    }];
    
    // 初始化按键
    [self initButtons];
    
    // get device orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIDeviceOrientation orientation;
    NSValue *value = [[UIDevice currentDevice] valueForKey:@"orientation"];
    [value getValue:&orientation];
//    NSLog(@"Orientation: %ld", (long)orientation);
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    if (orientation != UIDeviceOrientationLandscapeLeft) {
        value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
    
    // 启动TCP消息中心
//    [[MessageCenter sharedInstance] start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive
{
    // 启动TCP消息中心
    [[MessageCenter sharedInstance] start];
}

- (void)applicationDidEnterBackground
{
    // 停止TCP消息中心
    [[MessageCenter sharedInstance] stop];
}

#pragma mark - Screen rotation & StatusBar Style

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Init Buttons

/**
 *  初始化按键
 */
- (void)initButtons
{
    // 初始化按键
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // 设置按键图像
    [self.playButton setImage:[UIImage imageNamed:@"home_play"] forState:UIControlStateNormal];
    [self.helpButton setImage:[UIImage imageNamed:@"home_help"] forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"home_settings"] forState:UIControlStateNormal];
    // 设置高亮
    [self.playButton setImage:[UIImage imageNamed:@"home_play_h"] forState:UIControlStateHighlighted];
    [self.helpButton setImage:[UIImage imageNamed:@"home_help_h"] forState:UIControlStateHighlighted];
    [self.settingButton setImage:[UIImage imageNamed:@"home_settings_h"] forState:UIControlStateHighlighted];
    
    // 设置按键事件方法
    [self.playButton addTarget:self action:@selector(showControlPanel:) forControlEvents:UIControlEventTouchUpInside];
    [self.helpButton addTarget:self action:@selector(showHelp:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加按键到视图
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.helpButton];
    [self.view addSubview:self.settingButton];

    // 布局约束
#define BOTTOM_MARGIN   -21
#define RIGHT_MARGIN    -44
#define LEFT_MARGIN     44
#define BLANK_WIDTH     30
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(BOTTOM_MARGIN);
        make.right.equalTo(self.view).with.offset(RIGHT_MARGIN);
    }];
    [self.helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(BOTTOM_MARGIN);
        make.left.equalTo(self.view).with.offset(LEFT_MARGIN);
    }];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(BOTTOM_MARGIN);
        make.left.equalTo(self.helpButton.mas_right).with.offset(BLANK_WIDTH);
    }];
}

#pragma mark - Button Action

/**
 *  显示控制面板界面
 *
 *  @param button
 */
- (void)showControlPanel:(UIButton *)button
{
    NSURL *url = [NSURL URLWithString:PREVIEW_ADDRESS];
    [ControlPanelViewController presentFromViewController:self withTitle:@"" URL:url completion:nil];
}

/**
 *  显示帮助界面
 *
 *  @param sender
 */
- (void)showHelp:(UIButton *)sender
{
    HelpPageViewController *vc = [[HelpPageViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

/**
 *  显示设置界面
 *
 *  @param sender
 */
- (void)showSetting:(UIButton *)sender
{
//    SettingViewController *vc = [[SettingViewController alloc] init];
//    [self presentViewController:vc animated:YES completion:nil];
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
