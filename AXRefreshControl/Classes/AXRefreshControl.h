//
//  AXRefreshControl.h
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/27.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXRefreshControl : UIControl

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing NS_AVAILABLE_IOS(7_0);
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing NS_AVAILABLE_IOS(7_0);
@end
