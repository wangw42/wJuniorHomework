//
//  MineController.h
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogInController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentC;
@property (nonatomic) UIColor *themeColor;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageContentArray;
@end

NS_ASSUME_NONNULL_END
