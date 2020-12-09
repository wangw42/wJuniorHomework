//
//  TabBarController.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabBarController.h"

@interface TabBarController ()



@end



@implementation TabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HomepageViewController * homeVC = [[HomepageViewController alloc] init];
    homeVC.username = _username;
    SquareViewController * squareVC = [[SquareViewController alloc] init];
    
    UINavigationController * nav1 = [[UINavigationController alloc] initWithRootViewController:homeVC];
    nav1.title = @"主页";
    nav1.navigationBar.translucent = NO;
    UINavigationController * nav2 = [[UINavigationController alloc] initWithRootViewController:squareVC];
    nav2.title = @"广场";
    nav2.navigationBar.translucent = NO;
    
    self.viewControllers = @[nav1, nav2];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



@end
