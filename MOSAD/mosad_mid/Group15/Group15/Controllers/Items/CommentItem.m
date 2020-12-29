//
//  CommentItem.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "CommentItem.h"

@implementation CommentItem

- (instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    
    self.commentID = dict[@"Comment"][@"ID"];
    self.contentID = dict[@"Comment"][@"ContentID"];
    self.userID = dict[@"Comment"][@"UserID"];
    self.publishDate = [dict[@"Comment"][@"Date"] longValue];
    self.commentContent = dict[@"Comment"][@"Content"];
    self.likeNum = [dict[@"Comment"][@"LikeNum"] intValue];
    
    self.userName = dict[@"User"][@"Name"];
    self.gender = [dict[@"User"][@"Gender"] intValue];
    
    return self;
}

@end
