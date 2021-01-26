//
//  DWPasswordViewController.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWPasswordViewControllerDelegate <NSObject>

- (void)dismissViewController;
- (void)saveKeyIntoDataBase:(NSString *)key;
- (void)setSwitcherValue:(BOOL)value;

- (void)enterApp;

@end

@interface DWPasswordViewController : UIViewController

@property (weak, nonatomic) id<DWPasswordViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isSettingMode;

@end
