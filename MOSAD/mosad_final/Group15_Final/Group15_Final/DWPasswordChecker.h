//
//  DWPasswordChecker.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWPasswordChecker : NSObject

// 返回密码校验结果
- (BOOL)checkPassword:(NSString *)password;

// 更新密码
- (void)updateKey:(NSString *)key;

@end
