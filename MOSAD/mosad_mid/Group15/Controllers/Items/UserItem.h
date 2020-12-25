//
//  UserItem.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#ifndef UserItem_h
#define UserItem_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface UserItem : NSObject

@property (nonatomic) NSString *userName;
@property (nonatomic) int gender;
@property (nonatomic) int value_class;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *userid;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

#endif /* UserItem */
