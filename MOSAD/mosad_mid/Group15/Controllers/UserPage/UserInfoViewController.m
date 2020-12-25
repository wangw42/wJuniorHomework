//
//  UserInfoViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "UserInfoViewController.h"
#import "UserItem.h"

@interface UserInfoViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UITableView *infoView;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;
@property (nonatomic) NSString * gender;

@property (nonatomic, strong) UserItem * userItem;
@end

@implementation UserInfoViewController


- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    // 计算无遮挡页面尺寸
    UIWindow *window = UIApplication.sharedApplication.windows[0];
    CGRect safe = window.safeAreaLayoutGuide.layoutFrame;
    _w = safe.size.width;
    _h = safe.size.height;
    
    [self.view addSubview:self.avatarView];
    [self.view addSubview:self.infoView];
    
    [self loadData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

- (UIView *)avatarView{
    if(_avatarView == nil)
    {
        _avatarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _w, 160)];
        UIImageView *avator = [[UIImageView alloc] initWithFrame:CGRectMake(_w/2 - 45, 35, 90, 90)];
        avator.image = [UIImage imageNamed:@"avatar.jpg"];
        avator.layer.cornerRadius = 45;
        avator.layer.masksToBounds = YES;
        avator.layer.borderWidth = 1;
        [_avatarView addSubview:avator];
    }
    return _avatarView;
}

- (UITableView *)infoView{
    if(_infoView == nil)
    {
        _infoView = [[UITableView alloc]initWithFrame:CGRectMake(0, 160, _w, _h - 160)];
        _infoView.delegate = self;
        _infoView.dataSource = self;
    }
    return _infoView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.tableView.frame =  CGRectMake(0, 160, _w, _h - 160);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    
    switch (indexPath.row){
        case 0:
            
            cell.textLabel.text = @"用户名";
            cell.detailTextLabel.text = [self.userItem userName];
            break;
        case 1:
            cell.textLabel.text = @"邮箱";
            cell.detailTextLabel.text = [self.userItem email];
            break;
        case 2:
            cell.textLabel.text = @"Bio";
            cell.detailTextLabel.text = @"Na";
            break;
        case 3:
            cell.textLabel.text = @"性别";
            
            if([self.userItem gender] == 0) _gender = @"男";
            else _gender = @"女";
            //[NSString stringWithFormat:@"%d",[self.userItem gender]]
            cell.detailTextLabel.text = _gender;
            break;
        case 4:
            cell.textLabel.text = @"Nick Name";
            cell.detailTextLabel.text = @"None";
            break;
    }

    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"个人信息";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 60;
}



- (void)loadData {
    NSString *URL = [@"http://172.18.178.56/api/user/info/" stringByAppendingString:_userID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:URL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        if([response[@"State"] isEqualToString:@"success"]){
            self.userItem = [[UserItem alloc] initWithDict:response];
        }
        
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to fetch public contents somehow");
    }];
    
}

@end
