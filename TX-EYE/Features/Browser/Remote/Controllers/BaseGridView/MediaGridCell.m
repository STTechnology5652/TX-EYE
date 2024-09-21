//
//  MediaGridCell.m
//  GoTrack
//
//  Created by CoreCat on 2018/11/5.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import "MediaGridCell.h"

@import Masonry;

@interface MediaGridCell ()
{
//    UIImageView *_imageView;
//    UIImageView *_videoIndicator;
    UIButton *_selectedButton;
    UIImageView *_downloadedView;
}

@end

@implementation MediaGridCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Image
        _imageView = [UIImageView new];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
        
        _nameLabel = [UILabel new];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(4);
            make.right.equalTo(self).with.offset(-4);
            make.centerY.equalTo(self);
        }];
        
        // Selection button
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.contentMode = UIViewContentModeTopRight;
        _selectedButton.adjustsImageWhenHighlighted = NO;
        [_selectedButton setImage:[UIImage imageNamed:@"ImageSelectedSmallOff"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"ImageSelectedSmallOn"] forState:UIControlStateSelected];
        [_selectedButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchDown];
        _selectedButton.hidden = YES;
//        _selectedButton.frame = CGRectMake(0, 0, 44, 44);
        [_selectedButton sizeToFit];
        [self addSubview:_selectedButton];
        
        // Downloaded ImageView
        _downloadedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_downloaded"]];
        [_downloadedView sizeToFit];
        _downloadedView.contentMode = UIViewContentModeBottomRight;
        _downloadedView.hidden = YES;
        [self addSubview:_downloadedView];
        
        // 因为没设回调，所以禁用掉，点Cell的时候可以穿透
        _selectedButton.userInteractionEnabled = NO;
        _downloadedView.userInteractionEnabled = NO;
    }
    return self;
}

#pragma makr - View

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width - 4,
                                       4, _selectedButton.frame.size.width, _selectedButton.frame.size.height);
    _downloadedView.frame = CGRectMake(self.bounds.size.width - _downloadedView.frame.size.width - 4,
                                       self.bounds.size.height - _downloadedView.frame.size.height - 4,
                                       _downloadedView.frame.size.width, _downloadedView.frame.size.height);
}

#pragma mark - Cell

- (void)prepareForReuse {
    _imageView.image = nil;
    _selectedButton.hidden = YES;
    [super prepareForReuse];
}

#pragma mark - Selection

- (void)setSelectionMode:(BOOL)selectionMode {
    _selectionMode = selectionMode;
    [_selectedButton setHidden:!selectionMode];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _selectedButton.selected = isSelected;
}

- (void)selectionButtonPressed {
    _selectedButton.selected = !_selectedButton.selected;
}

#pragma mark - Downloaded

- (void)setIsDownloaded:(BOOL)isDownloaded
{
    _isDownloaded = isDownloaded;
    
    _downloadedView.hidden = !isDownloaded;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 0.6;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesCancelled:touches withEvent:event];
}

@end
