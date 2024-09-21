//
//  HelpPageViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/20.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "HelpPageViewController.h"
#import "Masonry.h"

@interface HelpPageViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *prevPageButton;
@property (nonatomic, strong) UIButton *nextPageButton;
@property (nonatomic, strong) NSArray *helpPages;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation HelpPageViewController
{
    UIImageView *currentPageImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色为白色
    self.view.backgroundColor = [UIColor colorWithRed:13/255. green:98/255. blue:179/255. alpha:1.0];
    
    // 配置帮助页
    [self initHelpPages];
    
    // 初始化按键
    [self initButtons];
    
    // 更新按键状态
    [self updateButtonsStatus];
}

/**
 *  初始化帮助页面
 */
- (void)initHelpPages
{
    // 帮助页数组（需要显示的帮助页可以放在这里！）
    self.helpPages = @[
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page_0"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page_1"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page_2"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page_3"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page_4"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page_5"]],
                       ];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    // 配置scrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollView.contentSize = CGSizeMake(screenSize.width * self.helpPages.count, screenSize.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    for (UIImageView *imageView in self.helpPages) {
        NSUInteger index = [self.helpPages indexOfObject:imageView];
        imageView.frame = CGRectMake(index * screenSize.width, 0, screenSize.width, screenSize.height);
        [self.scrollView addSubview:imageView];
    }
    
    // 配置pageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    self.pageControl.numberOfPages = self.helpPages.count;
    self.pageControl.hidden = YES;
    [self.view addSubview:self.pageControl];
}

/**
 *  初始化按键
 */
- (void)initButtons
{
    // 配置返回按键
    self.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.returnButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [self.returnButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.returnButton];
    
    // 配置上一页按键
    self.prevPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.prevPageButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [self.prevPageButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.prevPageButton];
    
    // 配置下一页按键
    self.nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextPageButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [self.nextPageButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextPageButton];

    // 布局约束
    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).with.offset(8.0);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).with.offset(8.0);
        } else {
            make.top.equalTo(self.view).with.offset(8.0);
            make.left.equalTo(self.view).with.offset(8.0);
        }
    }];
    [self.prevPageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).with.offset(5.0);
        } else {
            make.left.equalTo(self.view).with.offset(5.0);
        }
    }];
    [self.nextPageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).with.offset(-5.0);
        } else {
            make.right.equalTo(self.view).with.offset(-5.0);
        }
    }];
}

/**
 *  触摸按键入口
 *
 *  @param button 按键
 */
- (void)tapButton:(UIButton *)button
{
    // 返回按键
    if (button == self.returnButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // 翻页键，pageControl自动检查越界
    else {
        NSInteger page = self.pageControl.currentPage;
        // 上一页
        if (button == self.prevPageButton) {
            page--;
        }
        // 下一页
        else if (button == self.nextPageButton) {
            page++;
        }
        self.pageControl.currentPage = page;
        [self.scrollView setContentOffset:CGPointMake(page * [[UIScreen mainScreen] bounds].size.width, 0) animated:YES];
    }
}

/**
 *  更新按键状态
 *  第一页不显示上一页，最后一页不显示下一页
 */
- (void)updateButtonsStatus
{
    self.prevPageButton.hidden = self.pageControl.currentPage == 0;
    self.nextPageButton.hidden = self.pageControl.currentPage == self.helpPages.count - 1;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 根据滑动屏幕的位置显示不同的帮助页
    NSInteger page = scrollView.contentOffset.x / [[UIScreen mainScreen] bounds].size.width;
    self.pageControl.currentPage = page;
    [self updateButtonsStatus];
}

@end
