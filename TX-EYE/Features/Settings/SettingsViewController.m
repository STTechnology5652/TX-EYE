//
//  SettingsViewController.m
//  TX-EYE
//
//  Created by CoreCat on 2021/11/21.
//  Copyright © 2021 CoreCat. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@interface SettingsViewController () <IASKSettingsDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.neverShowPrivacySettings = YES;
    self.showDoneButton = YES;
    self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSetting:) name:kIASKAppSettingChanged object:nil];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didChangeSetting:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo != nil) {
        NSLog(@"Setting = %@", userInfo);
        
//        id net_protocol = [userInfo objectForKey:@"pref.key_net_protocol"];
//        if (net_protocol != nil) {
//            BOOL b = [net_protocol boolValue];
//            if (!b) {
//                NSSet *hiddenKeys = [NSSet setWithObjects:@"pref.key_tcp_timeout", nil];
//                [self setHiddenKeys:hiddenKeys animated:YES];
//            }
//        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSpecifier:(IASKSpecifier *)specifier
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:specifier.key];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:specifier.key];
//    }
    
    if ([specifier.key isEqualToString:@"pref.key_software_version"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:specifier.key];
        NSString *versionBuild = [self getAppVersion];
        [cell.textLabel setText:@"Version"];
        [cell.detailTextLabel setText:versionBuild];
    }
    else if ([specifier.key isEqualToString:@"pref.key_reset_parameters"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:specifier.key];
        [cell.textLabel setText:@"重置参数"];
    }
    
    return cell;
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier *)specifier
{
    if ([specifier.key isEqualToString:@"pref.key_reset_parameters"]) {
        [self resetParameters];
    }
}

- (NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    // version+build
    NSString *versionBuild = [NSString stringWithFormat:@"%@ (Build %@)", appVersion, appBuild];
    
    return versionBuild;
}

- (void)resetParameters
{
    // 重置设置
    [Settings resetSettings];
    
    // 显示重置成功的Alert
    NSString *title = NSLocalizedString(@"RESET_ALERT_TITLE", @"Reset Alert Title");
    NSString *message = NSLocalizedString(@"RESET_ALERT_MESSAGE", @"Reset alert message");
    NSString *buttonTitle = NSLocalizedString(@"RESET_ALERT_OK_BUTTON_TITLE", @"Reset alert OK button title");
    
    // 使用UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self showViewController:alertController sender:nil];
}

@end
