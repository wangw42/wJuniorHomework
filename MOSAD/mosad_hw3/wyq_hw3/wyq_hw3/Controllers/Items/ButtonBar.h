//
//  ButtonBar.h
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ButtonBar : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton * loadBtn;
@property (nonatomic, strong) IBOutlet UIButton * cleanBtn;
@property (nonatomic, strong) IBOutlet UIButton * delCacheBtn;

@end

NS_ASSUME_NONNULL_END
