//
//  DWSettingViewController.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock) (void);

@protocol DWSettingViewControllerDelegate <NSObject>

- (void)dismissViewController;

@end

@interface DWSettingViewController : UIViewController

@property (weak, nonatomic) id<DWSettingViewControllerDelegate> delegate;

@end
