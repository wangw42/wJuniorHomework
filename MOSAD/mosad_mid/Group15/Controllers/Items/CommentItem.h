//
//  CommentItem.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommentItem : NSObject
@property (nonatomic) NSString *commentID;
@property (nonatomic) NSString *contentID;
@property (nonatomic) NSString *userID;
@property (nonatomic) long publishDate;
@property (nonatomic) NSString *commentContent;
@property (nonatomic) int likeNum;

@property (nonatomic) NSString *userName;
@property (nonatomic) int gender;
//@property (nonatomic) UIImage *avatar;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

