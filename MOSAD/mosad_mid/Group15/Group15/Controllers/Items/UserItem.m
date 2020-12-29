//
//  UserItem.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    self.userName = dict[@"Name"];
    self.gender = [dict[@"Gender"] intValue];
    self.value_class = [dict[@"Class"] intValue];
    self.email = dict[@"Email"];
    self.userid = dict[@"ID"];
    
    
    
    
    NSString *avatarURL = dict[@"Avatar"];
    
    if([avatarURL isEqualToString:@""])
    {
        if(self.gender == 0)
            self.avatar = [UIImage imageNamed:@"avatar.png"];
        else if(self.gender == 1)
            self.avatar = [UIImage imageNamed:@"avatar.png"];
        else
            self.avatar = [UIImage imageNamed:@"avatar.png"];
    }
    else
    {
        NSURL *URL = [NSURL URLWithString:avatarURL];// 获取的图片地址
        self.avatar = [UIImage imageWithData: [NSData dataWithContentsOfURL:URL]]; // 根据地址取出图片
    }
    return self;
    
}





@end
