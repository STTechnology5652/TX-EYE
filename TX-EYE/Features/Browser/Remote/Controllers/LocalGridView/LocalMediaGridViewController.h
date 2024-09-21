//
//  LocalMediaGridViewController.h
//  GoTrack
//
//  Created by CoreCat on 2018/11/6.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "MediaGridViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalMediaGridViewController : MediaGridViewController

@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *selectAllButton;

@property (nonatomic, strong) NSMutableArray *mediaList;

// 重新载入媒体列表
- (void)reloadMediaList;

@end

NS_ASSUME_NONNULL_END
