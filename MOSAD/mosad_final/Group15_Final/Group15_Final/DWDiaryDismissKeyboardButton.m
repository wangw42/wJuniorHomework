//
//  DWDiaryDismissKeyboardButton.m
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "DWDiaryDismissKeyboardButton.h"
#import "Constants.h"

@implementation DWDiaryDismissKeyboardButton

- (instancetype)init {
    self = [[super class] buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.backgroundColor = DWDisKeyboardButtonGrayColor;
        [self setTitle:@"隐藏键盘" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return self;
}

@end
