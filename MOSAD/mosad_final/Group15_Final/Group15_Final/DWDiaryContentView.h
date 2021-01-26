//
//  DWDiaryContentView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDiaryContentViewDelegate <NSObject>

- (void)openTypingViewWithDicDate:(NSDictionary *)dicDate;
- (void)deleteDiaryWithDicDate:(NSDictionary *)dicDate;
- (void)updateContentViewWithOffset:(NSInteger)offset;

@end

@interface DWDiaryContentView : UIView

@property (strong, nonatomic) NSDictionary *dicDate;
@property (strong, nonatomic) NSString *detail;

@property (weak, nonatomic) id<DWDiaryContentViewDelegate> delegate;

- (void)showAnimated;

@end
