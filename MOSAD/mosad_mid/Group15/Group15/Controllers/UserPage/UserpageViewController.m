//
//  UserpageViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserpageViewController.h"
#import "PostCell.h"
#import "CommentTableViewController.h"


@interface UserpageViewController ()

@end

@implementation UserpageViewController



- (void)viewDidLoad{
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden=YES;
    
    _themeColor = [UIColor whiteColor];
    // 头像
    UIImage *avatar = [[UIImage imageNamed:@"avatar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UILabel * profileLabel;
    profileLabel = [[UILabel alloc]initWithFrame:CGRectMake(170, 30 ,100, 100)];
    profileLabel.layer.cornerRadius=profileLabel.bounds.size.width/2;
    profileLabel.layer.masksToBounds=YES;
    
    profileLabel.backgroundColor = [UIColor blackColor];
    UIColor *bgimg = [UIColor colorWithPatternImage:avatar];

    [profileLabel setBackgroundColor:bgimg];
    [self.view addSubview:profileLabel];
    
    _segmentC = [[UISegmentedControl alloc]initWithItems:@[@"用户动态",@"用户信息"]];
    _segmentC.frame = CGRectMake(0, 150, self.view.bounds.size.width, 30);
    _segmentC.tintColor = _themeColor;
    [_segmentC addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentC;
    
    
    UserInfoViewController * uivc = [[UserInfoViewController alloc] init];
    uivc.userID = _userID;
    _userInfo = uivc;
    _userInfo.view.frame=self.view.safeAreaLayoutGuide.layoutFrame;
    
    MomentViewController* mvc = [[MomentViewController alloc] init];
    mvc.userID = _userID;
    mvc.userName = _userName;
    _moment = mvc;
    _moment.view.frame=self.view.safeAreaLayoutGuide.layoutFrame;
    
    [self.view addSubview:_userInfo.view];
    [self.view addSubview:_moment.view];
    
    [_segmentC setSelectedSegmentIndex:0];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // 返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backTapped:)];
    
}


- (void)backTapped:(UIBarButtonItem *)sender{
    self.tabBarController.tabBar.hidden=NO;
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)segmentValueChanged:(UISegmentedControl *)seg{
    NSInteger selectedIndex = seg.selectedSegmentIndex;
    switch (selectedIndex) {
        case 0:
            [_userInfo.view setHidden:YES];
            [_moment.view setHidden:NO];
            
            break;
        case 1:
            [_userInfo.view setHidden:NO];
            [_moment.view setHidden:YES];
            break;
            
        default:
            break;
    }
    
}

@end
