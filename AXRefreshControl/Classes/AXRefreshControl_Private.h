//
//  AXRefreshControl_Private.h
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/27.
//  Copyright © 2016年 devedbox. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AXRefreshControl.h"
#import <AXIndicatorView/AXActivityIndicatorView.h>

static CGFloat const kAXRefreshControlHeight = 64.0;
static CGFloat const kAXRefreshControlIndicatorSize = 30.0;

static NSTimeInterval const kAXRefreshAnimationDuration = 0.40;

@protocol AXRefreshControlIndicatorDelegate <NSObject>
@required
- (void)beginAnimating;
- (void)endAniamting;
- (void)setNeedsEndAnimating;
- (void)handleRefreshControlStateChanged:(AXRefreshControlState)state transition:(CGFloat)transition;
@end

@interface AXRefreshControlIndicator : AXActivityIndicatorView <AXRefreshControlIndicatorDelegate>
/// Rotating.
@property(assign, nonatomic, getter=isRotating) BOOL rotating;
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
