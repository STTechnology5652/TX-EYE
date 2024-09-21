//
//  CountdownLabel.h
//  TX-EYE
//
//  Created by CoreCat on 2018/9/19.
//  Copyright © 2018年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CountdownLabel;

@protocol CountdownLabelDelegate <NSObject>

@optional
- (void)countdownEnded:(CountdownLabel *)cdLabel;

@end

@interface CountdownLabel : UILabel

@property (nonatomic, weak) id<CountdownLabelDelegate> delegate;

//开始倒计时时间
@property (nonatomic, assign) int count;

@property (nonatomic, assign) BOOL isCountingDown;

- (instancetype)initWithFrame:(CGRect)frame;

//执行这个方法开始倒计时
- (void)startCount;

@end
