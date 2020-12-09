//
//  TabBarController.m
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabBarController.h"
#import "LogInController.h"
#import "FindController.h"
#import "CheckController.h"

 

@interface TabBarController ()<UITableViewDataSource, UITableViewDelegate>
    @property (nonatomic, strong) NSArray *dataSourceTitles;
    @property (nonatomic, strong) NSArray *dataSourceImgs;
    @property (nonatomic, strong) FindController *findVC;
    @property (nonatomic, strong) LogInController *mineVC;
    @property (nonatomic, strong) CheckController * checkController;

    @property (nonatomic, strong) UITabBarController *tbc;

@end

@implementation TabBarController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏nav
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //显示其他界面的nav
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (instancetype) init{
    if(self = [super init]){
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    _themeColor = [UIColor whiteColor];
    
    _tbc = [[UITabBarController alloc]init];

    _findVC = [[FindController alloc] init];
    _mineVC = [[LogInController alloc]init];
    _checkController = [[CheckController alloc]init];
    
    _tbc.navigationItem.hidesBackButton = YES;
    _tbc.viewControllers = @[_findVC,_checkController, _mineVC];
    
    [self.navigationController pushViewController:_tbc animated:YES];

    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


@end
