//
//  UserInfoViewController.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#ifndef UserInfoViewController_h
#define UserInfoViewController_h
#import <UIKit/UIKit.h>


@interface UserInfoViewController : UITableViewController
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * useremail;
@end

#endif /* UserInfoViewController_h */
