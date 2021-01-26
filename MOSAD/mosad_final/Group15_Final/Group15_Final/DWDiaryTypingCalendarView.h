//
//  DWDiaryTypingCalendarView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDiaryTypingCalendarDelegate <NSObject>

- (void)leftButtonPressed;
- (void)rightButtonPressed;

@end

@interface DWDiaryTypingCalendarView : UIView

@property (strong, nonatomic) NSDictionary *dicDate;
@property (weak, nonatomic) id<DWDiaryTypingCalendarDelegate> delegate;

- (void)transformToSmallMood;
- (void)transformToNormalMood;

@end
