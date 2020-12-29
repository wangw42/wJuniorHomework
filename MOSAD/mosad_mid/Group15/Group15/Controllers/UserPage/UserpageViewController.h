//
//  UserpageViewController.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#ifndef UserpageViewController_h
#define UserpageViewController_h

#import <UIKit/UIKit.h>
#import "MomentViewController.h"
#import "UserInfoViewController.h"


@interface UserpageViewController : UIViewController

@property (nonatomic) UIColor *themeColor;
@property (strong, nonatomic) UISegmentedControl *segmentC;
@property (nonatomic, strong) UserInfoViewController *userInfo;
@property (nonatomic, strong) MomentViewController *moment;

@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSString * userName;


@end

#endif /* UserpageViewController_h */
