//
//  DetailViewController.m
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"



@interface DetailViewController ()



@end


@implementation DetailViewController




- (instancetype) init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        UILabel* detail = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.view.bounds.size.width-20,self.view.bounds.size.height-20)];
        
        detail.text = @"2020年11月11日\n\n广东省广州市番禺区\n\n中山大学东校区南实验楼\n\n中山大学广州校区东校园位于广州大学城的东北端，旧称中山大学东校区，亦称中山大学大学城校区，和广东外语外贸大学同属第一组团，靠近广州地铁四号线大学北站。东校区地理位置优越，南邻中心公园，东邻城市绿化带，总占地面积1.13平方公里，其中教学区87.5万平方米，生活区25.5万平方米。一期工程共有29栋建筑，包括教学区12幢建筑，建筑面积达32万平方米，共有课室111间，座位14454个；生活区共17幢学生宿舍，建筑面积共11万平方米，可容纳 12456名学生入住。校区规划的主体基本在第一期完成，二期工程计划建筑面积 3.25万平方米，包括多功能体育馆、动物实验中心和2幢学生宿舍。中山大学学生习惯戏称中山大学东校区为“中东”。";
        detail.textColor = [UIColor blackColor];
        detail.font = [UIFont systemFontOfSize:16];
        detail.textAlignment = NSTextAlignmentLeft;
        detail.numberOfLines = 20;
        
        UIImage *img = [[UIImage imageNamed:@"avatar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImageView * iv1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-120, 240, 90, 90)];
        iv1.image = img;
        
        [self.view addSubview:detail];
        [self.view addSubview:iv1];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置navTitle
    [self.parentViewController.navigationItem setTitle:[NSString stringWithFormat:@"查看打卡"]];
}




@end


