//
//  MediaLibraryManagerViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/27.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "MediaLibraryManagerViewController.h"
#import "Utilities.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@import Masonry;

@interface MediaLibraryManagerViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *selectAllButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign, getter=isDeletingMode) BOOL deletingMode;
@property (nonatomic, strong) UILabel *selectionLabel;
@property (nonatomic, assign) BOOL selectedAll;
@end

@implementation MediaLibraryManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化控件
    [self initControls];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 重新载入媒体列表
    [self reloadListData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // avoid memory leak
    [self.tableView setEditing:NO animated:NO];
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
 *  删除界面
 *
 *  @param deletingMode 进入删除界面开关
 */
- (void)setDeletingMode:(BOOL)deletingMode
{
    _deletingMode = deletingMode;

    [self.tableView setEditing:deletingMode animated:YES];

    [_selectAllButton setHidden:!deletingMode];
    [_deleteButton setHidden:!deletingMode];
    [_selectionLabel setHidden:!deletingMode];

    [self updateSelectedCellNumber];

    // Change select button image, according to the status of editing
    [self.selectButton setImage:[UIImage imageNamed:deletingMode ? @"media_cancel" : @"media_select"] forState:UIControlStateNormal];
}

/**
 *  是否已经选择所有文件
 */
- (BOOL)selectedAll
{
    return [self.tableView indexPathsForSelectedRows].count == [self totalItemNumber];
}

/**
 *  全部Item数
 */
- (NSUInteger)totalItemNumber
{
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < self.listItems.count; i++) {
        NSDictionary *dict = self.listItems[i];
        NSArray *array = dict[@"FileItems"];
        count += array.count;
    }
    return count;
}

/**
 *  初始化控件
 */
- (void)initControls
{
    // 配置Top Container
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:150.0/255.0 blue:254.0/255.0 alpha:1.0];
    [self.view addSubview:_topView];

    // 配置后退按键
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_returnButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [_returnButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_returnButton];

    // 配置选择按键
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectButton setImage:[UIImage imageNamed:@"media_select"] forState:UIControlStateNormal];
    [_selectButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_selectButton];

    // 配置全选按键
    _selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectAllButton setImage:[UIImage imageNamed:@"media_selectall_h"] forState:UIControlStateNormal];
    [_selectAllButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_selectAllButton];
    // Hidden
    [_selectAllButton setHidden:YES];

    // 配置删除按键
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"media_delete"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_deleteButton];
    // Hidden
    [_deleteButton setHidden:YES];

    // 选择数Label
    _selectionLabel = [[UILabel alloc] init];
    [_selectionLabel setTextColor:[UIColor whiteColor]];
    [_topView addSubview:_selectionLabel];
    // Hidden
    [_selectionLabel setHidden:YES];

    // 配置列表
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

    // 布局约束
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(self.view);
        make.height.mas_equalTo(40.0);
    }];
    [_returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.centerY.equalTo(_topView);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(_topView.mas_safeAreaLayoutGuideLeft).with.offset(8.0);
        } else {
            make.left.mas_equalTo(8.0);
        }
    }];
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.centerY.equalTo(_topView);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(_topView.mas_safeAreaLayoutGuideRight).with.offset(-8.0);
        } else {
            make.right.equalTo(_topView).with.offset(-8.0);
        }
    }];
    [_selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.centerY.equalTo(_topView);
        make.right.equalTo(_selectButton.mas_left).with.offset(-6.0);
    }];
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.centerY.equalTo(_topView);
        make.right.equalTo(_selectAllButton.mas_left).with.offset(-6.0);
    }];
    [_selectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.equalTo(_topView);
    }];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom);
        make.left.bottom.and.right.equalTo(self.view);
    }];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // 删除键
    else if (button == self.deleteButton) {
        [self deleteSelectedFiles];
    }
    // 选择键
    else if (button == self.selectButton) {
        self.deletingMode = !self.isDeletingMode;
    }
    // 全选键
    else if (button == self.selectAllButton) {
        if (self.selectedAll) {
            [self deselectAllRows];
        } else {
            [self selectAllRows];
        }
        // 更新显示选择的文件数
        [self updateSelectedCellNumber];
    }
}

/**
 *  选择所有行
 */
- (void)selectAllRows
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

