//
//  UIScrollView+Refreshable.m
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

#import "UIScrollView+Refreshable.h"
#import "AXRefreshControl_Private.h"
#import <objc/runtime.h>

@implementation UIScrollView (Refreshable)
+ (void)ax_exchangeClassOriginalMethod:(SEL)original swizzledMethod:(SEL)swizzled {
    Method _method1 = class_getInstanceMethod(self, original);
    if (_method1 == NULL) return;
    method_exchangeImplementations(_method1, class_getClassMethod(self, swizzled));
}

+ (void)ax_exchangeInstanceOriginalMethod:(SEL)original swizzledMethod:(SEL)swizzled {
    Method _method1 = class_getInstanceMethod(self, original);
    if (_method1 == NULL) return;
    method_exchangeImplementations(_method1, class_getInstanceMethod(self, swizzled));
}

#pragma mark - Methods
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_notifyDidScroll") swizzledMethod:@selector(ax_scrollViewDidScroll)];
        [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_scrollViewWillBeginDragging") swizzledMethod:@selector(ax_scrollViewWillBeginDragging)];
        [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_scrollViewDidEndDraggingForDelegateWithDeceleration:") swizzledMethod:@selector(ax_scrollViewDidEndDraggingForDelegateWithDeceleration:)];
        [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_scrollViewDidEndDeceleratingForDelegate") swizzledMethod:@selector(ax_scrollViewDidEndDeceleratingForDelegate)];
    });
}

- (void)ax_scrollViewWillBeginDragging {
    [self ax_scrollViewWillBeginDragging];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handleScrollViewWillBeginDragging:self];
}

- (void)ax_scrollViewDidScroll {
    [self ax_scrollViewDidScroll];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handleScrollViewDidScroll:self];
}

- (void)ax_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration {
    [self ax_scrollViewDidEndDraggingForDelegateWithDeceleration:deceleration];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handleScrollViewDidEndDragging:self willDecelerate:deceleration];
}

- (void)ax_scrollViewDidEndDeceleratingForDelegate {
    [self ax_scrollViewDidEndDeceleratingForDelegate];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handlescrollViewDidEndDecelerating:self];
}
- (void)dealloc {
    [self setContentInset:self.originalInset];
}

#pragma mark - Getters
// Get the refresh control.
- (AXRefreshControl *)ax_refreshControl {
    AXRefreshControl *control = objc_getAssociatedObject(self, _cmd);
    if (!control) {
        control = [[AXRefreshControl alloc] initWithFrame:CGRectZero];
        control.scrollView = self;
        objc_setAssociatedObject(self, _cmd, control, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return control;
}

- (BOOL)isRefreshEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isAnimatingContentInset {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIEdgeInsets)originalInset {
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}

#pragma mark - Setters

- (void)setRefreshEnabled:(BOOL)refreshEnabled {
    objc_setAssociatedObject(self, @selector(isRefreshEnabled), @(refreshEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setAnimatingContentInset:(BOOL)animatingContentInset {
    objc_setAssociatedObject(self, @selector(isAnimatingContentInset), @(animatingContentInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setOriginalInset:(UIEdgeInsets)originalInset {
    objc_setAssociatedObject(self, @selector(originalInset), [NSValue valueWithUIEdgeInsets:originalInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - Public
- (void)beginRefreshing {
    if (self.originalInset.top - self.contentOffset.y == 0) {
        [self setOriginalInset:self.contentInset];
    }
    if (!self.ax_refreshControl.isRefreshing) {
        [self.ax_refreshControl beginRefreshing];
    }
    // Set the content inset of the scroll view.
    if (!self.ax_refreshControl.superview) {
        [self insertSubview:self.ax_refreshControl atIndex:0];
    }
    UIEdgeInsets contentInset = self.originalInset;
    contentInset.top += kAXRefreshControlHeight;
    if (self.isDragging) return;
    self.animatingContentInset = YES;
    [UIView animateWithDuration:kAXRefreshAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setContentInset:contentInset];
        [self setContentOffset:CGPointMake(0, -contentInset.top)];
        [self.ax_refreshControl layoutSubviews];
    } completion:^(BOOL finished) {
        if (finished) {
            self.animatingContentInset = NO;
        }
    }];
}

- (void)endRefreshing {
    // Reset the content inset of the scroll view.
    UIEdgeInsets contentInset = self.originalInset;
    if (self.isDragging) return;
    self.animatingContentInset = YES;
    [UIView animateWithDuration:kAXRefreshAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setContentInset:contentInset];
        [self.ax_refreshControl layoutSubviews];
    } completion:^(BOOL finished) {
        if (finished) {
            self.animatingContentInset = NO;
            self.ax_refreshControl.hidden = YES;
        }
    }];
}
@end
