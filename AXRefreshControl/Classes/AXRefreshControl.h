//
//  AXRefreshControl.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(int64_t, AXRefreshControlState) {
    AXRefreshControlStateNormal,
    AXRefreshControlStateTransiting,
    AXRefreshControlStateReached,
    AXRefreshControlStateReleased,
    AXRefreshControlStateRefreshing,
    AXRefreshControlStatePending
};

@protocol AXRefreshControlIndicatorDelegate <NSObject>
@required
- (void)beginAnimating;
- (void)endAniamting;
- (void)setNeedsEndAnimating;
- (void)handleRefreshControlStateChanged:(AXRefreshControlState)state transition:(CGFloat)transition;
@end

@interface AXRefreshControl : UIControl

/// State of refresh control.
@property(assign, nonatomic) AXRefreshControlState refreshState;

@property(nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing NS_AVAILABLE_IOS(7_0);
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing NS_AVAILABLE_IOS(7_0);
@end
