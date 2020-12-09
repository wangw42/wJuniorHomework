//
//  PicCell.h
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PicCell : UITableViewCell


@property (nonatomic, copy) void (^showImageBlock)(UIImage *image);

- (void)addPic:(UIImage *)img;
@end


