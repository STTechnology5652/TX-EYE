//
//  RemoteMediaGridViewController.m
//  GoTrack
//
//  Created by CoreCat on 2018/11/6.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "RemoteMediaGridViewController.h"
#import "MediaManager.h"
#import "MediaManagerHelper.h"

#import "MBProgressHUD+KeyWindow.h"
#import "UIAlertController+Window.h"
#import "BWSocketWrapper.h"
#import "NSError+BWSDK.h"
#import "Utilities.h"
#import "UIColor+Theme.h"

@import Masonry;


@interface RemoteMediaGridViewController ()
{
    CGFloat _gridCellHeight;
}

@end

@implementation RemoteMediaGridViewController

- (instancetype)init
{
    self = [super init];
    
    // 重新布局
    self.columns = 1; self.columnsL = 1;
    self.margin = 1; self.gutter = 2;
    self.marginL = 1; self.gutterL = 2;
    
    _gridCellHeight = 56;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBottomViewItems];
    [self setupButtonsHandler];
    
    // 下拉刷新
    [self addRefreshControl];
    
    // 添加返回
    [self addReturnButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // APP准备进入后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    // 是否从navigationController进入
    if ([self isMovingToParentViewController]) {
        [self reloadMediaList];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 取消通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 是否从navigationController退出
    if ([self isMovingFromParentViewController]) {
        // 界面消失，则中止下载
        [MediaManager.sharedInstance cancelDownload];
        
        // 退出动作
//        [self doExit];
    }
}

- (void)applicationWillResignActive
{
    // APP准备进入后台，取消下载
    [MediaManager.sharedInstance cancelDownload];
}

- (void)doExit
{
    NSString *title = NSLocalizedString(@"EXITING", nil);
    MBProgressHUD *hud = [MBProgressHUD createIndeterminateProgressHUDWithTitle:title detail:nil];
    [hud showAnimated:YES];

    [[BWSocketWrapper sharedInstance] startRecordWithCompletion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    }];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Views

- (void)addReturnButton
{
    if (self.navigationController) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
        self.navigationItem.leftBarButtonItem = button;
    }
}

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
        make.right.equalTo(bottomView.mas_centerX).multipliedBy(2.0 / 3.0);
    }];
    
    // 下载按钮
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _downloadButton = downloadButton;
    [bottomView addSubview:downloadButton];
    [downloadButton setImage:[UIImage imageNamed:@"media_download"] forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView.mas_centerX).multipliedBy(2.0 / 3.0);
        make.top.and.bottom.equalTo(bottomView);
        make.right.equalTo(bottomView.mas_centerX).multipliedBy(4.0 / 3.0);
    }];
    
    // 删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _deleteButton = deleteButton;
    [bottomView addSubview:deleteButton];
    [deleteButton setImage:[UIImage imageNamed:@"media_delete"] forState:UIControlStateNormal];
    [deleteButton setTintColor:[UIColor whiteColor]];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView.mas_centerX).multipliedBy(4.0 / 3.0);
        make.top.bottom.and.right.equalTo(bottomView);
    }];
}

#pragma mark - UIRefreshControl

- (void)addRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshMediaList:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)refreshMediaList:(UIRefreshControl *)refreshControl
{
    [self reloadMediaList];
}

#pragma mark - Buttons

