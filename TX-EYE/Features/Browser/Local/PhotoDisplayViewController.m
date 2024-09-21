//
//  PhotoDisplayViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/28.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "PhotoDisplayViewController.h"

@import Masonry;

@interface PhotoDisplayViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *returnButton;
@end

@implementation PhotoDisplayViewController

- (void)setImageFilePath:(NSString *)imageFilePath
{
    _imageFilePath = imageFilePath;
    // 载入图像到内存
    _image = [UIImage imageWithContentsOfFile:_imageFilePath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色为黑色
    self.view.backgroundColor = [UIColor blackColor];
    
    // 如果image为非空，则开始初始化显示
    if (self.image) {
        [self initDisplayControl];
    }
    
    // 初始化按键
    [self initButtons];
    
    // 双击手势识别
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
}

/**
 *  初始化显示控件
 */
- (void)initDisplayControl
{
    // 设置imageView
    _imageView = [[UIImageView alloc] initWithImage:self.image];
    [_imageView setUserInteractionEnabled:YES];
    [_imageView setBackgroundColor:[UIColor clearColor]];
    [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_imageView setFrame:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];

    // 设置scrollView样式等
    _scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [_scrollView setScrollEnabled:YES];
    [_scrollView setClipsToBounds:YES];
    [_scrollView setBounces:YES];
    [_scrollView addSubview:_imageView];
    [_scrollView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_scrollView];
    // 设置scrollView的ContentSize，并根据图像大小设置缩放
    [_scrollView setContentSize:self.image.size];
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = MIN(minScale, 1.0f);
    self.scrollView.maximumZoomScale = MAX(minScale, 2.0f);
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

/**
 *  初始化按键
 */
- (void)initButtons
{
    // 设置返回键
    self.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.returnButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [self.returnButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.returnButton];

    // 布局约束
    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.top.and.left.mas_equalTo(0);
    }];
}

/**
 *  按下按键
 *
 *  @param button 按键
 */
- (void)tapButton:(UIButton *)button
{
    // Backing Button
    if (button == self.returnButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 *  配置图像位置在中间
 */
- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - UIScrollView Delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

#pragma mark - Gesture

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    // 根据当前的图像缩放选择全尺寸缩放或者适当缩放
    CGFloat zoomScale = self.scrollView.zoomScale;
    
    if (fabs(zoomScale - 1.0) < 0.000001) {
        CGRect scrollViewFrame = self.scrollView.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        zoomScale = MIN(scaleWidth, scaleHeight);
    } else {
        zoomScale = 1.0f;
    }
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / zoomScale;
    CGFloat h = scrollViewSize.height / zoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

@end
