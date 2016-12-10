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
NS_ASSUME_NONNULL_BEGIN
NS_ENUM_AVAILABLE_IOS(8_0)
typedef NS_ENUM(int64_t, AXRefreshControlState) {
    /// State normal. Offset plus original inset more than or equal to zero.
    AXRefreshControlStateNormal,
    /// State transiting.
    AXRefreshControlStateTransiting,
    /// State reached.
    AXRefreshControlStateReached,
    /// State released.
    AXRefreshControlStateReleased,
    /// State refreshing.
    AXRefreshControlStateRefreshing,
    /// State pending.
    AXRefreshControlStatePending
};
NS_CLASS_AVAILABLE_IOS(8_0)
@interface AXRefreshControl : UIControl
/// State of refresh control.
@property(assign, nonatomic) AXRefreshControlState refreshState;
/// Sound interavtive. Default is NO.
@property(assign, nonatomic) BOOL soundInteractive;
/// Refresh control is refreshing.
@property(nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing;
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing;
@end
NS_ASSUME_NONNULL_END
