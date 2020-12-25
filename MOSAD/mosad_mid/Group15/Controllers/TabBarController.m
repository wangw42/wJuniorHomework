//
//  TabBarController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabBarController.h"

@interface TabBarController ()



@end



@implementation TabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    HomepageViewController * homeVC = [[HomepageViewController alloc] init];
    homeVC.username = _username;
    homeVC.userID = _userID;
    SquareViewController * squareVC = [[SquareViewController alloc] init];
    SettingViewController * settingVC = [[SettingViewController alloc] init];
    
    UINavigationController * nav1 = [[UINavigationController alloc] initWithRootViewController:homeVC];
    nav1.title = @"主页";
    nav1.navigationBar.translucent = NO;
    UINavigationController * nav2 = [[UINavigationController alloc] initWithRootViewController:squareVC];
    nav2.title = @"广场";
    nav2.navigationBar.translucent = NO;
    UINavigationController * nav3 = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav3.title = @"设置";
    nav3.navigationBar.translucent = NO;
    
    self.viewControllers = @[nav1, nav2, nav3];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



@end
