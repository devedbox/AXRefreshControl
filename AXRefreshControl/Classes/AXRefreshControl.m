//
//  AXRefreshControl.m
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
#import "AXRefreshControl_Private.h"
#import "UIScrollView+Refreshable.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>

#ifndef __IPHONE_10_0
#define __IPHONE_10_0 100000
#endif
#ifndef kCFCoreFoundationVersionNumber_iOS_9_4
#define kCFCoreFoundationVersionNumber_iOS_9_4 1280.38
#endif
#pragma mark - AXRefreshControl
@implementation AXRefreshControl
@synthesize refreshIndicator = _refreshIndicator;
#pragma mark - Initializer
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    [self addSubview:self.refreshIndicator];
    // Set default values.
    _soundInteractive = YES;
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    // Place the indicator view in the center of refresh control.
    _refreshIndicator.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        [self setFrame:CGRectMake(0, 0, CGRectGetWidth(newSuperview.frame), kAXRefreshControlHeight)];
        [self layoutSubviews];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    self.refreshIndicator.tintColor = tintColor;
}

#pragma mark - Getters
- (BOOL)isRefreshing {
    return self.refreshIndicator.isAnimating;
}

- (AXRefreshControlIndicator *)refreshIndicator {
    if (_refreshIndicator) return _refreshIndicator;
    _refreshIndicator = [[AXRefreshControlIndicator alloc] initWithFrame:CGRectMake(0, 0, kAXRefreshControlIndicatorSize, kAXRefreshControlIndicatorSize)];
    [_refreshIndicator setCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)];
    _refreshIndicator.backgroundColor = [UIColor clearColor];
    return _refreshIndicator;
}

#pragma mark - Public
- (void)beginRefreshing {
    // Begin refresh indicator animation.
    [self.refreshIndicator beginAnimating];
    // Scroll view begin refreshing.
    if (_scrollView) [_scrollView beginRefreshing];
    // Send actions to targets.
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)endRefreshing {
    // If scroll view is dragging, set state to Pending and handle the Pending state.
    if (_scrollView.isDragging) {
        [self setRefreshState:AXRefreshControlStatePending];
        [self handlePendingStateWithContentOffset:CGPointMake(0, _scrollView.contentOffset.y + _scrollView.contentInset.top)];
    } else {
        // End refreshing animation.
        [self.refreshIndicator endAniamting];
        // Set state of refresh control to reached.
        [self setRefreshState:AXRefreshControlStateReached];
        // Scroll view end refreshing.
        if (_scrollView) [_scrollView endRefreshing];
        // Send actions to targets.
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)handleScrollViewDidScroll:(UIScrollView *)scrollView {// Any offset changed.
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y+=_scrollView.originalInset.top;
    
    // Add the refresh control to scroll view.
    if (!self.superview) {
        if (_scrollView) [_scrollView insertSubview:self atIndex:0];
    }
    [self setHidden:NO];

    // Update the frame of refresh control.
    [self setFrame:CGRectMake(0, MIN(contentOffset.y, 0), CGRectGetWidth(_scrollView.frame), MAX(-contentOffset.y, kAXRefreshControlHeight))];
    
    switch (_refreshState) {
        case AXRefreshControlStateTransiting:
            [self handleTransitingStateWithContentOffset:contentOffset];
            if (-contentOffset.y >= kAXRefreshControlHeight) {
                [self setRefreshState:AXRefreshControlStateReached];
                [self handleReachedStateWithContentOffset:contentOffset];
            }
            break;
        case AXRefreshControlStateReached: {
            if (-contentOffset.y < kAXRefreshControlHeight) {
                [self setRefreshState:AXRefreshControlStateTransiting];
            }
        }
            break;
        case AXRefreshControlStateReleased:
            [self handleReleasedStateWithContentOffset:contentOffset];
            [self setRefreshState:AXRefreshControlStateRefreshing];
            break;
        case AXRefreshControlStateRefreshing:
            [self handleRefreshingStateWithContentOffset:contentOffset];
            break;
        case AXRefreshControlStatePending:
            [self handlePendingStateWithContentOffset:contentOffset];
            break;
        default:
            [self handleNormalStateWithContentOffset:contentOffset];
            if (contentOffset.y < 0 && -contentOffset.y < kAXRefreshControlHeight) {
                [self setRefreshState:AXRefreshControlStateTransiting];
            }
            break;
    }
    
    if (contentOffset.y >= 0 && _refreshState != AXRefreshControlStateRefreshing && _refreshState != AXRefreshControlStatePending) {
        [self setRefreshState:AXRefreshControlStateNormal];
        [self handleNormalStateWithContentOffset:contentOffset];
    }
}

- (void)handleScrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y+=_scrollView.originalInset.top;
    
    if (_refreshState == AXRefreshControlStateRefreshing || _refreshState == AXRefreshControlStatePending) return;
    
    if (contentOffset.y >= 0) {
        [self setRefreshState:AXRefreshControlStateNormal];
    } else if (-contentOffset.y < kAXRefreshControlHeight) {
        [self setRefreshState:AXRefreshControlStateTransiting];
    } else {
        [self setRefreshState:AXRefreshControlStateReached];
        [self handleReachedStateWithContentOffset:contentOffset];
    }
}

