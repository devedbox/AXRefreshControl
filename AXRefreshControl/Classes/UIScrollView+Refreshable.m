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
        [self ax_exchangeInstanceOriginalMethod:@selector(contentInset) swizzledMethod:@selector(ax_contentInset)];
        [self ax_exchangeInstanceOriginalMethod:@selector(setContentInset:) swizzledMethod:@selector(ax_setContentInset:)];
        [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_notifyDidScroll") swizzledMethod:@selector(ax_scrollViewDidScroll)];
        [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_scrollViewWillBeginDragging") swizzledMethod:@selector(ax_scrollViewWillBeginDragging)];
        if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_8_x_Max) {
            [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_endPanNormal:") swizzledMethod:@selector(ax_endPanNormal:)];
            [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_stopScrollDecelerationNotify:") swizzledMethod:@selector(ax_stopScrollDecelerationNotify:)];
        } else {
            [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_scrollViewDidEndDraggingForDelegateWithDeceleration:") swizzledMethod:@selector(ax_scrollViewDidEndDraggingForDelegateWithDeceleration:)];
            [self ax_exchangeInstanceOriginalMethod:NSSelectorFromString(@"_scrollViewDidEndDeceleratingForDelegate") swizzledMethod:@selector(ax_scrollViewDidEndDeceleratingForDelegate)];
        }
    });
}

- (void)ax_scrollViewWillBeginDragging {
    [self ax_scrollViewWillBeginDragging];
    if (![self isRefreshEnabled]) return;
    if (self.contentInset.top + self.contentOffset.y >= 0 && !self.ax_refreshControl.isRefreshing) [self setOriginalInset:self.contentInset];
    [self.ax_refreshControl handleScrollViewWillBeginDragging:self];
}

- (void)ax_scrollViewDidScroll {
    [self ax_scrollViewDidScroll];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handleScrollViewDidScroll:self];
}
// For iOS8+.
- (void)ax_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration {
    [self ax_scrollViewDidEndDraggingForDelegateWithDeceleration:deceleration];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handleScrollViewDidEndDragging:self willDecelerate:deceleration];
}
// For iOS8.
- (void)ax_endPanNormal:(BOOL)arg1 {
    [self ax_endPanNormal:arg1];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handleScrollViewDidEndDragging:self willDecelerate:arg1];
}
// For iOS8+.
- (void)ax_scrollViewDidEndDeceleratingForDelegate {
    [self ax_scrollViewDidEndDeceleratingForDelegate];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handlescrollViewDidEndDecelerating:self];
}
// For iOS8.
- (void)ax_stopScrollDecelerationNotify:(BOOL)arg1 {
    [self ax_stopScrollDecelerationNotify:arg1];
    if (![self isRefreshEnabled]) return;
    [self.ax_refreshControl handlescrollViewDidEndDecelerating:self];
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

- (BOOL)contentInsetSettingFromInternal {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIEdgeInsets)ax_contentInset {
    UIEdgeInsets contentInset = [self ax_contentInset];
    if (self.ax_refreshControl.isRefreshing) {
        return self.originalInset;
    }
    return contentInset;
}

#pragma mark - Setters
// Set conent inset if needed.
- (void)ax_setContentInset:(UIEdgeInsets)contentInset {
    if (self.ax_refreshControl.isRefreshing && !self.contentInsetSettingFromInternal) {
        [self setOriginalInset:contentInset];
        UIEdgeInsets targetContentInset = UIEdgeInsetsMake(self.originalInset.top+kAXRefreshControlHeight, self.originalInset.left, self.originalInset.bottom, self.originalInset.right);
        [self ax_setContentInset:targetContentInset];
        [self setContentOffset:CGPointMake(0, -targetContentInset.top)];
    } else {
        [self ax_setContentInset:contentInset];
    }
}

- (void)setRefreshEnabled:(BOOL)refreshEnabled {
    objc_setAssociatedObject(self, @selector(isRefreshEnabled), @(refreshEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!refreshEnabled) {
        objc_setAssociatedObject(self, @selector(ax_refreshControl), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setAnimatingContentInset:(BOOL)animatingContentInset {
    objc_setAssociatedObject(self, @selector(isAnimatingContentInset), @(animatingContentInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setOriginalInset:(UIEdgeInsets)originalInset {
    objc_setAssociatedObject(self, @selector(originalInset), [NSValue valueWithUIEdgeInsets:originalInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setContentInsetSettingFromInternal:(BOOL)contentInsetSettingFromInternal {
    @throw [NSException exceptionWithName:@"com.devedbox.axrefreshcontrol" reason:@"Can't set the flag value directly." userInfo:nil];
}
#pragma mark - Public
- (void)beginRefreshing {
    // Scroll view is at the beginning state.
    if (self.contentInset.top + self.contentOffset.y >= 0 && !self.ax_refreshControl.isRefreshing) [self setOriginalInset:self.contentInset];
    // Begin refreshing if refresh control is not at refreshing state.
    if (!self.ax_refreshControl.isRefreshing) [self.ax_refreshControl beginRefreshing];
    // Add refresh control to scroll view.
    if (!self.ax_refreshControl.superview) [self insertSubview:self.ax_refreshControl atIndex:0];
    // Set the content inset of the scroll view.
    UIEdgeInsets contentInset = self.originalInset;
    contentInset.top += kAXRefreshControlHeight;
    // If scroll view is dragging then do nothing.
    if (self.isDragging) return;
    self.animatingContentInset = YES;
    [UIView animateWithDuration:kAXRefreshAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        SCROLL_VIEW_SET_CONTENT_INSET_FROM_INTERNAL(self, YES);
        [self setContentInset:contentInset];
        SCROLL_VIEW_SET_CONTENT_INSET_FROM_INTERNAL(self, NO);
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
    // If scroll view is dragging then do nothing.
    if (self.isDragging) return;
    // Set content inset animating.
    self.animatingContentInset = YES;
    [UIView animateWithDuration:kAXRefreshAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        SCROLL_VIEW_SET_CONTENT_INSET_FROM_INTERNAL(self, YES);
        [self setContentInset:contentInset];
        SCROLL_VIEW_SET_CONTENT_INSET_FROM_INTERNAL(self, NO);
        [self.ax_refreshControl layoutSubviews];
    } completion:^(BOOL finished) {
        if (finished) {
            self.animatingContentInset = NO;
            self.ax_refreshControl.hidden = YES;
        }
    }];
}

#pragma mark - Private.
static void SCROLL_VIEW_SET_CONTENT_INSET_FROM_INTERNAL(UIScrollView *scrollView, BOOL fromInternal) {
    objc_setAssociatedObject(scrollView, @selector(contentInsetSettingFromInternal), @(fromInternal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
