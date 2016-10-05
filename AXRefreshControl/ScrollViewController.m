//
//  ScrollViewController.m
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/28.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ScrollViewController.h"
#import "UIScrollView+Refreshable.h"

@interface ScrollViewController ()<UIScrollViewDelegate>
/// Scroll view.
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_scrollView setContentInset:UIEdgeInsetsMake(128, 0, 0, 0)];
//    [_scrollView setRefreshEnabled:NO];
    [_scrollView setRefreshEnabled:YES];    
    
    _scrollView.ax_refreshControl.backgroundColor = [UIColor blackColor];
    _scrollView.ax_refreshControl.tintColor = [UIColor whiteColor];
    
    [_scrollView.ax_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_scrollView.ax_refreshControl beginRefreshing];
//
    _scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    _scrollView.delegate = self;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_scrollView ax_setContentOffset:CGPointMake(0, -64) animated:YES];
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(AXRefreshControl *)refreshControl {
    if (refreshControl.isRefreshing) {
        NSLog(@"Begin refreshing");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
            
        });
    } else {
        NSLog(@"End refreshing");
    }
}
#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%s", __FUNCTION__);
//}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"%s", __FUNCTION__);
//}
@end
