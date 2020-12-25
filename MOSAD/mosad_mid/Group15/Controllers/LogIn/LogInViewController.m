//
//  LogInViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "LogInViewController.h"
#import "TabBarController.h"
#import "SceneDelegate.h"
#import "UserInfo.h"
#import <AFNetworking/AFNetworking.h>
#import "UserItem.h"

@interface LogInViewController ()

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UserItem * userItem;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // logo
    UIImage *avatar = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIColor *bgimg = [UIColor colorWithPatternImage:avatar];
    [_logo setBackgroundColor:bgimg];
    _logo.layer.cornerRadius = _logo.bounds.size.width/2;
    _logo.layer.masksToBounds = YES;
    
    [_pwd setSecureTextEntry:YES];
    
    [_name setHidden:YES];
    [_logBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_logBtn.layer setCornerRadius:4];
    
    [_signIn setUserInteractionEnabled:YES];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchMode)];
    [_signIn addGestureRecognizer:gesture];
    _isLogIn = YES;
}



# pragma mark 登录/注册
- (IBAction)logInOrSignUp:(id)sender {
    NSString *username = [_name text];
    NSString *email = [_mail text];
    NSString *password = [_pwd text];
    if(_isLogIn)
        [self logInWithEmail:email AndPassword:password];
    
    else
        [self signUpWithUsername:username andEmail:email andPassword:password];
    
}

- (void)logInWithEmail:(NSString *)email
           AndPassword:(NSString *)password {
    NSString *URL = @"http://172.18.178.56/api/user/login/pass";
    NSDictionary *body = @{
        @"name":email,
        @"password":password
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"\nRequest success with responce %@", responseObject);
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if([[response valueForKey:@"State"] isEqualToString:@"success"]) {
            NSLog(@"LogIn success");
            
            NSString *selfURL = @"http://172.18.178.56/api/user/info/self";
            [manager GET:selfURL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"\nSelf Info: %@", responseObject);
                NSDictionary *selfInfo = (NSDictionary *)responseObject;
                
                [UserInfo configUser:selfInfo];
                
                NSDictionary *response = (NSDictionary *)responseObject;
                if([response[@"State"] isEqualToString:@"success"]){
                    self.userItem = [[UserItem alloc] initWithDict:response];
                }
                self->_userID = self.userItem.userid;
                self.username = self.userItem.userName;
                
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
                tbc.userID = self.userID;
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


- (void)signUpWithUsername:(NSString *)username
                  andEmail:(NSString *)email
               andPassword:(NSString *)password
{
    NSString *URL = @"http://172.18.178.56/api/user/register";
    NSDictionary *body = @{
        @"name":username,
        @"password":password,
        @"email":email
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *response = (NSDictionary *)responseObject;
        if([response[@"State"] isEqualToString:@"success"])
        {
            [self Alert:@"注册成功"];
            [self switchMode];
            [self.mail setText:email];
            [self.pwd setText:password];
        }
        else
            [self Alert:@"注册失败"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request failure");
    }];
}

# pragma mark 登陆/注册
- (void)switchMode {
    if(_isLogIn){
        [_name setHidden:NO];
        [_logBtn setTitle:@"注册" forState:UIControlStateNormal];
        [_signIn setText:@"返回登陆"];
        [_mail setText:@""];
        [_pwd setText:@""];
        _isLogIn = NO;
    }
    else {
        [_name setHidden:YES];
        [_logBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_signIn setText:@"注册"];
        [_mail setText:@""];
        [_pwd setText:@""];
        _isLogIn = YES;
    }
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
