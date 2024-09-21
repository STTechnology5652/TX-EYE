//
//  MediaGridViewController.m
//  GoTrack
//
//  Created by CoreCat on 2018/11/5.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "MediaGridViewController.h"
#import "UIColor+Theme.h"
#import "PaddingLabel.h"

@import Masonry;

#define TABBAR_HEIGHT_NROMAL 49.0


@interface MediaGridViewController () <UICollectionViewDelegateFlowLayout>
{
    // Store margins for current setup
//    CGFloat _margin, _gutter, _marginL, _gutterL, _columns, _columnsL;
}

@property (strong, nonatomic) UIBarButtonItem *selectButton;

@property (strong, nonatomic) UIView *bottomContainerView;

@end

@implementation MediaGridViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Defaults
        _columns = 3; _columnsL = 5;
        _margin = 0; _gutter = 1;
        _marginL = 0; _gutterL = 2;
        
        CGFloat screenHeight = fmaxf([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // For pixel perfection...
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            _columns = 6; _columnsL = 8;
            _margin = 1; _gutter = 2;
            _marginL = 1; _gutterL = 2;
        } else if (screenHeight == 480) {
            // iPhone 3.5 inch
            _columns = 3; _columnsL = 4;
            _margin = 0; _gutter = 1;
            _marginL = 1; _gutterL = 2;
        } else if (screenHeight == 568) {
            // iPhone 4 inch
            _columns = 3; _columnsL = 5;
            _margin = 0; _gutter = 1;
            _marginL = 0; _gutterL = 2;
        } else if (screenHeight == 667) {
            // iPhone 4.7 inch
            _columns = 3; _columnsL = 5;
            _margin = 0; _gutter = 1;
            _marginL = 0; _gutterL = 2;
        } else {
            // iPhone other size
            _columns = 3; _columnsL = 6;
            _margin = 0; _gutter = 1;
            _marginL = 0; _gutterL = 2;
        }
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBottomView];
    [self setupCollectionView];
    
    [self setupNavigationButton];

    // 用于提示信息
    [self setupInfoLabel];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // 保证横竖屏切换翻转后布局正确
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 保证浏览文件时，切换横竖屏后退出时的布局正确
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 是否从navigationController退出
    if ([self isMovingFromParentViewController]) {
        // 竖屏退出把TabBar显示出来，横屏则隐藏
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.tabBarController.tabBar.hidden = (screenSize.width > screenSize.height);
        // 恢复TabBar的位置
//        [self hideTabBar:NO];
    }
}

#pragma mark - View

- (void)setupCollectionView
{
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:[UICollectionViewFlowLayout new]];
    _collectionView = collectionView;
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView setBackgroundColor:[UIColor themeBackgroundColor]];
    [self.view addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomContainerView.mas_top);
    }];
    
    // UICollectionView没填满也可以下拉
    [collectionView setAlwaysBounceVertical:YES];
    // 适配刘海屏
    if (@available(iOS 11, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    
    [collectionView registerClass:[MediaGridCell class] forCellWithReuseIdentifier:@"MediaGridCell"];
}

- (void)setupBottomView
{
    UIView *bottomContainerView = [[UIView alloc] init];
    _bottomContainerView = bottomContainerView;
    [self.view addSubview:bottomContainerView];
    [bottomContainerView setBackgroundColor:[UIColor themeColor]];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(self.tabBarController ? self.tabBarController.tabBar.bounds.size.height : TABBAR_HEIGHT_NROMAL);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    [self.bottomContainerView addSubview:bottomView];
    [bottomView setBackgroundColor:[UIColor themeColor]];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.and.right.equalTo(self.bottomContainerView);
        make.height.mas_equalTo(TABBAR_HEIGHT_NROMAL);
    }];
    [bottomView setUserInteractionEnabled:NO];
}

- (void)hideBottomView:(BOOL)hide
{
    [self.bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (hide) {
            make.top.equalTo(self.view.mas_bottom);
        } else {
            make.bottom.equalTo(self.view);
        }
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(self.tabBarController ? self.tabBarController.tabBar.bounds.size.height : TABBAR_HEIGHT_NROMAL);
    }];
}

- (void)hideTabBar:(BOOL)hide
{
    [self hideTabBar:hide animated:YES completion:nil];
}

