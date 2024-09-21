//
//  VTrimView.h
//  TX-EYE
//
//  Created by CoreCat on 16/1/18.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VTrimView;

@protocol VTrimViewDelegate

@optional
- (void)vTrimView:(VTrimView *)vTrimView valueChanged:(float)value;

@end

@interface VTrimView : UIView
@property (nonatomic, assign) SInt32 scaleNum;
@property (nonatomic, assign) SInt32 scaleValue;
@property (nonatomic, readonly) float value;

@property (nonatomic, weak) id <VTrimViewDelegate> delegate;

@end
