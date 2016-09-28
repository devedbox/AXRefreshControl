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

- (void)resetOrginalContentInset;

- (void)beginRefreshing;
- (void)endRefreshing;
@end
