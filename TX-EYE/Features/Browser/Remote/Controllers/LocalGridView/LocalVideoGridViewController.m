//
//  LocalVideoGridViewController.m
//  GoTrack
//
//  Created by CoreCat on 2018/11/5.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "LocalVideoGridViewController.h"
#import "MediaManager.h"

#import "VideoPlayerViewController.h"

@import MWPhotoBrowser;


#define USE_INTERNAL_PLAYER     1


@interface LocalVideoGridViewController () <MWPhotoBrowserDelegate>

@end

@implementation LocalVideoGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadMediaList];
}

#pragma mark - Reload Media List

- (void)reloadMediaList
{
    [MediaManager.sharedInstance getAllLocalVideoFilesWithCompletion:^(NSArray * _Nullable array, NSError * _Nullable error) {
        self.mediaList = [array mutableCopy];
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

#pragma mark - UICollectionView DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaGridCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL selected = [[self.selectedList objectAtIndex:indexPath.row] boolValue];
    
    cell.index = indexPath.row;
    
    LocalFile *localFile = [self.mediaList objectAtIndex:indexPath.row];
    
    // PlaceHolder
    UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder_video"];
    [cell.imageView setImage:placeHolderImage];
    
    // 缩略图，此处有缓存
    [MediaManager.sharedInstance createVideoThumbnailURL:localFile.fullPath
                                              completion:^(UIImage *image, NSError *error) {
                                                  // Image
                                                  [cell.imageView setImage:image];
                                                  [cell setNeedsLayout];
                                              }];
    
    // 选择
    [cell setSelectionMode:self.selectionMode];
    [cell setIsSelected:selected];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaList.count;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    } else {
#if USE_INTERNAL_PLAYER
        // 显示图片浏览器
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        
        // Set options
        browser.displayActionButton = YES;
        browser.displayNavArrows = YES;
        browser.displaySelectionButtons = NO;
        browser.zoomPhotosToFill = YES;
        browser.alwaysShowControls = NO;
        browser.enableGrid = YES;
        browser.startOnGrid = NO;
        browser.autoPlayOnAppear = YES;
        
        [browser setCurrentPhotoIndex:indexPath.row];
        
        [self.navigationController pushViewController:browser animated:YES];
    }
#else
    LocalFile *localFile = [self.mediaList objectAtIndex:indexPath.row];
    // 播放本地视频
    [VideoPlayerViewController presentFromViewController:self withTitle:localFile.name URL:[NSURL URLWithString:localFile.fullPath] completion:nil];
#endif
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.mediaList.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.mediaList.count) {
        LocalFile *localFile = [self.mediaList objectAtIndex:index];
        MWPhoto *video = [MWPhoto videoWithURL:[NSURL fileURLWithPath:localFile.fullPath]];
        // 这是一个trick，为的是让浏览器显示ActionButton，以保存视频到系统相册
        // 一般情况下不会使用
        video.underlyingImage = [UIImage new];
        return video;
    }
    return nil;
}

@end
