//
//  AXRefreshControl_Private.h
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/27.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXRefreshControl.h"

static CGFloat const kAXRefreshControlHeight = 64.0;
static CGFloat const kAXRefreshControlIndicatorSize = 30.0;

@interface AXRefreshControlIndicator : UIView
/// Line width.
@property(assign, nonatomic) CGFloat lineWidth;
/// Drawing percent of the components.
@property(assign, nonatomic) int64_t drawingComponents;
/// Animating.
@property(assign, nonatomic, getter=isAnimating) BOOL animating;
/// Rotating.
@property(assign, nonatomic, getter=isRotating) BOOL rotating;
/// Animated color index.
@property(assign, nonatomic) int64_t animatedColorIndex;
/// Rotate offset. Default is 0.0;
@property(assign, nonatomic) CGFloat rotateOffset;
/// Animated duration per cycle. Default is 0.8;
@property(assign, nonatomic) NSTimeInterval colorDuration;
/// Animated duration per cycle. Default is 1.6;
@property(assign, nonatomic) NSTimeInterval rotateDuration;
/// Animated to rotate the indicator.
- (void)rotateWithRepeat:(int64_t)repeat reverse:(BOOL)reverse duration:(NSTimeInterval)duration;
/// Begin animating.
- (void)beginAnimating;
/// End animating.
- (void)endAniamting;
@end

@interface AXRefreshControl ()
/// Refresh indicator. Get the indicator with default width and height 30.0.
@property(readonly, strong, nonatomic) AXRefreshControlIndicator *refreshIndicator;
/// Scorll view.
@property(weak, nonatomic) UIScrollView *scrollView;
@end

@class _AXScrollViewObserverableManager;

@interface UIScrollView ()
/// Observerable manager.
@property(strong, nonatomic) _AXScrollViewObserverableManager *observeManager;
/// Original content inset.
@property(assign, nonatomic) UIEdgeInsets originalInset;
@end
