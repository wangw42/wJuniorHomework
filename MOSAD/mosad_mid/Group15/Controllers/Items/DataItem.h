//
//  DataItem.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataItem : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *detail;
@property (nonatomic) NSMutableArray *tags;
@property (nonatomic) bool isPublic;
@property (nonatomic) NSString *contentType;
@property (nonatomic) NSString *contentID;
@property (nonatomic) long PublishDate;
@property (nonatomic) int likeNum;
@property (nonatomic) int commentNum;
@property (nonatomic) NSString *ownID;

@property (nonatomic) NSArray *images;

@property (nonatomic) NSDictionary *album;


- (instancetype)initWithDict:(NSDictionary *)dict;
- (instancetype)initEmpty;
- (NSDictionary *)getDict;
@end

