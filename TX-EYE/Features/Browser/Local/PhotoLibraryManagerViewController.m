//
//  PhotoLibraryManagerViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/27.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "PhotoLibraryManagerViewController.h"
#import "Utilities.h"
#import "PhotoDisplayViewController.h"
#import "Config.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MBProgressHUD+KeyWindow.h"
#import "UIAlertView+Notification.h"
#import "UIView+Toast.h"
#import <objc/runtime.h>
#import "MediaManager.h"

@interface PhotoLibraryManagerViewController ()

@end

@implementation PhotoLibraryManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册UITableViewCell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

/**
 *  重新载入图像列表
 */
- (void)reloadListData
{
    // reload tableView
    self.listItems = [Utilities loadListOfType:MediaFileTypePhoto];
    [self.tableView reloadData];
}

/**
 *  展示图像
 *
 *  @param indexPath 图像索引
 */
- (void)displayMediaAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    // 图像地址
    NSString *imageFilePath = self.listItems[section][@"FileItems"][row][@"FilePath"];
    
    // 配置VC并显示，以展示图片
    PhotoDisplayViewController *vc = [[PhotoDisplayViewController alloc] init];
    vc.imageFilePath = imageFilePath;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
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
    
    // 显示小图
    NSString *imageFilePath = self.listItems[section][@"FileItems"][row][@"FilePath"];
    // Thumbnail
    [[MediaManager sharedInstance] createImageThumbnailURL:imageFilePath
                                                completion:^(UIImage *image, NSError *error) {
                                                    cell.imageView.image = image;
                                                    [cell setNeedsLayout];
                                                }];
    // 显示文件名
    NSString *imageFileName = self.listItems[section][@"FileItems"][row][@"FileName"];
    cell.textLabel.text = [[imageFileName componentsSeparatedByString:@"."] firstObject];

    // Save to album
    UIButton *saveToAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveToAlbumButton setImage:[UIImage imageNamed:@"save_to_album"] forState:UIControlStateNormal];
    [saveToAlbumButton sizeToFit];
    [saveToAlbumButton addTarget:self action:@selector(saveToAlbum:) forControlEvents:UIControlEventTouchUpInside];
    // Associate FilePath to saveToAlbumButton
    objc_setAssociatedObject(saveToAlbumButton, "FilePath", imageFilePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [cell setAccessoryView:saveToAlbumButton];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

#pragma mark - Save to album

/**
 *  Save photo to the album named with app name
 */
- (void)saveToAlbum:(UIButton *)button
{
    NSString *imageFilePath = objc_getAssociatedObject(button, "FilePath");

    [self requestPhotoAccessAuthorization:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doSaveToAlbum:imageFilePath];
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

- (void)doSaveToAlbum:(NSString *)imageFilePath
{
    unsigned long long fileSize = [Utilities getFileSizeAtPath:imageFilePath];
    long long freeDiskSpace = [Utilities freeDiskSpaceInBytes];
    
    if (fileSize > freeDiskSpace) {
        NSString *title = nil;
        NSString *message = NSLocalizedString(@"MEDIA_LIBRARY_NEED_MORE_SPACE", @"");
        [UIAlertView showAlertDialogWithTitle:title message:message];
    } else {
        // Show HUD
        MBProgressHUD *hud = [MBProgressHUD createIndeterminateProgressHUDWithTitle:NSLocalizedString(@"MEDIA_LIBRARY_PLEASE_WAIT", @"") detail:NSLocalizedString(@"MEDIA_LIBRARY_SAVING_IMAGE_FILE", @"")];
        [hud showAnimated:YES];
        
        NSString *albumName = [Utilities getAppName]; // use app name as album name
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveImageData:[NSData dataWithContentsOfFile:imageFilePath] toAlbum:albumName metadata:nil completion:^(NSURL *assetURL, NSError *error) {
            // Hide HUD
            MBProgressHUD *hud = [MBProgressHUD hudForKeyWindow];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            if (error) {
                NSString *title = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_FAILED", @"");
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MEDIA_LIBRARY_SAVE_IMAGE_ERROR", @""), error.localizedDescription];
                [UIAlertView showAlertDialogWithTitle:title message:message];
            } else {
                NSString *message = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_IAMGE_SUCCESS", @"");
                [self.view makeToast:message duration:1.0 position:CSToastPositionBottom];
            }
        } failure:^(NSError *error) {
            // Hide HUD
            MBProgressHUD *hud = [MBProgressHUD hudForKeyWindow];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            NSString *title = NSLocalizedString(@"MEDIA_LIBRARY_SAVE_FAILED", @"");
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MEDIA_LIBRARY_SAVE_IMAGE_ERROR", @""), error.localizedDescription];
            [UIAlertView showAlertDialogWithTitle:title message:message];
        }];
    }
}

@end
