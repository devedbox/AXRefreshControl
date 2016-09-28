//
//  UIScrollView+Refreshable.m
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/27.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "UIScrollView+Refreshable.h"
#import "AXRefreshControl_Private.h"
#import <objc/runtime.h>
#import <pop/POP.h>

@interface _AXScrollViewObserverableManager : NSObject
/// Scroll view.
@property(weak, nonatomic) UIScrollView *scrollView;
@end

@implementation UIScrollView (Refreshable)
+ (void)ax_exchangeClassMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getClassMethod(self, method1), class_getClassMethod(self, method2));
}

+ (void)ax_exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}

#pragma mark - Methods

- (void)dealloc {
    [self removeObserver:self.observeManager forKeyPath:@"contentOffset"];
    [self setContentInset:self.originalInset];
}

- (void)addObserver {
    [self addObserver:self.observeManager forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - Getters
// Get the refresh control.
- (AXRefreshControl *)ax_refreshControl {
    AXRefreshControl *control = objc_getAssociatedObject(self, _cmd);
    if (!control) {
        control = [[AXRefreshControl alloc] init];
        control.scrollView = self;
        objc_setAssociatedObject(self, _cmd, control, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return control;
}

- (BOOL)isRefreshEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIEdgeInsets)originalInset {
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}

- (_AXScrollViewObserverableManager *)observeManager {
    _AXScrollViewObserverableManager *manager = objc_getAssociatedObject(self, _cmd);
    if (!manager) {
        manager = [[_AXScrollViewObserverableManager alloc] init];
        manager.scrollView = self;
        [self setObserveManager:manager];
    }
    return manager;
}

#pragma mark - Setters
- (void)setObserveManager:(_AXScrollViewObserverableManager *)observeManager {
    objc_setAssociatedObject(self, @selector(observeManager), observeManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRefreshEnabled:(BOOL)refreshEnabled {
    objc_setAssociatedObject(self, @selector(isRefreshEnabled), @(refreshEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (refreshEnabled) {
        [self addObserver];
        [self resetOrginalContentInset];
        self.ax_refreshControl.backgroundColor = [UIColor whiteColor];
    } else {
        [self removeObserver:self.observeManager forKeyPath:@"contentOffset"];
    }
}

- (void)setOriginalInset:(UIEdgeInsets)originalInset {
    objc_setAssociatedObject(self, @selector(originalInset), [NSValue valueWithUIEdgeInsets:originalInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - Public
- (void)resetOrginalContentInset {
    [self setOriginalInset:self.contentInset];
}

- (void)beginRefreshing {
    [self.ax_refreshControl beginRefreshing];
}

- (void)endRefreshing {
    [self.ax_refreshControl endRefreshing];
}
@end

@implementation _AXScrollViewObserverableManager
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        contentOffset.y+=_scrollView.originalInset.top;

        if (contentOffset.y < 0 && [_scrollView isRefreshEnabled]) {
            // Add the refresh control to scroll view.
            if (!_scrollView.ax_refreshControl.superview) {
                [_scrollView insertSubview:_scrollView.ax_refreshControl atIndex:0];
            }
            // Update the frame of refresh control.
            [_scrollView.ax_refreshControl setFrame:CGRectMake(0, contentOffset.y, CGRectGetWidth(_scrollView.frame), MAX(-contentOffset.y, kAXRefreshControlIndicatorSize))];
            
            int64_t components = MAX(1, -((int64_t)contentOffset.y+kAXRefreshControlIndicatorSize/2)/(kAXRefreshControlHeight/12));
            // Handle with none animating.
            if (!_scrollView.ax_refreshControl.refreshIndicator.isAnimating) {
                if (contentOffset.y >= -kAXRefreshControlIndicatorSize/2) {
                    [_scrollView.ax_refreshControl.refreshIndicator setRotating:NO];
                    _scrollView.ax_refreshControl.refreshIndicator.rotateOffset = 0.0;
                    _scrollView.ax_refreshControl.refreshIndicator.drawingComponents = 1;
                    _scrollView.ax_refreshControl.refreshIndicator.alpha = -contentOffset.y/(kAXRefreshControlIndicatorSize/2);
                } else {
                    _scrollView.ax_refreshControl.refreshIndicator.alpha = 1.0;
                    _scrollView.ax_refreshControl.refreshIndicator.drawingComponents = components;
                    // Begin the animating if components reach to the value.
                    if (components >= 12) {
                        if (_scrollView.isDragging) {
                            if (!_scrollView.ax_refreshControl.refreshIndicator.isRotating) {
                                [_scrollView.ax_refreshControl.refreshIndicator rotateWithRepeat:0 reverse:YES duration:_scrollView.ax_refreshControl.refreshIndicator.rotateDuration*2];
                            }
                        } else {
                            [_scrollView.ax_refreshControl beginRefreshing];
                        }
                    }
                }
            } else {
                // Update conent inset and content offset.
                // Set the content inset to the target content inset.
                if (contentOffset.y+kAXRefreshControlHeight<=0 && !_scrollView.isDragging && _scrollView.ax_refreshControl.refreshIndicator.isAnimating) {
                    UIEdgeInsets contentInset = _scrollView.originalInset;
                    contentInset.top+=kAXRefreshControlHeight;
                    if (UIEdgeInsetsEqualToEdgeInsets(contentInset, _scrollView.contentInset)) return;

                    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        _scrollView.contentInset = contentInset;
                        _scrollView.contentOffset = CGPointMake(0, contentOffset.y-_scrollView.originalInset.top);
                    } completion:NULL];
                }
            }
        } else {
            if (_scrollView.ax_refreshControl.superview && !_scrollView.ax_refreshControl.refreshIndicator.isAnimating) {
                [_scrollView.ax_refreshControl removeFromSuperview];
                [_scrollView.ax_refreshControl.refreshIndicator pop_removeAllAnimations];
                [_scrollView.ax_refreshControl.refreshIndicator.layer pop_removeAllAnimations];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