/**
 *  取消选择所有行
 */
- (void)deselectAllRows
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO];
        }
    }
}

/**
 *  删除已选择的文件
 */
- (void)deleteSelectedFiles
{
    // 已选择文件数组
    NSArray *selectedCells = [self.tableView indexPathsForSelectedRows];
    // 如果选择数不为0
    if (selectedCells.count != 0) {
        // 显示删除警告
        NSString *title = NSLocalizedString(@"MEDIA_ALERT_TITLE", @"MediaLib ALERT title");
        NSString *message = NSLocalizedString(@"MEDIA_ALERT_MESSAGE", @"MediaLib ALERT message");
        NSString *noActionTitle = NSLocalizedString(@"MEDIA_ALERT_BUTTON_NO", @"MediaLib ALERT button no");
        NSString *yesActionTitle = NSLocalizedString(@"MEDIA_ALERT_BUTTON_YES", @"MediaLib ALERT button yes");
        // 根据系统版本选择不同的Alert类
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
            // 使用UIAlertController
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:noActionTitle style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self doDeleteCells:selectedCells];
            }];
            [alertController addAction:noAction];
            [alertController addAction:yesAction];
            [self showViewController:alertController sender:nil];
        } else {
            // 使用UIAlertView
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:noActionTitle otherButtonTitles:yesActionTitle, nil];
            [alertView show];
        }
    }
}

/**
 *  UIAlertView Delegate
 *
 *  @param alertView   实例
 *  @param buttonIndex 按键索引
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // yes???
        [self doDeleteCells:[self.tableView indexPathsForSelectedRows]];
    }
}

/**
 *  执行删除
 *
 *  @param cells 需要删除的文件数组
 */
- (void)doDeleteCells:(NSArray *)cells
{
    // delete files
    for (NSIndexPath *indexPath in cells) {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        // 删除文件，如果目录为空，亦删除
        NSString *dirName = self.listItems[section][@"DirName"];
        NSString *fileName = self.listItems[section][@"FileItems"][row][@"FileName"];
        [Utilities removeFile:fileName inDocumentDir:dirName];
    }
    // 删除后重新载入列表
    [self reloadListData];
    // 更新选择的文件数
    [self updateSelectedCellNumber];
}

/**
 *  更新显示选择的文件数
 */
- (void)updateSelectedCellNumber
{
    // 暂时这样，以后改类
    NSUInteger totalCount = 0;
    for (NSUInteger i = 0; i < [_listItems count]; i++) {
        NSArray *fileItems = _listItems[i][@"FileItems"];
        totalCount += fileItems.count;
    }

    NSArray *selectedCells = [_tableView indexPathsForSelectedRows];
    NSUInteger selectedCellCount = selectedCells.count;

    NSString *selectionLabelText = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)selectedCellCount, (unsigned long)totalCount];
    [_selectionLabel setText:selectionLabelText];
    
    // 更新selectAll按键状态
    [_selectAllButton setImage:[UIImage imageNamed:self.selectedAll ? @"media_selectall" : @"media_selectall_h"] forState:UIControlStateNormal];
}

/**
 *  重新载入列表，在子类中实现
 */
- (void)reloadListData
{
    // implement in subclass
}

/**
 *  展示媒体，在子类中实现
 *
 *  @param indexPath 媒体文件索引
 */
- (void)displayMediaAtIndexPath:(NSIndexPath *)indexPath
{
    // implement in subclass
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.listItems[section][@"DirName"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listItems[section][@"FileItems"] count];
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];  // 在子类中Override
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isDeletingMode) {
        // 更新显示选择的文件数
        [self updateSelectedCellNumber];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // show photo or video
        [self displayMediaAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isDeletingMode) {
        // 更新显示选择的文件数
        [self updateSelectedCellNumber];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 3;   // Not public，SDK中不存在此枚举数，用这种类型可以更直观的表示Cell是否被选择
}

#pragma mark - Permission

- (void)requestPhotoAccessAuthorization:(void (^)(BOOL success))handler
{
    // TODO: new API above iOS 10.0
    if (@available(iOS 8.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                handler(NO);
            } else {
                handler(YES);
            }
        }];
    } else {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        if (status != ALAuthorizationStatusAuthorized) {
            handler(NO);
        } else {
            handler(YES);
        }
    }
}

@end
