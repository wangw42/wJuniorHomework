//
//  SettingManage.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingManage : NSObject

@property (assign, nonatomic) BOOL isLocked;

+ (instancetype)sharedInstance;

@end
