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

static NSTimeInterval const kAXRefreshAnimationDuration = 0.40;

@interface AXRefreshControlIndicator : UIView <AXRefreshControlIndicatorDelegate>
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
/// Animated duration per cycle. Default is 1.6;
@property(assign, nonatomic) NSTimeInterval rotateDuration;
/// Need end animating.
@property(assign, nonatomic) BOOL neededEndAnimating;
/// Animated to rotate the indicator.
- (void)rotateWithRepeat:(int64_t)repeat reverse:(BOOL)reverse duration:(NSTimeInterval)duration;
/// Begin animating.
- (void)beginAnimating;
/// End animating.
- (void)endAniamting;
/// Wait to end animating.
- (void)setNeedsEndAnimating;
/// End animating if needed.
- (void)endAniamtingInNeeded;
@end

@interface AXRefreshControl ()
@property(strong, nonatomic) NSDate *reachedDate;
/// Refresh indicator. Get the indicator with default width and height 30.0.
@property(readonly, strong, nonatomic) AXRefreshControlIndicator *refreshIndicator;
/// Scorll view.
@property(weak, nonatomic) UIScrollView *scrollView;
/// Handle scroll vuew did scroll.
- (void)handleScrollViewDidScroll:(UIScrollView *)scrollView;
/// Handle scroll view will begin dragging.
- (void)handleScrollViewWillBeginDragging:(UIScrollView *)scrollView;
/// Handle scroll view did end dragging.
- (void)handleScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
/// Handle scroll view did end decelerating.
- (void)handlescrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end

@interface UIScrollView ()
/// Original content inset.
@property(assign, nonatomic) UIEdgeInsets originalInset;
/// Is ending animating.
@property(assign, nonatomic, getter=isAnimatingContentInset) BOOL animatingContentInset;
@end
