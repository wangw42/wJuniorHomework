//
//  CommentTableViewController.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CommentTableViewController : UITableViewController
@property (nonatomic) NSString *contentID;
@property (nonatomic) NSString *ownID;
@property (nonatomic) NSMutableArray *commentItems;
- (instancetype)initWithContentID:(NSString *)contentID
                       andOwnID:(NSString *)ownID;
@end

