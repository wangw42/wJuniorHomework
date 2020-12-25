//
//  PostCell.h
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PostCell : UITableViewCell
@property (nonatomic, copy) void (^showImageBlock)(UIImage *image);

//@property (nonatomic, copy) void (^showPersonalPageBlock)(NSString *userID);
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *portraitButton;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *textContentLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *likeNumberLabel;

@property (nonatomic) int picNum;
@property (nonatomic) bool liked;

- (void)dontShowPicView;
- (void)addPic:(UIImage *)image;
@end


