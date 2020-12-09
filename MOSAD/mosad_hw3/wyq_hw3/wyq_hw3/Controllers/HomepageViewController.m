//
//  HomepageViewController.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomepageViewController.h"
#import <Masonry/Masonry.h>
#import "UserItem.h"
#import <AFNetworking/AFNetworking.h>

@interface HomepageViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;
@property (nonatomic) NSString * gender;

@property (nonatomic, strong) UserItem * userItem;

@end

@implementation HomepageViewController 

- (instancetype)init{
    
    self = [super init];
    
    // TabBar & navi
    self.tabBarItem.title = @"主页";
    self.navigationItem.title = @"主页";
    UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = img1;
    self.tabBarItem.selectedImage = img2;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _w = self.view.bounds.size.width;
    _h = self.view.bounds.size.height;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    return self;
}


- (void)viewDidLoad {
    
    
    [super viewDidLoad];

    
    [self loadData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.tableView.frame =  CGRectMake(0, 250, _w, _h - 250);
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    
    switch (indexPath.row){
        case 0:
            
            cell.textLabel.text = @"Username";
            cell.detailTextLabel.text = [self.userItem userName];
            break;
        case 1:
            cell.textLabel.text = @"E-mail";
            cell.detailTextLabel.text = [self.userItem email];
            break;
        case 2:
            cell.textLabel.text = @"Level";
            cell.detailTextLabel.text = [self.userItem level];
            break;
        case 3:
            cell.textLabel.text = @"Phone";
            cell.detailTextLabel.text = [self.userItem phone];
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



# pragma mark load data
- (void)loadData {
    NSString *URL = @"http://172.18.176.202:3333/hw3/getinfo?name=MOSAD";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:URL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        self.userItem = [[UserItem alloc] initWithDict:response];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to fetch public contents somehow");
    }];
    
}

@end
