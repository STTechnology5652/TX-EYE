//
//  TrackCanvasView.h
//  TX-EYE
//
//  Created by CoreCat on 2017/1/12.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchPoint.h"

@class TrackCanvasView;

@protocol TrackCanvasViewDelegate

@optional
- (void)trackCanvasViewWillDraw:(TrackCanvasView *)canvasView;
- (void)trackCanvasView:(TrackCanvasView *)canvasView drawnPoints:(NSArray<TouchPoint *> *)points;

@end

@interface TrackCanvasView : UIView
@property (nonatomic, weak) id<TrackCanvasViewDelegate> delegate;
- (void)reset;
@end
