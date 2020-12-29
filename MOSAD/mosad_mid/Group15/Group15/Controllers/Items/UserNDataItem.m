//
//  UserNDataItem.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "UserNDataItem.h"

@implementation UserNDataItem
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    self.contentItem = [[DataItem alloc]initWithDict:dict[@"Data"]];
    self.userItem = [[UserItem alloc]initWithDict:dict[@"User"]];
    return self;
}
@end
