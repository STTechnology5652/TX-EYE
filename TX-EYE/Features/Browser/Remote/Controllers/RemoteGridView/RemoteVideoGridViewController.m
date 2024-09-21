//
//  RemoteVideoGridViewController.m
//  GoTrack
//
//  Created by CoreCat on 2018/11/5.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "RemoteVideoGridViewController.h"
#import "MediaManager.h"
#import "MediaManagerHelper.h"

#import "MBProgressHUD+KeyWindow.h"
#import "UIAlertController+Window.h"

#import "Utilities.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "RemoteFileCacheKeyFilter.h"

#import "VideoPlayerViewController.h"


@interface RemoteVideoGridViewController ()

@end

@implementation RemoteVideoGridViewController

#pragma mark - Reload Media List

- (void)reloadMediaList
{
    // 禁用自动锁屏
    [Utilities keepScreenOn:YES];
    
    // 显示HUD
    NSString *title = NSLocalizedString(@"FETCH_VIDEO_LIST", nil);
    MBProgressHUD *hud = [MBProgressHUD createIndeterminateProgressHUDWithTitle:title detail:nil];
    
    // 获取文件列表
    [MediaManager.sharedInstance getVideoFileListWithCompletion:^(NSArray * _Nullable array, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 恢复自动锁屏
            [Utilities keepScreenOn:NO];
            // 关闭HUD
            [hud hideAnimated:YES];
            // 关闭下拉刷新
            [self.refreshControl endRefreshing];
            // 根据有无错误做不同动作
            if (error) {
                NSString *title = NSLocalizedString(@"CONNECTION_FAILED_TITLE", nil);
                NSString *message = NSLocalizedString(@"CONNECTION_FAILED_MESSAGE", nil);
                [UIAlertController showAlertDialogWithTitle:title message:message];
                // Workaround，弹窗后不能UIRefreshControl收回，手动收回
//                [self.collectionView setContentOffset:CGPointZero];
            } else {
                self.mediaList = [array mutableCopy];
                [self fillSelectedListWith:NO count:self.mediaList.count];
                // 重新载入列表
                [self.collectionView reloadData];
                // 刷新文件状态
                [MediaManagerHelper checkRemoteFiles:self.mediaList withCompletion:^(NSError * _Nullable error) {
                    // 刷新文件状态完成后，重新载入GridView数据
                    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                }];
            }
        });
    }];
}

#pragma mark - UICollectionView DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaGridCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL selected = [[self.selectedList objectAtIndex:indexPath.row] boolValue];
    
    cell.index = indexPath.row;
    
    RemoteFile *remoteFile = [self.mediaList objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = remoteFile.name;

#if 0
    // PlaceHolder
    UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder_video"];
    
    // 缩略图
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:remoteFile.thumbPath]
//                      placeholderImage:placeHolderImage
//                               options:SDWebImageRefreshCached];
    
    id<SDWebImageCacheKeyFilter> cacheKeyFilter = [RemoteFileCacheKeyFilter cacheKeyFilterWithRemoteFile:remoteFile];
    SDWebImageContext *context = @{ SDWebImageContextCacheKeyFilter: cacheKeyFilter };
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:remoteFile.thumbPath]
                      placeholderImage:placeHolderImage
                               options:0
                               context:context];
#endif
    
    // 选择
    [cell setSelectionMode:self.selectionMode];
    [cell setIsSelected:selected];
    // 已下载
    [cell setIsDownloaded:remoteFile.downloaded];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaList.count;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectionMode) {
        // 选择
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    } else {
        RemoteFile *remoteFile = [self.mediaList objectAtIndex:indexPath.row];
        [VideoPlayerViewController presentFromViewController:self withTitle:remoteFile.name URL:[NSURL URLWithString:remoteFile.webPath] completion:nil];
    }
}

@end
