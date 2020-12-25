//
//  DataItem.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "DataItem.h"

@implementation DataItem

- (id)init
{
  self = [super init];

  _tags = [NSMutableArray new];
  return self;
}

- (NSDictionary *)getDict
{

    NSDictionary *dict = @{
        @"title" : _title,
        @"detail" : _detail,
        @"tags" : _tags,
        @"isPublic" : [NSNumber numberWithBool:_isPublic]
    };
    return dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    self.ownID = dict[@"OwnID"];
    self.title = dict[@"Name"];
    self.detail = dict[@"Detail"];
    self.isPublic = [dict[@"Public"] intValue] == 1;
    self.tags = (NSMutableArray *)dict[@"Tag"];
    self.contentID = dict[@"ID"];
    self.PublishDate = [dict[@"PublishDate"] longValue];
    self.likeNum = [dict[@"LikeNum"] intValue];
    self.commentNum = [dict[@"CommentNum"] intValue];
    
    self.contentType = dict[@"Type"];
    
    self.album = dict[@"Album"];
    return self;
}

// 没发过消息的用户 先这样放着
- (instancetype)initEmpty{
    self = [super init];
    self.ownID = @"null";
    self.title = @"null";
    self.detail = @"null";
    self.isPublic =  1;
    self.tags = nil;
    self.contentID = @"null";
    self.PublishDate = nil;
    self.likeNum = 0;
    self.commentNum = 0;
    return self;
}

@end