- (void)handleScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGPoint contentOffset = scrollView.contentOffset;
    if (contentOffset.y >= 0) return;
    contentOffset.y+=_scrollView.originalInset.top;
    
    if (_refreshState == AXRefreshControlStateRefreshing) return;
    
    if (_refreshState == AXRefreshControlStatePending) {
        if (-scrollView.contentOffset.y >= kAXRefreshControlHeight) return;
        if (_scrollView) [_scrollView endRefreshing];
        [self.refreshIndicator endAniamting];
        [self setRefreshState:AXRefreshControlStateNormal];
    }
    
    if (contentOffset.y >= 0) {
        [self setRefreshState:AXRefreshControlStateNormal];
        [self handleNormalStateWithContentOffset:contentOffset];
    } else if (-contentOffset.y < kAXRefreshControlHeight) {
        [self setRefreshState:AXRefreshControlStateTransiting];
        [self handleTransitingStateWithContentOffset:contentOffset];
    } else {
        [self setRefreshState:AXRefreshControlStateReleased];
        [self handleReleasedStateWithContentOffset:contentOffset];
        // Play reached sound.
        NSTimeInterval timeinterval = [[NSDate date] timeIntervalSinceDate:_reachedDate];
        if (timeinterval < 0.25) return;
        if (_soundInteractive) [self playSound:@"AXRefreshControl.bundle/sound_refreshing"];
    }
}

- (void)handlescrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    if (contentOffset.y >= 0) return;
    contentOffset.y+=_scrollView.originalInset.top;
    
    if (_refreshState == AXRefreshControlStateRefreshing) return;
    
    if (_refreshState == AXRefreshControlStatePending) {
        if (_scrollView) [_scrollView endRefreshing];
        [self.refreshIndicator endAniamting];
        [self setRefreshState:AXRefreshControlStateTransiting];
        return;
    }
    
    if (contentOffset.y >= 0) {
        [self setRefreshState:AXRefreshControlStateNormal];
    } else if (-contentOffset.y < kAXRefreshControlHeight) {
        [self setRefreshState:AXRefreshControlStateTransiting];
    } else {
        [self setRefreshState:AXRefreshControlStateReleased];
    }
}

#pragma mark - Handler.
- (void)handleNormalStateWithContentOffset:(CGPoint)contentOffset {
    if (!_scrollView.animatingContentInset) {
        [self setHidden:YES];
    }
    [self.refreshIndicator handleRefreshControlStateChanged:AXRefreshControlStateNormal transition:-contentOffset.y];
}

- (void)handleTransitingStateWithContentOffset:(CGPoint)contentOffset {
    [self.refreshIndicator handleRefreshControlStateChanged:AXRefreshControlStateTransiting transition:-contentOffset.y];
}

- (void)handleReachedStateWithContentOffset:(CGPoint)contentOffset {
    // Play reached sound.
    if (_scrollView.isDragging) {
        _reachedDate = [NSDate date];
        if (_soundInteractive) [self playSound:@"AXRefreshControl.bundle/sound_reached"];
    }
    [self.refreshIndicator handleRefreshControlStateChanged:AXRefreshControlStateReached transition:-contentOffset.y];
}

- (void)handleReleasedStateWithContentOffset:(CGPoint)contentOffset {
    [self.refreshIndicator handleRefreshControlStateChanged:AXRefreshControlStateReleased transition:-contentOffset.y];
}

- (void)handleRefreshingStateWithContentOffset:(CGPoint)contentOffset {
    if (self.refreshIndicator.isAnimating || self.refreshIndicator.neededEndAnimating || _scrollView.isDragging) return;
    [self.refreshIndicator handleRefreshControlStateChanged:AXRefreshControlStateRefreshing transition:-contentOffset.y];
    [self beginRefreshing];
}

- (void)handlePendingStateWithContentOffset:(CGPoint)contentOffset {
    [self.refreshIndicator handleRefreshControlStateChanged:AXRefreshControlStatePending transition:-contentOffset.y];
}

