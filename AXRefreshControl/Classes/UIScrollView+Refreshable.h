//
//  UIScrollView+Refreshable.h
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/27.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXRefreshControl.h"

@interface UIScrollView (Refreshable)
/// Refresh control.
@property(readonly, nonatomic) AXRefreshControl *ax_refreshControl;
/// Refresh enabled.
@property(assign, nonatomic, getter=isRefreshEnabled) BOOL refreshEnabled;
/// Reset the original content inset of scroll view when the contnet inset has changed.
- (void)resetOrginalContentInset;
/// Begin refreshing and set the content inset and content offset to the right value.
- (void)beginRefreshing;
/// End refreshing and reset the content inset and offset.
- (void)endRefreshing;
@end
