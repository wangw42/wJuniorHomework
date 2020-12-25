//
//  SettingViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "SettingViewController.h"
#import "UserInfo.h"
#import "LogInViewController.h"
#import "TabBarController.h"
#import <AFNetworking/AFNetworking.h>


@interface SettingViewController ()
@end

@implementation SettingViewController

- (instancetype)init{
    self = [super init];
    
    // TabBar & navi
    self.tabBarItem.title = @"设置";
    self.navigationItem.title = @"设置";
    UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = img1;
    self.tabBarItem.selectedImage = img2;

    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserInfo *userInfo = [UserInfo sharedUser];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:nil];
    switch (indexPath.row){
        case 0:
            cell.textLabel.text = @"用户名";
            cell.detailTextLabel.text = userInfo.name;
            break;
        case 1:
            cell.textLabel.text = @"邮箱";
            cell.detailTextLabel.text = userInfo.email;
            break;
        case 2:
            cell.textLabel.text = @"Bio";
            cell.detailTextLabel.text = userInfo.bio;
            break;
        case 3:
            cell.textLabel.text = @"性别";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",userInfo.gender];
            break;
        case 4:
            cell.textLabel.text = @"Nick Name";
            cell.detailTextLabel.text = @"None";
            break;
        case 5:
            cell.textLabel.text = @"班级";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",userInfo.classNum];
            break;
        case 6:
            [cell.textLabel setText:@"退出登录"];
            break;
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return 60;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger i = indexPath.row;
    if(i == 6 ) [self logOut];
    if(i != 0 ) [self Alert:[NSString stringWithFormat:@"禁止修改"]];
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"修改信息"] message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
                NSArray *textfields = alertController.textFields;
                UITextField * namefield = textfields[0];
                NSLog(@"%@",namefield.text);
                [self changeName:namefield.text];
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)changeName:(NSString *)newName {
    NSString *URL = @"http://172.18.178.56/api/user/name";
    NSDictionary *body = @{@"name":newName};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *response = (NSDictionary *)responseObject;
        if([response[@"State"] isEqualToString:@"success"]){
            [self.tableView reloadData];
            [self Alert:@"改名成功"];
        }
        else
            [self Alert:@"改名失败"];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request failure");
    }];
}

- (void)Alert:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:true completion:nil];
}



- (void)logOut {
    
    NSString *URL = @"http://172.18.178.56/api/user/logout";
        
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
    [manager POST:URL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        UIWindow* window = nil;
        
        if (@available(iOS 13.0, *)){
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
                if (windowScene.activationState == UISceneActivationStateForegroundActive){
                    window = windowScene.windows.firstObject;
                    break;
                }
        }
        else
            window = [UIApplication sharedApplication].keyWindow;
        window.rootViewController =[LogInViewController new];
            
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Log out failed somehow");
    }];
    
}

@end

