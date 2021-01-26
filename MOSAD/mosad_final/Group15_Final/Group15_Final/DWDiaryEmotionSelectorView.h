//
//  DWDiaryEmotionSelectorView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDiaryEmotionSelectorDelegate <NSObject>

- (void)setEmotionWithString:(NSString *)emotion;

@end

@interface DWDiaryEmotionSelectorView : UIView

@property (weak, nonatomic) id<DWDiaryEmotionSelectorDelegate> delegate;

- (void)showAnimated;

@end
