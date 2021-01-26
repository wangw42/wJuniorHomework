//
//  DWDiaryTipsView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDiaryTipsView : UIView

@property (copy, nonatomic) NSString *message;

- (void)showAnimated;
- (void)disappear;

@end
