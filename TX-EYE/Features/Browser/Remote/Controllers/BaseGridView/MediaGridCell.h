//
//  MediaGridCell.h
//  GoTrack
//
//  Created by CoreCat on 2018/11/5.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaGridCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic) NSUInteger index;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isDownloaded;

@end

NS_ASSUME_NONNULL_END
