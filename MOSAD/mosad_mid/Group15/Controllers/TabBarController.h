//
//  TabBarController.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#ifndef TabBarController_h
#define TabBarController_h

#import <UIKit/UIKit.h>
#import "HomepageViewController.h"
#import "SquareViewController.h"
#import "SettingViewController.h"
#import <Masonry/Masonry.h>

@interface TabBarController : UITabBarController
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* username;
@end



#endif /* TabBarController_h */
