//
//  TrackView.h
//  TX-EYE
//
//  Created by CoreCat on 2017/1/3.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrackView;

@protocol TrackViewDelegate

@optional
- (void)trackViewBeginOutput:(TrackView *)trackView;
- (void)trackView:(TrackView *)trackView outputPoint:(CGPoint)point;    // ([-1, 1], [-1, 1])
- (void)trackViewFinishOutput:(TrackView *)trackView;

@end

@interface TrackView : UIView
@property (nonatomic, weak) id<TrackViewDelegate> delegate;
@property (nonatomic, assign) int speedLevel;
- (void)reset;
@end
