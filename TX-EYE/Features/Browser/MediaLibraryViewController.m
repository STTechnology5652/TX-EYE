//
//  MediaLibraryViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/21.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "MediaLibraryViewController.h"
#import "PhotoLibraryManagerViewController.h"
#import "VideoLibraryManagerViewController.h"

@import Masonry;

#import "MessageCenter.h"
#import "RemotePhotoGridViewController.h"
#import "RemoteVideoGridViewController.h"
#import "BrowserNavigationController.h"

typedef void(^MasonryConstraintBlock)(MASConstraintMaker *);

@interface MediaLibraryViewController ()
{
    MasonryConstraintBlock localPhotoConstraintBlock;
    MasonryConstraintBlock localVideoConstraintBlock;
    MasonryConstraintBlock localPhotoConstraintBlockR;
    MasonryConstraintBlock localVideoConstraintBlockR;
    MasonryConstraintBlock remotePhotoConstraintBlockR;
    MasonryConstraintBlock remoteVideoConstraintBlockR;
}

@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *cardPhotoButton;
@property (nonatomic, strong) UIButton *cardVideoButton;

@end

@implementation MediaLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色为黑色
    self.view.backgroundColor = [UIColor colorWithRed:0 green:8.0/255.0 blue:23.0/255.0 alpha:1.0];
    
    // 初始化按键
    [self initButtons];
    
    // 更新卡按钮状态
    [self updateButtonConstraints];
    
    // MessageCenter消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageCenterNotification:) name:kMessageCenterMessageNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  自动旋转
 *
 *  @return 固定值，不支持旋屏
 */
-(BOOL)shouldAutorotate
{
    return NO;
}

/**
 *  初始化按键
 */
- (void)initButtons
{
    // 配置返回键
    self.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.returnButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [self.returnButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.returnButton];
    
    // 配置照片按键
    self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.photoButton setImage:[UIImage imageNamed:@"photo_library"] forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.photoButton];
    
    // 配置视频按键
    self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoButton setImage:[UIImage imageNamed:@"video_library"] forState:UIControlStateNormal];
    [self.videoButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.videoButton];
    
    // 远程照片
    self.cardPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cardPhotoButton setImage:[UIImage imageNamed:@"card_photo_library"] forState:UIControlStateNormal];
    [self.cardPhotoButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cardPhotoButton];
    
    // 远程视频
    self.cardVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cardVideoButton setImage:[UIImage imageNamed:@"card_video_library"] forState:UIControlStateNormal];
    [self.cardVideoButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cardVideoButton];
    
    // 布局约束
    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).with.offset(8.0);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).with.offset(8.0);
        } else {
            make.top.and.left.mas_equalTo(8.0);
        }
    }];
    
    UIView *container = self.view;
    
    /* 没有远程卡状态下 */
    
    localPhotoConstraintBlock = ^(MASConstraintMaker *make) {
        make.centerY.equalTo(container);
        make.centerX.equalTo(container).multipliedBy(3.0/5.0);
    };
    
    localVideoConstraintBlock = ^(MASConstraintMaker *make) {
        make.centerY.equalTo(container);
        make.centerX.equalTo(container).multipliedBy(7.0/5.0);
    };
    
    /* 存在远程卡状态下 */
    
    localPhotoConstraintBlockR = ^(MASConstraintMaker *make) {
        make.centerY.equalTo(container).multipliedBy(3.0/5.0);
        make.centerX.equalTo(container).multipliedBy(3.0/5.0);
    };
    
    localVideoConstraintBlockR = ^(MASConstraintMaker *make) {
        make.centerY.equalTo(container).multipliedBy(3.0/5.0);
        make.centerX.equalTo(container).multipliedBy(7.0/5.0);
    };
    
    remotePhotoConstraintBlockR = ^(MASConstraintMaker *make) {
        make.centerY.equalTo(container).multipliedBy(7.0/5.0);
        make.centerX.equalTo(container).multipliedBy(3.0/5.0);
    };
    
    remoteVideoConstraintBlockR = ^(MASConstraintMaker *make) {
        make.centerY.equalTo(container).multipliedBy(7.0/5.0);
        make.centerX.equalTo(container).multipliedBy(7.0/5.0);
    };
}

- (void)updateButtonConstraints
{
    [self.cardPhotoButton mas_remakeConstraints:remotePhotoConstraintBlockR];
    [self.cardVideoButton mas_remakeConstraints:remoteVideoConstraintBlockR];
    
//    // 是否支持卡拍照
//    if ([[MessageCenter sharedInstance] isDeviceSupportFunction:DEVICE_FUNCTION_CARD_PHOTO]) {
        [self.photoButton mas_remakeConstraints:localPhotoConstraintBlockR];
        [self.cardPhotoButton setHidden:NO];
//    } else {
//        [self.photoButton mas_remakeConstraints:localPhotoConstraintBlock];
//        [self.cardPhotoButton setHidden:YES];
//    }
//    // 是否支持卡录像
//    if ([[MessageCenter sharedInstance] isDeviceSupportFunction:DEVICE_FUNCTION_CARD_VIDEO]) {
        [self.videoButton mas_remakeConstraints:localVideoConstraintBlockR];
        [self.cardVideoButton setHidden:NO];
//    } else {
//        [self.videoButton mas_remakeConstraints:localVideoConstraintBlock];
//        [self.cardVideoButton setHidden:YES];
//    }
}

/**
 *  触摸按键入口
 *
 *  @param button 按键
 */
- (void)tapButton:(UIButton *)button
{
    // 返回键
    if (button == self.returnButton) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    // 照片按键
    else if (button == self.photoButton) {
        PhotoLibraryManagerViewController *vc = [[PhotoLibraryManagerViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    // 视频按键
    else if (button == self.videoButton) {
        VideoLibraryManagerViewController *vc = [[VideoLibraryManagerViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    // 远程照片
    else if (button == self.cardPhotoButton) {
        RemotePhotoGridViewController *vc = [[RemotePhotoGridViewController alloc] init];
        BrowserNavigationController *nav = [[BrowserNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
    // 远程视频
    else if (button == self.cardVideoButton) {
        RemoteVideoGridViewController *vc = [[RemoteVideoGridViewController alloc] init];
        BrowserNavigationController *nav = [[BrowserNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Message Center Notification

- (void)didReceiveMessageCenterNotification:(NSNotification *)notification
{
    TCPMessage *message = [notification object];
    uint8_t messageId = message.messageId;
    
    if (messageId == MSG_ID_REPORT) {
        // MessageCenter处理过Report，判断是否显示卡拍照录像图标
        [self updateButtonConstraints];
    }
}

@end
