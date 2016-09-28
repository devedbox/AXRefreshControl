//
//  ScrollViewController.m
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/28.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ScrollViewController.h"
#import "UIScrollView+Refreshable.h"

@interface ScrollViewController ()
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
    [_scrollView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [_scrollView setRefreshEnabled:YES];
    [_scrollView.ax_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_scrollView.ax_refreshControl beginRefreshing];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
