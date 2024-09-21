//
//  HTrimView.h
//  TX-EYE
//
//  Created by CoreCat on 16/1/18.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTrimView;

@protocol HTrimViewDelegate

@optional
- (void)hTrimView:(HTrimView *)hTrimView valueChanged:(float)value;

@end

@interface HTrimView : UIView
@property (nonatomic, assign) SInt32 scaleNum;
@property (nonatomic, assign) SInt32 scaleValue;
@property (nonatomic, readonly) float value;

@property (nonatomic, weak) id <HTrimViewDelegate> delegate;

@end
