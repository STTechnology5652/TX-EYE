//
//  VideoLibraryManagerViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/27.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "VideoLibraryManagerViewController.h"
#import "Utilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "Config.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MBProgressHUD+KeyWindow.h"
#import "UIAlertView+Notification.h"
#import "UIView+Toast.h"
#import <objc/runtime.h>
#import "MediaManager.h"

@interface VideoLibraryManagerViewController ()

@end

@implementation VideoLibraryManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册UITableViewCell以做复用
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

/**
 *  重新载入视频列表
 */
- (void)reloadListData
{
    // reload tableView
    self.listItems = [Utilities loadListOfType:MediaFileTypeVideo];
    [self.tableView reloadData];
}

/**
 *  播放视频
 *
 *  @param indexPath 视频索引
 */
- (void)displayMediaAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    // 视频地址
    NSString *videoFilePath = self.listItems[section][@"FileItems"][row][@"FilePath"];
    
    // 配置video player，并播放
    NSURL *fileURL = [NSURL fileURLWithPath:videoFilePath];
    if (@available(iOS 9.0, *)) {
        AVPlayerViewController *moviePlayerVC = [[AVPlayerViewController alloc] init];
        moviePlayerVC.player = [AVPlayer playerWithURL:fileURL];
        moviePlayerVC.videoGravity = AVLayerVideoGravityResizeAspect;
        moviePlayerVC.showsPlaybackControls = YES;
        moviePlayerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        moviePlayerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:moviePlayerVC animated:YES completion:^{
            [moviePlayerVC.player play];
        }];
    } else {
        MPMoviePlayerViewController *moviePlayerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
        moviePlayerVC.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerVC];
    }
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    NSString *videoFilePath = self.listItems[section][@"FileItems"][row][@"FilePath"];
    
    // 加载缩略图
    [[MediaManager sharedInstance] createVideoThumbnailURL:videoFilePath
                                                completion:^(UIImage *image, NSError *error) {
                                                    cell.imageView.image = image;
                                                    [cell setNeedsLayout];
                                                }];
    
    // 显示文件名
    NSString *videoFileName = self.listItems[section][@"FileItems"][row][@"FileName"];
    cell.textLabel.text = [[videoFileName componentsSeparatedByString:@"."] firstObject];

    // Save to album
    UIButton *saveToAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveToAlbumButton setImage:[UIImage imageNamed:@"save_to_album"] forState:UIControlStateNormal];
    [saveToAlbumButton sizeToFit];
    [saveToAlbumButton addTarget:self action:@selector(saveToAlbum:) forControlEvents:UIControlEventTouchUpInside];
    // Associate FilePath to saveToAlbumButton
    objc_setAssociatedObject(saveToAlbumButton, "FilePath", videoFilePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [cell setAccessoryView:saveToAlbumButton];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

#pragma mark - Save to album

/**
 *  Save video to the album named with app name
 */
- (void)saveToAlbum:(UIButton *)button
{
    NSString *videoFilePath = objc_getAssociatedObject(button, "FilePath");

    [self requestPhotoAccessAuthorization:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doSaveToAlbum:videoFilePath];
            });
        } else {
            // 临时使用
            dispatch_async(dispatch_get_main_queue(), ^{
                if (@available(iOS 8.0, *)) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MEDIA_LIBRARY_PERMISSION_DENIED", @"")
                                                                                             message:NSLocalizedString(@"MEDIA_LIBRARY_ACCESS_PHOTO_PERMISSION", @"")
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                                           style:UIAlertActionStyleCancel
                                                                         handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MEDIA_LIBRARY_PERMISSION_DENIED", @"")
                                                                        message:NSLocalizedString(@"MEDIA_LIBRARY_ACCESS_PHOTO_PERMISSION", @"")
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
            });
        }
    }];
}

- (void)doSaveToAlbum:(NSString *)videoFilePath
{
    unsigned long long fileSize = [Utilities getFileSizeAtPath:videoFilePath];
    long long freeDiskSpace = [Utilities freeDiskSpaceInBytes];
    
    // FIXME: freeDiskSpace is not the real free space, how can I get the real space
    //    if (fileSize > freeDiskSpace) {
    if (fileSize + 200 * 1024 * 1024 > freeDiskSpace) {
        NSString *title = nil;
        NSString *message = NSLocalizedString(@"MEDIA_LIBRARY_NEED_MORE_SPACE", @"");
        [UIAlertView showAlertDialogWithTitle:title message:message];
    } else {
        NSURL *videoFileUrl = [NSURL fileURLWithPath:videoFilePath];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoFileUrl]) {
            // Show HUD
            MBProgressHUD *hud = [MBProgressHUD createIndeterminateProgressHUDWithTitle:NSLocalizedString(@"MEDIA_LIBRARY_PLEASE_WAIT", @"") detail:NSLocalizedString(@"MEDIA_LIBRARY_SAVING_VIDEO_FILE", @"")];
            [hud showAnimated:YES];
            
            dispatch_async(dispatch_queue_create("saveVideoToAlbum", NULL), ^{
                NSString *albumName = [Utilities getAppName]; // use app name as album name
                [library saveVideo:videoFileUrl toAlbum:albumName completion:^(NSURL *assetURL, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Hide HUD
                        MBProgressHUD *hud = [MBProgressHUD hudForKeyWindow];
                        [hud hideAnimated:YES];
                        
                        if (error) {
                            NSString *title = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_FAILED", @"");
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MEDIA_LIBRARY_SAVE_VIDEO_ERROR", @""), error.localizedDescription];
                            [UIAlertView showAlertDialogWithTitle:title message:message];
                        } else {
                            NSString *message = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_VIDEO_SUCCESS", @"");
                            [self.view makeToast:message duration:1.0 position:CSToastPositionBottom];
                        }
                    });
                } failure:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Hide HUD
                        MBProgressHUD *hud = [MBProgressHUD hudForKeyWindow];
                        [hud hideAnimated:YES];
                        
                        NSString *title = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_FAILED", @"");
                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MEDIA_LIBRARY_SAVE_VIDEO_ERROR", @""), error.localizedDescription];
                        [UIAlertView showAlertDialogWithTitle:title message:message];
                    });
                }];
            });
        } else {
            NSString *title = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_FAILED", @"");
            NSString *message = NSLocalizedString(@"MEDIA_LIBRARY_VIDEO_INCOMPATIBLE", @"");
            [UIAlertView showAlertDialogWithTitle:title message:message];
        }
    }
}

@end
