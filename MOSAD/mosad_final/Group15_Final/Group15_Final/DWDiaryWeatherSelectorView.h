//
//  DWDiaryWeatherSelectorView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDiaryWeatherSelectorDelegate <NSObject>

- (void)setWeatherWithString:(NSString *)weather;

@end

@interface DWDiaryWeatherSelectorView : UIView

@property (weak, nonatomic) id<DWDiaryWeatherSelectorDelegate> delegate;

- (void)showAnimated;

@end
