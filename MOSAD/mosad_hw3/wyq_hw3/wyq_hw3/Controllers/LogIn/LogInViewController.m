//
//  LogInViewController.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "LogInViewController.h"
#import "TabBarController.h"
#import "SceneDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "UserItem.h"

@interface LogInViewController ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UserItem * userItem;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *avatar = [[UIImage imageNamed:@"avatar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIColor *bgimg = [UIColor colorWithPatternImage:avatar];
    [_logo setBackgroundColor:bgimg];
    _logo.layer.cornerRadius = _logo.bounds.size.width/2;
    _logo.layer.masksToBounds = YES;
    
    [_pwd setSecureTextEntry:YES];
    
    [_name setHidden:YES];
    [_logBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_logBtn.layer setCornerRadius:4];
    
    _isLogIn = YES;
}



# pragma mark 登录/注册
- (IBAction)logIn:(id)sender {
    NSString *email = [_mail text];
    NSString *password = [_pwd text];
    if(_isLogIn)
        [self logInWithEmail:email AndPassword:password];
    
    
}

- (void)logInWithEmail:(NSString *)email
           AndPassword:(NSString *)password {
    NSString *URL = @"http://172.18.176.202:3333/hw3/signup";
    NSDictionary *body = @{
        @"name":email,
        @"pwd":password
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    
    [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"\nRequest success with responce %@", responseObject);
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if([[response valueForKey:@"msg"] isEqualToString:@"success"]) {
            NSLog(@"LogIn success");
            
            NSString *selfURL = @"http://172.18.176.202:3333/hw3/getinfo?name=MOSAD";
            [manager GET:selfURL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *response = (NSDictionary *)responseObject;
                self.userItem = [[UserItem alloc] initWithDict:response];
                self.username = self.userItem.userName;
                
                // 找到主界面，更改根vc到tabbar
                UIWindow* window = nil;
                if (@available(iOS 13.0, *))
                {
                    for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
                        if (windowScene.activationState == UISceneActivationStateForegroundActive)
                        {
                            window = windowScene.windows.firstObject;
                            break;
                        }
                }
                else{
                    window = [UIApplication sharedApplication].keyWindow;
                }
                TabBarController* tbc =  [[TabBarController alloc]init];
                tbc.username = self.username;
                window.rootViewController = tbc;
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Get self info failed somehow");
            }];
        }
        else if([[response valueForKey:@"Data"] isEqualToString:@"not found"])
            [self Alert:@"没有这个账号"];
        
        else if([[response valueForKey:@"Data"] isEqualToString:@"crypto/bcrypt: hashedPassword is not the hash of the given password"])
            [self Alert:@"密码错误"];
        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request failure");
    }];
    
}



# pragma mark 提示
- (void)Alert:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:true completion:nil];
}


@end
