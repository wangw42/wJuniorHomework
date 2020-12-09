//
//  UserItem.h
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#ifndef UserItem_h
#define UserItem_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface UserItem : NSObject

@property (nonatomic) NSString *userName;
@property (nonatomic) NSString * level;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *phone;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

#endif /* UserItem */
