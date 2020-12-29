//
//  LogInViewController.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
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
@property (nonatomic,strong) IBOutlet UILabel * signIn;


@property (nonatomic) bool isLogIn;

@end

#endif /* LogInViewController_h */

