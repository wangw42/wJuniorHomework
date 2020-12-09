//
//  FindController.m
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import "FindController.h"
#import "DetailViewController.h"

@interface FindController ()

@property (strong, nonatomic) UIWindow *window;

@end


@implementation FindController




- (instancetype) init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
    
        //设置tab的标题及图片
        self.tabBarItem.title = @"发现";
        UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.image = img1;
        self.tabBarItem.selectedImage = img2;
        
        
        
        //高度自适应设定
        self.tableView.estimatedRowHeight = 68.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
        // cell之间分割线不显示
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        // 搜索框
        UISearchBar * bar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 35)];
        bar.showsCancelButton = YES;
        bar.delegate = self;
        [bar sizeToFit];
        bar.layer.masksToBounds = YES;
     
        // 搜索框取消按钮
        for (UIView *view in [[bar.subviews lastObject] subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *cancelBtn = (UIButton *)view;
                cancelBtn.enabled = YES;
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cancelBtn addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        self.tableView.tableHeaderView = bar;
        
        /*
         //实现背景渐变
         //初始化我们需要改变背景色的UIView，并添加在视图上
         UIView * uiv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
         [self.view addSubview:uiv];
         
         //初始化CAGradientlayer对象，使它的大小为UIView的大小
         CAGradientLayer * cagl = [CAGradientLayer layer];
         cagl.frame = uiv.bounds;
         
         //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
         [uiv.layer addSublayer:cagl];
         
         //设置渐变区域的起始和终止位置（范围为0-1）
         cagl.startPoint = CGPointMake(0, 0);
         cagl.endPoint = CGPointMake(1, 1);
         
         //设置颜色数组
         cagl.colors = @[(__bridge id)[UIColor lightGrayColor].CGColor,
                                          (__bridge id)[UIColor whiteColor].CGColor];
         
         //设置颜色分割点（范围：0-1）
         cagl.locations = @[@(0.5f), @(1.0f)];
         
         */

        
        
    }
    return self;
}

// 点击取消按钮会调用该方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    UIButton *cancelBtn = [searchBar valueForKeyPath:@"cancelButton"]; //首先取出cancelBtn
    cancelBtn.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置navTitle
    [self.parentViewController.navigationItem setTitle:[NSString stringWithFormat:@"打卡清单"]];
}

#pragma mark - Table view data source
// tableView 中 Section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}
// 每个 Section 中的 Cell 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return 27;
}




// 设置每个 Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID1 = @"cellID1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID1];
    }
    NSString *add = @"sysu南实验楼D403";
    NSString *notes = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
    cell.textLabel.text = [NSString stringWithFormat:@"日期  %@\n地点  %@\n心得  %@", [NSDate date],add, notes];
    //高度自适应设定
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.preferredMaxLayoutWidth = 300.0;
    
    return cell;
}

- (UIViewController *)viewController {
    for (UIView* next = [self.view superview]; next; next = next.superview) {
    UIResponder *nextResponder = [next nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController *)nextResponder;
    }
  }
  return nil;
}

// 点击cell显示详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 动画
    CATransition *animation = [CATransition animation];
    //animation.type = @"cube";
    animation.type = @"pageCurl";
    animation.subtype = kCATransitionFromTop ;
    animation.duration = 0.5;
    [self.view.window.layer addAnimation:animation forKey:@"kTransitionAnimation"];
    
    
    DetailViewController *dvc=[[DetailViewController alloc]init];
    [[self viewController]presentViewController:dvc animated:YES completion:nil];
}


// cell加载动画
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;

    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0, 0.5);


    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
    
    //边框
    [cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cell.contentView.layer setBorderWidth:0.5f];
    cell.contentView.layer.cornerRadius = 20;
    cell.contentView.layer.masksToBounds = YES;

}



@end


