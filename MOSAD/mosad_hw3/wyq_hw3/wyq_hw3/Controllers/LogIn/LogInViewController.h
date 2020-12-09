//
//  LogInViewController.h
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#ifndef LogInViewController_h
#define LogInViewController_h

#import <UIKit/UIKit.h>



@interface LogInViewController : UIViewController

@property (nonatomic,strong) IBOutlet UILabel * logo;
@property (nonatomic,strong) IBOutlet UITextField * mail;
@property (nonatomic,strong) IBOutlet UITextField * pwd;
@property (nonatomic,strong) IBOutlet UITextField * name;
@property (nonatomic,strong) IBOutlet UIButton * logBtn;


@property (nonatomic) bool isLogIn;

@end

#endif /* LogInViewController_h */

