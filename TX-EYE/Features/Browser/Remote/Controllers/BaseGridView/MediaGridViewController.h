//
//  MediaGridViewController.h
//  GoTrack
//
//  Created by CoreCat on 2018/11/5.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "BaseViewController.h"
#import "MediaGridCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaGridViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

// Store margins for current setup
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat gutter;
@property (nonatomic, assign) CGFloat marginL;
@property (nonatomic, assign) CGFloat gutterL;
@property (nonatomic, assign) CGFloat columns;
@property (nonatomic, assign) CGFloat columnsL;

- (CGFloat)getColumns;
- (CGFloat)getMargin;
- (CGFloat)getGutter;


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, getter=isEditing) BOOL editing;

- (void)hideBottomView:(BOOL)hide;

- (void)hideTabBar:(BOOL)hide;
- (void)hideTabBar:(BOOL)hide animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;

// 选择
@property (nonatomic, assign) BOOL selectionMode;
@property (nonatomic, strong) NSMutableArray *selectedList;

@property (nonatomic, assign) BOOL allSelected;

- (void)resetSelectedList;

- (void)didChangeEditingMode:(BOOL)editing;

// 填充选择列表
- (void)fillSelectedListWith:(BOOL)bValue count:(NSUInteger)length;

// 信息显示
@property (strong, nonatomic) UILabel *infoLabel;

@end

NS_ASSUME_NONNULL_END
