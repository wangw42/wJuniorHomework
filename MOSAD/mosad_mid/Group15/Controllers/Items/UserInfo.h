//
//  UserInfo.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserInfo : NSObject
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *name;
@property (nonatomic) int classNum;
@property (nonatomic) NSString *bio;
@property (nonatomic) int gender;

@property (nonatomic) NSInteger *maxSize;
@property (nonatomic) NSInteger *usedSize;
@property (nonatomic) NSInteger *singleSize;


+ (UserInfo *)sharedUser;
+ (void)configUser:(NSDictionary *)dict;
+ (void)updateUserInfo;
@end

