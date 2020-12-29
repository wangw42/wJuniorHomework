//
//  UserNDataItem.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataItem.h"
#import "UserItem.h"


@interface UserNDataItem : NSObject
@property (nonatomic) DataItem *contentItem;
@property (nonatomic) UserItem *userItem;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