- (void)hideTabBar:(BOOL)hide animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion
{
    void (^doBlock)(void) = ^() {
        CGRect tabBarFrame = self.tabBarController.tabBar.frame;
        if (hide) {
            tabBarFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
        } else {
            tabBarFrame.origin.y = [UIScreen mainScreen].bounds.size.height - tabBarFrame.size.height;
        }
        self.tabBarController.tabBar.frame = tabBarFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:doBlock completion:completion];
    } else {
        doBlock();
        if (completion)
            completion(YES);
    }
}


- (void)setupInfoLabel
{
    PaddingLabel *infoLabel = [[PaddingLabel alloc] init];
    _infoLabel = infoLabel;
    [infoLabel setEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [infoLabel setBackgroundColor:[UIColor themeColor]];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoLabel setAlpha:0.6];
    [infoLabel setNumberOfLines:0];
    [self.view addSubview:infoLabel];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top).with.offset(-0.5);
        make.width.lessThanOrEqualTo(self.view);
    }];
    
    // 信息暂时不会变，在这里定义
    [infoLabel setText:NSLocalizedString(@"INFO_FOR_DOWNLOADED", nil)];
    
    // 默认隐藏
    [infoLabel setHidden:YES];
}

#pragma mark - Misc

- (void)resetSelectedList
{
    // Implement in subclass
}

- (void)didChangeEditingMode:(BOOL)editing
{
    // Implement in subclass
}

- (void)openEditingMode:(BOOL)editing
{
    self.editing = editing;
    
    _selectionMode = editing;
    [self resetSelectedList];
    [self.collectionView reloadData];
    
    [self didChangeEditingMode:editing];
    
    // 非选择状态，重置全选
    if (!editing) {
        _allSelected = NO;
    }
    
    // Change select button image, according to the status of editing
//    [self.selectButton setImage:[UIImage imageNamed:editing ? @"media_cancel" : @"media_select"]];
    [self.selectButton setTitle:editing ? NSLocalizedString(@"CANCEL", nil) : NSLocalizedString(@"SELECT", nil)];
    
    [self.bottomView setUserInteractionEnabled:editing];
    
//    // TODO: 替换横屏语句
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//
//    BOOL animated;
//    void (^completion)(BOOL);
//    // 横屏
//    if (screenSize.width > screenSize.height) {
        // 根据编辑状态立即显示/隐藏bottomView
        [self hideBottomView:!editing];
//        animated = NO;
//        completion = nil;
//    }
//    // 竖屏
//    else {
//        // 编辑状态，立即隐藏bottomView
//        if (editing) {
//            [self hideBottomView:NO];
//        }
//        animated = YES;
//        // 禁用选择按键，直到动画完成
//        self.selectButton.enabled = NO;
//        // 事情处理完成后执行
//        completion = ^(BOOL finished) {
//            // 非编辑状态，隐藏bottomView
//            if (!editing) {
//                [self hideBottomView:YES];
//            }
//            // 启用选择按键
//            self.selectButton.enabled = YES;
//        };
//    }
//    // 根据编辑状态显示/隐藏tabBar
//    [self hideTabBar:editing animated:animated completion:completion];
}

#pragma mark - Buttons

- (void)setupNavigationButton
{
//    _selectButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"media_select"]
//                                                     style:UIBarButtonItemStylePlain
//                                                    target:self
//                                                    action:@selector(tapSelectButton:)];
    _selectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SELECT", nil)
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(tapSelectButton:)];
    self.navigationItem.rightBarButtonItem = _selectButton;
}

- (void)tapSelectButton:(id)sender
{
    BOOL isEditing = self.isEditing;
    [self openEditingMode:!isEditing];
}

#pragma mark - Layout

- (CGFloat)getColumns
{
    if ((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))) {
        return _columns;
    } else {
        return _columnsL;
    }
}

- (CGFloat)getMargin
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return _margin;
    } else {
        return _marginL;
    }
}

- (CGFloat)getGutter
{
    if ((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))) {
        return _gutter;
    } else {
        return _gutterL;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = [self getMargin];
    CGFloat gutter = [self getGutter];
    CGFloat columns = [self getColumns];
    CGFloat value = floorf(((self.view.bounds.size.width - (columns - 1) * gutter - 2 * margin) / columns));
    return CGSizeMake(value, value);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self getGutter];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self getGutter];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat margin = [self getMargin];
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}

#pragma mark - UICollectionView DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaGridCell" forIndexPath:indexPath];
    
    // Implement in subclass
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;   // Implement in subclass
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Implement in subclass
}

#pragma mark - Misc

- (void)fillSelectedListWith:(BOOL)bValue count:(NSUInteger)length
{
    self.selectedList = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < length; i++) {
        [self.selectedList addObject:@(bValue)];
    }
}

@end
