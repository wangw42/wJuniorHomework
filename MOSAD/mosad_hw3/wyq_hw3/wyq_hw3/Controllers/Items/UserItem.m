//
//  UserItem.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    self.userName = dict[@"name"];
    self.level = dict[@"level"];
    self.email = dict[@"email"];
    self.phone = dict[@"phone"];
    return self;
    
}





@end
