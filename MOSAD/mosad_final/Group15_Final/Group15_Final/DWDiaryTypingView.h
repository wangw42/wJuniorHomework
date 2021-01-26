//
//  DWDiaryTypingView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDiaryTypingDelegate <NSObject>

- (void)saveModelWithTitle:(NSString *)title detail:(NSString *)detail emotion:(NSString *)emotion weather:(NSString *)weather;

@end

@interface DWDiaryTypingView : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *emotion;
@property (strong, nonatomic) NSString *weather;

@property (weak, nonatomic) id<DWDiaryTypingDelegate> delegate;

- (void)updateFrameWithDalta:(CGFloat)dalta;

@end
