//
//  VisualStickView.h
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JoyStickView;

@protocol JoyStickViewDelegate

@optional
- (void)joyStickView:(JoyStickView *)joyStickView moveToPoint:(CGPoint)point;

@end

typedef NS_OPTIONS(NSUInteger, JoyStickStyle) {
    JoyStickStylePower,
    JoyStickStyleRanger,
};

@interface JoyStickView : UIView

@property (nonatomic, assign) JoyStickStyle joyStickStyle;
@property (nonatomic, assign) BOOL lockMode;
@property (nonatomic, assign) BOOL trackMode;

@property (nonatomic, weak) id <JoyStickViewDelegate> delegate;

- (void)moveStickTo:(CGPoint)deltaToCenter;

@end
