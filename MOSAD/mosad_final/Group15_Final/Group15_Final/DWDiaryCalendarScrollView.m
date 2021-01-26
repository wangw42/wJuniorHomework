//
//  DWDiaryCalendarScrollView.m
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "DWDiaryCalendarScrollView.h"
#import "DWDiaryCalendarView.h"
#import "ViewController.h"
#import "Constants.h"

@interface DWDiaryCalendarScrollView()

@property (strong, nonatomic) NSMutableArray *arrayDayViews;

@end

@implementation DWDiaryCalendarScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollsToTop = NO;
        _arrayDayViews = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            CGFloat X = i * DWScreenWidth;
            DWDiaryCalendarView *view = [[DWDiaryCalendarView alloc] initWithFrame:CGRectMake(X, 0, DWScreenWidth, DWDiaryCalendarViewHeight)];
            [self addSubview:view];
            [_arrayDayViews addObject:view];
        }
    }
    return self;
}

- (NSMutableArray *)arrayDayViews {
    if (!_arrayDayViews) {
        _arrayDayViews = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _arrayDayViews;
}

- (void)setArrayDayDics:(NSArray *)arrayDayDics {
    if (arrayDayDics) {
        _arrayDayDics = arrayDayDics;
        
        CGFloat W = DWScreenWidth;
        
        for (int i = 0; i < arrayDayDics.count; i++) {
            DWDiaryCalendarView *view = _arrayDayViews[i];
            view.dicDate = arrayDayDics[i];
        }
        
        CGFloat contentW = W * arrayDayDics.count;
        self.contentSize = CGSizeMake(contentW, 0);
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
    }
}

@end
