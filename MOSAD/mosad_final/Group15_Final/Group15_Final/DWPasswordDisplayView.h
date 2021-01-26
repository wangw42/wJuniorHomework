//
//  DWPasswordDisplayView.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWPasswordDisplayView : UIView

@property (assign, nonatomic) BOOL isEmpty;
@property (assign, nonatomic) BOOL isFull;

- (void)plus;
- (void)minus;

@end
