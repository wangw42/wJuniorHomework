//
//  MineController.m
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import "LogInController.h"
#import "FindController.h"
#import "CheckController.h"



@interface LogInController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UITableViewDataSource, UITableViewDelegate>
    @property (nonatomic, strong) NSArray *dataSourceTitles;
    @property (nonatomic, strong) NSArray *dataSourceImgs;
    @property (nonatomic, strong) UIButton *btn;

@end

@implementation LogInController

- (instancetype) init{
    if(self = [super init]){
        [self setupUI];
        //[self loadControllers];
    }
    return self;
}

-(void)setupUI{
    _themeColor = [UIColor lightGrayColor];

    
    //设置标签项的标题及图片
    self.tabBarItem.title = @"我的";
    UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = img1;
    self.tabBarItem.selectedImage = img2;
 
    //添加圆形UIButton
    UIView *btnField = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-200)];
    _btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 160)];
    _btn.center = btnField.center;
    _btn.backgroundColor = [UIColor blackColor];
    _btn.layer.cornerRadius = _btn.bounds.size.width / 2.0;
    //用shadow做渐变
    _btn.layer.shadowColor =  [UIColor blackColor].CGColor;
    _btn.layer.shadowOffset =  CGSizeMake(0, 0);
    _btn.layer.shadowOpacity = 1;
    _btn.layer.shadowRadius = 150.0;
    
    [_btn setTitle:@"登陆" forState:UIControlStateNormal];
    _btn.titleLabel.textColor = [UIColor whiteColor];
    [btnField addSubview:_btn];
    [_btn addTarget:self action:@selector(AfterLogin) forControlEvents:UIControlEventTouchUpInside];
    [_btn sendActionsForControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:btnField];
    
}

-(void)LogInUI{
    _themeColor = [UIColor lightGrayColor];
    self.tabBarItem.title = @"我的";
    UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = img1;
    self.tabBarItem.selectedImage = img2;

    // 头像
    UIImage *avatar = [[UIImage imageNamed:@"avatar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UILabel * profileLabel;
    profileLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 100 ,100, 100)];
    profileLabel.layer.cornerRadius=profileLabel.bounds.size.width/2;
    profileLabel.layer.masksToBounds=YES;
    
    profileLabel.backgroundColor = [UIColor blackColor];
    UIColor *bgimg = [UIColor colorWithPatternImage:avatar];

    [profileLabel setBackgroundColor:bgimg];
    [self.view addSubview:profileLabel];
    
    _segmentC = [[UISegmentedControl alloc]initWithItems:@[@"用户信息",@"关于"]];
    _segmentC.frame = CGRectMake(0, 270, self.view.bounds.size.width, 30);
    _segmentC.tintColor = _themeColor;
    _segmentC.selectedSegmentIndex = 0;
    [_segmentC addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentC];
    
    
    
    //pageView
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                         navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                       options:nil];
    _pageViewController.view.frame = CGRectMake(0, 300, self.view.bounds.size.width, self.view.bounds.size.height - 300);
    _pageViewController.dataSource=self;
    _pageViewController.delegate=self;
    
    //两个tableView
    UITableViewController *userInfo = [[UITableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    UITableViewController *userSettings = [[UITableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    userInfo.tableView.scrollEnabled = NO;
    userSettings.tableView.scrollEnabled = NO;
    userInfo.view.tag = 100;
    userSettings.view.tag = 101;
    userInfo.tableView.delegate = self;
    userInfo.tableView.dataSource = self;
    userSettings.tableView.delegate = self;
    userSettings.tableView.dataSource = self;
    [userInfo.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [userSettings.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    _pageContentArray = @[userInfo, userSettings];
    NSArray *array = @[_pageContentArray[0]];
    [_pageViewController setViewControllers:array direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self.view addSubview:_pageViewController.view];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)AfterLogin{
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self LogInUI];
   

    /*
    [self presentViewController:[[MyInfoController alloc] init] animated:true completion:^{
    }];
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self loadControllers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.parentViewController.navigationItem setTitle:@"我的"];
}

#pragma mark pageView相关内容
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [self indexOfViewInArray:viewController];
    if (index==0) {
        return nil;
    }else{
        return _pageContentArray[index-1];
    }
}
//翻页控制器进行向后翻页动作 这个数据源方法返回的视图控制器为要显示视图的视图控制器
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [self indexOfViewInArray:viewController];
    if (index==1) {
        return nil;
    }else{
        return _pageContentArray[index+1];
    }
}
//返回传入的vc在数组中的index
- (NSInteger)indexOfViewInArray:(UIViewController *)thisVC{
    return [_pageContentArray indexOfObject:thisVC];
}
//翻页成功后调用
//设置segmentedControl的显示
- (void)pageViewController:(UIPageViewController *)pageViewController
didFinishAnimating:(BOOL)finished previousViewControllers:(nonnull NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    //暂时没想到更加合理的实现，这种实现方式只能用于两个标签页的时候。
    if(completed){
        NSInteger index = [self indexOfViewInArray:previousViewControllers[0]];
        _segmentC.selectedSegmentIndex = (index + 1) % 2;
    }
}

#pragma mark 处理tableView
// tableView 中 Section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

// 每个 Section 中的 Cell 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return 4;
}

// 设置每个 Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(tableView.tag == 100){
        // 创建一个cellID，用于cell的重用
        NSString *cellID = @"userInfoCellID";
        // 从tableview的重用池里通过cellID取一个cell
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            // 如果tableview的重用池中没有取到，就创建一个新的cell，style为Value2，并用cellID对其进行标记。
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        }
        if(indexPath.row == 0){
            cell.textLabel.text = @"用户名";
            cell.detailTextLabel.text = @"王五";
        }
        if(indexPath.row == 1){
            cell.textLabel.text = @"ID";
            cell.detailTextLabel.text = @"16303090";
        }
        if(indexPath.row == 2){
            cell.textLabel.text = @"邮箱";
            cell.detailTextLabel.text = @"1070094087@qq.com";
        }
        if(indexPath.row == 3){
            cell.textLabel.text = @"联系电话";
            cell.detailTextLabel.text = @"13659275295";
        }
    }
    if(tableView.tag == 101){
        // 创建一个cellID，用于cell的重用
        NSString *cellID = @"userSettingsCellID";
        // 从tableview的重用池里通过cellID取一个cell
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            // 如果tableview的重用池中没有取到，就创建一个新的cell，style为Value2，并用cellID对其进行标记。
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        if(indexPath.row == 0){
            cell.textLabel.text = @"版本：4.2";
        }
        if(indexPath.row == 1){
            cell.textLabel.text = @"隐私和cookie";
        }
        if(indexPath.row == 2){
            cell.textLabel.text = @"清除缓存";
        }
        if(indexPath.row == 3){
            cell.textLabel.text = @"同步";
        }
        
    }
    return cell;
}


#pragma mark 处理segmentedController点击事件
-(void)segmentValueChanged:(UISegmentedControl *)seg{
    NSInteger selectedIndex = seg.selectedSegmentIndex;
    switch (selectedIndex) {
        case 0:
            {
                NSArray *array = @[_pageContentArray[0]];
                [_pageViewController setViewControllers:array direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            }
            break;
        case 1:
        {
            NSArray *array = @[_pageContentArray[1]];
            [_pageViewController setViewControllers:array direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
            
        default:
            break;
    }
    
}




@end