#pragma mark - Private
- (SystemSoundID)playSound:(NSString *)soundName
{
    SystemSoundID ssid;
    NSString* pathName = nil;
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    pathName = [bundle pathForResource:soundName ofType:@"wav"];
    if (pathName) {
        NSURL* pathUrl = [[NSURL alloc] initFileURLWithPath:pathName];
        if (pathUrl) {
            OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathUrl, &ssid);
            if (err == kAudioServicesNoError) {
                AudioServicesPlaySystemSound(ssid);
                return ssid;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    else {
        return 0;
    }
}
@end
#pragma mark - AXRefreshControlIndicator
@implementation AXRefreshControlIndicator
@synthesize rotating = _rotating;
#pragma mark - Initializer
- (void)initializer {
    [super initializer];
    _rotateDuration = 1.6;
}
#pragma mark - Override
- (void)drawComponents {
    // Get the 12 components of the bounds.
    CGFloat angle = M_PI*2/12;
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    UIColor *tintColor = self.tintColor?:[UIColor blackColor];
    // Draw all the possilbe line using the proper tint color.
    for (int64_t i = self.animatedColorIndex; i < self.animatedColorIndex+self.drawingComponents; i++) [self drawLineWithAngle:angle*i+_rotateOffset-M_PI_2 context:cxt tintColor:self.animating&&!_neededEndAnimating?[tintColor colorWithAlphaComponent:((float)i-(float)self.animatedColorIndex)/12.0]:tintColor];
}
#pragma mark - Delegate
- (void)handleRefreshControlStateChanged:(AXRefreshControlState)state transition:(CGFloat)transition {
    switch (state) {
        case AXRefreshControlStateTransiting: {
            if (self.isAnimating) break;
            int64_t components = MAX(1, ceil(transition/(kAXRefreshControlHeight/12)));
            if (components > 12) return;
            self.drawingComponents = components;
            self.rotating = NO;
        }
            break;
        case AXRefreshControlStateReached: {
            if (self.isAnimating) break;
            if (self.drawingComponents != 12) {
                [self setDrawingComponents:12];
            }
            if (!self.isRotating) {
                [self rotateWithRepeat:0 reverse:YES duration:_rotateDuration*2];
            }
        }
            break;
        case AXRefreshControlStateReleased: {
            
        }
            break;
        case AXRefreshControlStateRefreshing:
            
            break;
        case AXRefreshControlStatePending: {
            if (_neededEndAnimating) break;
            [self setNeedsEndAnimating];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getters
- (BOOL)isRotating {
    return _rotating;
}

#pragma mark - Setters
- (void)setRotateOffset:(CGFloat)rotateOffset {
    _rotateOffset = rotateOffset;
    [self setNeedsDisplay];
}

- (void)setRotating:(BOOL)rotating {
    _rotating = rotating;
    if (rotating) {
        [self rotateWithRepeat:0 reverse:NO duration:_rotateDuration];
    } else {
        [self.layer removeAnimationForKey:@"transform.rotation"];
    }
}
#pragma mark - Public 
- (void)rotateWithRepeat:(int64_t)repeat reverse:(BOOL)reverse duration:(NSTimeInterval)duration {
    _rotating = YES;
    // Create a rotate animation.
    CABasicAnimation *rotating = [self rotateAnimationWithRepeat:repeat reverse:reverse duration:duration];
    [self.layer addAnimation:rotating forKey:@"transform.rotation"];
}

- (void)beginAnimating {
    if (self.drawingComponents != 12) {
        self.drawingComponents = 12;
    }
    // Begin with a scale aimation.
    CAKeyframeAnimation *scale1 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale1.values = @[@(1.0), @(1.4), @(1.0)];
    scale1.removedOnCompletion = YES;
    scale1.fillMode = kCAFillModeForwards;
    scale1.duration = kAXRefreshAnimationDuration;
    [self.layer addAnimation:scale1 forKey:@"transform.scale"];
    // Begin rotate.
    [self rotateWithRepeat:1 reverse:NO duration:_rotateDuration];
    [self setAnimating:YES];
}

- (void)endAniamting {
    [self setRotating:NO];
    [self setAnimating:NO];
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    // Reset the state of control.
    self.animatedColorIndex = 0;
    _rotateOffset = 0.0;
    _neededEndAnimating = NO;
    [self setNeedsDisplay];
    [self rotateWithRepeat:1 reverse:YES duration:_rotateDuration];
}

- (void)setNeedsEndAnimating {
    _neededEndAnimating = YES;
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        [self setNeedsDisplay];
    }
    [self rotateWithRepeat:0 reverse:YES duration:_rotateDuration*2];
}

- (void)endAniamtingInNeeded {
    if (!_neededEndAnimating) return;
    [self endAniamting];
}

#pragma mark - Helper

- (CABasicAnimation *)rotateAnimationWithRepeat:(float)repeat reverse:(BOOL)reverse duration:(NSTimeInterval)duration {
    CABasicAnimation *rotating = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotating.toValue = @(reverse?-M_PI*2:M_PI*2);
    rotating.duration = duration;
    [rotating setFillMode:kCAFillModeForwards];
    rotating.removedOnCompletion = YES;
    if (repeat == 0) {
        rotating.repeatCount = CGFLOAT_MAX;
    } else {
        rotating.repeatCount = repeat;
    }
    return rotating;
}
@end
