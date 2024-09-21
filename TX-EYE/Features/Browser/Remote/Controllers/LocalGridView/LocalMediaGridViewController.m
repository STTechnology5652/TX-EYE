//
//  LocalMediaGridViewController.m
//  GoTrack
//
//  Created by CoreCat on 2018/11/6.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "LocalMediaGridViewController.h"
#import "MediaManager.h"
#import "LocalFile.h"
#import "Utilities.h"

#import "UIAlertController+Window.h"

@import Masonry;


@interface LocalMediaGridViewController ()

@end

@implementation LocalMediaGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBottomViewItems];
    [self setupButtonsHandler];
}

#pragma mark - Views

- (void)setupBottomViewItems
{
    UIView *bottomView = self.bottomView;
    
    // 全选按钮
    UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _selectAllButton = selectAllButton;
    [bottomView addSubview:selectAllButton];
    [selectAllButton setImage:[UIImage imageNamed:@"media_selectall"] forState:UIControlStateNormal];
    [selectAllButton setTintColor:[UIColor whiteColor]];
    [selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.and.left.equalTo(bottomView);
        make.right.equalTo(bottomView.mas_centerX);
    }];
    
    // 删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _deleteButton = deleteButton;
    [bottomView addSubview:deleteButton];
    [deleteButton setImage:[UIImage imageNamed:@"media_delete"] forState:UIControlStateNormal];
    [deleteButton setTintColor:[UIColor whiteColor]];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView.mas_centerX);
        make.top.bottom.and.right.equalTo(bottomView);
    }];
}

#pragma mark - Buttons

- (void)setupButtonsHandler
{
    [self.selectAllButton addTarget:self action:@selector(tapSelectAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(tapDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapSelectAllButton:(UIButton *)sender
{
    if (self.editing) {
        [self fillSelectedListWith:!self.allSelected count:self.mediaList.count];
        self.allSelected = [self selectedAllMediaFiles];
        [self.collectionView reloadData];
    }
}

- (void)tapDeleteButton:(UIButton *)sender
{
    if (self.isEditing) {
        NSArray<LocalFile *> *selectedItems = [self getSelectedItems];
        
        if (selectedItems.count > 0) {
            // 逆序，保证从尾部开始向头部删除
            NSArray<LocalFile *> *sortedSelectedItems = [selectedItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                LocalFile *localFile1 = obj1;
                LocalFile *localFile2 = obj2;
                NSUInteger idx1 = [self.mediaList indexOfObject:localFile1];
                NSUInteger idx2 = [self.mediaList indexOfObject:localFile2];
                
                if (idx1 < idx2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            
            // 弹出确认
            NSString *title = NSLocalizedString(@"CONFIRM", nil);
            NSString *message = NSLocalizedString(@"FILE_WILL_BE_DELETED", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *yesActionTitle = NSLocalizedString(@"YES", nil);
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesActionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];
                
                // 执行删除任务
                for (NSUInteger i = 0; i < sortedSelectedItems.count; i++) {
                    LocalFile *localFile = [sortedSelectedItems objectAtIndex:i];
                    NSUInteger index = [self.mediaList indexOfObject:localFile];
                    
                    // 如果删除成功
                    if ([Utilities removeFile:localFile.fullPath]) {
                        [self.mediaList removeObject:localFile];
                        [self.selectedList removeObjectAtIndex:index];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                    }
                }
                
                // 从GridView中移除已经删除的图片
                [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            }];
            [alertController addAction:yesAction];
            
            NSString *noActionTitle = NSLocalizedString(@"NO", nil);
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:noActionTitle style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:noAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            NSString *message = NSLocalizedString(@"SELECTED_AT_LEAST_ONE_FILE", nil);
            [UIAlertController showAlertDialogWithTitle:nil message:message];
        }
    }
}

#pragma mark - Misc

- (void)resetSelectedList
{
    [self fillSelectedListWith:NO count:self.mediaList.count];
}

- (NSArray<LocalFile *> *)getSelectedItems
{
    NSMutableArray<LocalFile *> *array = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < self.selectedList.count; i++) {
        BOOL bValue = [[self.selectedList objectAtIndex:i] boolValue];
        if (bValue) {
            [array addObject:[self.mediaList objectAtIndex:i]];
        }
    }
    
    return array;
}

- (BOOL)selectedAllMediaFiles
{
    NSUInteger count = [self.mediaList count];
    for (NSUInteger i = 0; i < count; i++) {
        BOOL selected = [[self.selectedList objectAtIndex:i] boolValue];
        if (!selected)
            return NO;
    }
    return YES;
}

#pragma mark - CollectionView

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 选择
    BOOL selected = [[self.selectedList objectAtIndex:indexPath.row] boolValue];
    [self.selectedList replaceObjectAtIndex:indexPath.row withObject:@(!selected)];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    // 检查全选
    self.allSelected = [self selectedAllMediaFiles];
}

#pragma mark - Reload Media List

- (void)reloadMediaList
{
    // implement in subclass
}

@end
