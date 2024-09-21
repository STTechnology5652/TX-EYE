//
//  RudderView.h
//  TX-EYE
//
//  Created by CoreCat on 16/1/15.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RudderView;

@protocol RudderViewDelegate

@optional
// “-”代表水平方向，“|”代表垂直方向，“+”代表水平和垂直方向，“[]”内表示输出值范围
// Trim Value
- (void)rudderView:(RudderView *)rudderView hTrimValueChanged:(float)value;     // -, [-1.0, 1.0]
- (void)rudderView:(RudderView *)rudderView vTrimValueChanged:(float)value;     // |, [-1.0, 1.0]
- (void)rudderView:(RudderView *)rudderView trimPointMovedTo:(CGPoint)point;    // +, ([-1.0, 1.0], [-1.0, 1.0])
// Base Value
- (void)rudderView:(RudderView *)rudderView hBaseValueChanged:(float)value;     // -, [-1.0, 1.0]
- (void)rudderView:(RudderView *)rudderView vBaseValueChanged:(float)value;     // |, [-1.0, 1.0]
- (void)rudderView:(RudderView *)rudderView basePointMovedTo:(CGPoint)point;    // +, ([-1.0, 1.0], [-1.0, 1.0])

@end

typedef NS_OPTIONS(NSUInteger, RudderStyle) {
    RudderStylePower,
    RudderStyleRanger,
};

@interface RudderView : UIView

@property (nonatomic, weak) id <RudderViewDelegate> delegate;

@property (nonatomic, assign) RudderStyle rudderStyle;
@property (nonatomic, assign) BOOL useGravity;
@property (nonatomic, assign) UIDeviceOrientation orientation;

@property (nonatomic, readonly) CGPoint basePoint;
@property (nonatomic, readonly) CGPoint trimPoint;

@property (class, nonatomic, readonly) SInt32 hScaleNum;
@property (class, nonatomic, readonly) SInt32 vScaleNum;

- (void)lockToHalfPowerMode;  // Only work in RudderStylePower
- (void)unlockHalfPowerMode;  // Only work in RudderStylePower

- (void)reset;

- (void)moveStickTo:(CGPoint)deltaToCenter;

@end
