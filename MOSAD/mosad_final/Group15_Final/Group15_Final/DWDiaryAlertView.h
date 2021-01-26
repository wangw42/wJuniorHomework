//
//  DWDiaryAlertView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDiaryAlertDelegate <NSObject>

- (void)buttonYesPressed;
- (void)buttonNoPressed;

@end

@interface DWDiaryAlertView : UIView

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;

@property (weak, nonatomic) id<DWDiaryAlertDelegate> delegate;

- (void)showAnimated;

@end