- (void)setupButtonsHandler
{
    [self.selectAllButton addTarget:self action:@selector(tapSelectAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadButton addTarget:self action:@selector(tapDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(tapDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapSelectAllButton:(UIButton *)sender
{
    if (self.isEditing) {
        [self fillSelectedListWith:!self.allSelected count:self.mediaList.count];
        self.allSelected = [self selectedAllMediaFiles];
#if 0
        // !!!如果已经下载就不选择!!!
        for (int i=0; i<self.mediaList.count; i++) {
            RemoteFile *remoteFile = [self.mediaList objectAtIndex:i];
            if (!remoteFile.downloaded)
                [self.selectedList replaceObjectAtIndex:i withObject:@(YES)];
        }
#endif
        [self.collectionView reloadData];
    }
}

- (void)tapDownloadButton:(UIButton *)sender
{
    if (self.isEditing) {
        NSArray<RemoteFile *> *selectedItems = [self getSelectedItems];
        if (selectedItems.count > 0) {
            [self downloadFiles:selectedItems];
        } else {
            NSString *message = NSLocalizedString(@"SELECTED_AT_LEAST_ONE_FILE", nil);
            [UIAlertController showAlertDialogWithTitle:nil message:message];
        }
    }
}

- (void)tapDeleteButton:(UIButton *)sender
{
    if (self.isEditing) {
        NSArray<RemoteFile *> *selectedItems = [self getSelectedItems];
        
        if (selectedItems.count > 0) {
            // 逆序，保证从尾部开始向头部删除
            NSArray<RemoteFile *> *sortedSelectedItems = [selectedItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                RemoteFile *remoteFile1 = obj1;
                RemoteFile *remoteFile2 = obj2;
                NSUInteger idx1 = [self.mediaList indexOfObject:remoteFile1];
                NSUInteger idx2 = [self.mediaList indexOfObject:remoteFile2];
                
                if (idx1 < idx2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            
            // 弹出警告
            NSString *title = NSLocalizedString(@"CONFIRM", nil);
            NSString *message = NSLocalizedString(@"FILE_WILL_BE_DELETED", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *yesActionTitle = NSLocalizedString(@"YES", nil);
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesActionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // 从FTP服务器中删除文件
                [self deleteRemoteFiles:sortedSelectedItems];
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

#pragma mark - FTP

- (void)downloadFiles:(NSArray *)files
{
    // 禁用自动锁屏
    [Utilities keepScreenOn:YES];
    
    // 显示HUD
    NSString *title = NSLocalizedString(@"PREPARE_TO_DOWNLOAD", nil);
    NSString *cancelTitle = NSLocalizedString(@"CANCEL", nil);
    MBProgressHUD *hud = [MBProgressHUD createDeterminateProgressHUDWithTitle:title detail:nil];
    [hud.button addTarget:self action:@selector(tapCancelDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [hud.button setTitle:cancelTitle forState:UIControlStateNormal];
    
    // started block
    void (^started)(NSString *) = ^(NSString *fileName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud.label setText:fileName];
            [hud setProgress:0.f];
            [hud showAnimated:YES];
            // 禁用返回按键
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
        });
    };
    
    // progress block
    BOOL (^progress)(NSUInteger, NSUInteger) = ^BOOL(NSUInteger received, NSUInteger totalBytes) {
        if (totalBytes != 0) {
            float progress = (float)received / totalBytes;
            NSString *downloadedFormat = NSLocalizedString(@"DOWNLOADED_FORMAT", nil);
            NSString *detail = [NSString stringWithFormat:downloadedFormat, [Utilities memoryFormatter:received], [Utilities memoryFormatter:totalBytes]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud setProgress:progress];
                [hud.detailsLabel setText:detail];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud setMode:MBProgressHUDModeIndeterminate];
                [hud.detailsLabel setText:nil];
            });
        }
        
        return YES;
    };
    
    // completion block
    void (^completion)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 恢复自动锁屏
            [Utilities keepScreenOn:NO];
            // 关闭选择模式
//            [self openEditingMode:NO];    // Put it before reload table
            // 刷新列表文件状态
            [MediaManagerHelper checkRemoteFiles:self.mediaList withCompletion:^(NSError * _Nullable error) {
                [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }];
            // 关闭HUD
            [hud hideAnimated:YES];
            
            if (error != nil) {
                if (error.code == BWSDKMediaManagerErrorUserAborted) {
                    NSString *message = NSLocalizedString(@"DOWNLOAD_ABORTED", nil);
                    [UIAlertController showAlertDialogWithTitle:nil message:message];
                } else {
                    NSString *message = NSLocalizedString(@"DOWNLOAD_FAILED", nil);
                    [UIAlertController showAlertDialogWithTitle:nil message:message];
                }
            }
            // 重新启用返回按键
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
        });
    };
    
    // 下载
    if (files.count > 0) {
        RemoteFile *remoteFile = [files objectAtIndex:0];
        if (remoteFile.isVideo) {
            [MediaManager.sharedInstance downloadRemoteVideoFiles:files started:started progress:progress withCompletion:completion];
        } else {
            [MediaManager.sharedInstance downloadRemoteImageFiles:files started:started progress:progress withCompletion:completion];
        }
    }
}

- (void)tapCancelDownloadButton:(UIButton *)button
{
    MBProgressHUD *hud = [MBProgressHUD hudForKeyWindow];
    if (hud) {
        NSString *title = NSLocalizedString(@"CANCELLING_DOWNLOAD", nil);
//        [hud hideAnimated:NO];
        [hud.button removeTarget:self action:@selector(tapCancelDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
        [hud setMode:MBProgressHUDModeIndeterminate];
        [hud.label setText:title];
        [hud.detailsLabel setText:nil];
        [hud showAnimated:YES];
    }
    [MediaManager.sharedInstance cancelDownload];
}

- (void)deleteRemoteFiles:(NSArray<RemoteFile *> *)files
{
    NSUInteger totalNumber = files.count;
    
    NSString *title = NSLocalizedString(@"PREPARE_TO_DELETE", nil);
    MBProgressHUD *hud = [MBProgressHUD createDeterminateProgressHUDWithTitle:title detail:nil];
    
    // started block
    // 显示HUD，并禁用返回按键
    void (^started)(void) = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 显示HUD
            [hud showAnimated:YES];
            // 禁用返回按键
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
        });
    };
    
    // 单次完成Block
    // 从数组中删除，从GridView中删除，更新HUD
    void (^singleCompletion)(RemoteFile *, NSArray<RemoteFile *> *, NSError *__nullable) = ^void(RemoteFile *remoteFile, NSArray<RemoteFile *> *remoteFiles, NSError *__nullable error) {
        if (error) {
            // 关闭HUD
            //            [hud hideAnimated:YES];
            // do something?
        } else {
            NSUInteger index = [self.mediaList indexOfObject:remoteFile];
            // 从数组中删除
            [self.mediaList removeObject:remoteFile];
            [self.selectedList removeObjectAtIndex:index];
            // 从GridView中移除已经删除的图片
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            // 更新HUD
            NSUInteger currentNumber = remoteFiles.count;
            NSString *detail = [NSString stringWithFormat:NSLocalizedString(@"DELETE_FORMAT", nil), currentNumber, totalNumber];
            [hud.detailsLabel setText:detail];
        }
    };
    
    // 全部完成Block
    // 关闭HUD，启用返回按键
    BWCompletionBlock completion = ^void(NSError *__nullable error) {
        // 关闭HUD
        [hud hideAnimated:YES];
        // 重新启用返回按键
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    };
    
    // 判断文件类型
    RemoteFile *remoteFile = [files firstObject];
    // 执行删除操作
    if (remoteFile.isVideo) {
        [MediaManager.sharedInstance deleteRemoteVideoFiles:files started:started withSingleCompletion:singleCompletion withCompletion:completion];
    } else {
        [MediaManager.sharedInstance deleteRemoteImageFiles:files started:started withSingleCompletion:singleCompletion withCompletion:completion];
    }
}

#pragma mark - Misc

- (void)resetSelectedList
{
    [self fillSelectedListWith:NO count:self.mediaList.count];
}

- (void)didChangeEditingMode:(BOOL)editing
{
    // 提示信息
    [self.infoLabel setHidden:!editing];
}

- (NSArray<RemoteFile *> *)getSelectedItems
{
    NSMutableArray<RemoteFile *> *array = [NSMutableArray new];
    
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = [self getMargin];
    CGFloat gutter = [self getGutter];
    CGFloat columns = [self getColumns];
    CGFloat width;
    if (@available(iOS 11, *)) {
        width = self.view.safeAreaLayoutGuide.layoutFrame.size.width;
    } else {
        width = self.view.bounds.size.width;
    }
    CGFloat value = floorf(((width - (columns - 1) * gutter - 2 * margin) / columns));
    return CGSizeMake(value, _gridCellHeight);
}

#pragma mark - UICollectionView DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaGridCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        // 选择
        BOOL selected = [[self.selectedList objectAtIndex:indexPath.row] boolValue];
        
//        RemoteFile *remoteFile = [self.mediaList objectAtIndex:indexPath.row];
        
        void (^reverseSelection)(void) = ^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 反选
                [self.selectedList replaceObjectAtIndex:indexPath.row withObject:@(!selected)];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                // 判断全选
                self.allSelected = [self selectedAllMediaFiles];
            });
        };
        
        // 如果之前还没选择，检查对应本地文件状态
//        if (!selected) {
//            // 文件已存在
//            // 目前文件名才用"源文件_文件大小"方式命名，这里会假设所有的文件名都不会一致
//            if (remoteFile.downloaded) {
//                // 弹框
//                NSString *title = NSLocalizedString(@"OVERWRITE_CONFIRM_TITLE", nil);
//                NSString *message = NSLocalizedString(@"OVERWRITE_CONFIRM_MESSAGE", nil);
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//
//                NSString *yesTitle = NSLocalizedString(@"YES", nil);
//                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                    remoteFile.resumeDownload = NO;
//                    // 反选
//                    reverseSelection();
//                }];
//                [alertController addAction:yesAction];
//
//                NSString *noTitle = NSLocalizedString(@"NO", nil);
//                UIAlertAction *noAction = [UIAlertAction actionWithTitle:noTitle style:UIAlertActionStyleCancel handler:nil];
//                [alertController addAction:noAction];
//
//                [self presentViewController:alertController animated:YES completion:nil];
//            }
//            else if (remoteFile.tempExist) {
//                if (remoteFile.localSize < remoteFile.size) {
//                    // 弹框
//                    NSString *title = NSLocalizedString(@"RESUME_CONFIRM_TITLE", nil);
//                    NSString *messageFormat = NSLocalizedString(@"RESUME_CONFIRM_MESSAGE", nil);
//                    NSString *message = [NSString stringWithFormat:messageFormat, [Utilities memoryFormatter:remoteFile.localSize]];
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//
//                    NSString *overwriteTitle = NSLocalizedString(@"YES", nil);
//                    UIAlertAction *overwriteAction = [UIAlertAction actionWithTitle:overwriteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                        remoteFile.resumeDownload = NO;
//                        // 反选
//                        reverseSelection();
//                    }];
//                    [alertController addAction:overwriteAction];
//
//                    NSString *resumeTitle = NSLocalizedString(@"NO", nil);
//                    UIAlertAction *resumeAction = [UIAlertAction actionWithTitle:resumeTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        remoteFile.resumeDownload = YES;
//                        // 反选
//                        reverseSelection();
//                    }];
//                    [alertController addAction:resumeAction];
//
//                    NSString *cancelTitle = NSLocalizedString(@"CANCEL", nil);
//                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
//                    [alertController addAction:cancelAction];
//
//                    [self presentViewController:alertController animated:YES completion:nil];
//                }
//                // 如果大小一样，应该是重命名没有成功
////                else if (remoteFile.localSize == remoteFile.size) {
////
////                }
//            }
//            else {
//                remoteFile.resumeDownload = NO;
//                // 反选
//                reverseSelection();
//            }
//        } else {
//            remoteFile.resumeDownload = NO;
            // 反选
            reverseSelection();
//        }
    }
}

#pragma mark - Media List

- (void)reloadMediaList
{
    // implement in subclass
}

@end
