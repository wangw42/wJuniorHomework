//
//  PicCell.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicCell.h"
#import "ImageSender.h"
#import <AFNetworking/AFNetworking.h>

@interface PicCell()


@property (nonatomic, strong) UIView *pic;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;


@end



@implementation PicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initPicView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


# pragma mark 图片区域
- (void)initPicView {
    _pic = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    
    [_scrollView addSubview:_pic];
    [_scrollView setContentSize:CGSizeMake(110, _scrollView.frame.size.height)];
    [_scrollView setClipsToBounds:YES];
    
    [_scrollView.layer setCornerRadius:5];
    [_pic.layer setCornerRadius:5];
    UIColor *backgroundColor = [UIColor whiteColor];
    [_pic setBackgroundColor:backgroundColor];
    [_scrollView setBackgroundColor:backgroundColor];
    
}

- (void)addPic:(UIImage *)img {
    
    UIImageView *newPicView = [[UIImageView alloc] initWithFrame:[self frameAtIndex:1]];
    [newPicView setImage:img];
    [newPicView.layer setCornerRadius:5];
    [newPicView.layer setMasksToBounds:YES];
    
    ImageSender *tapGesture = [[ImageSender alloc] initWithTarget:self
                                                                   action:@selector(showFullImage:)];
    
    tapGesture.image = img;
    [newPicView setUserInteractionEnabled: YES];
    [newPicView addGestureRecognizer:tapGesture];
 
    [_pic addSubview:newPicView];
}

- (void)showFullImage:(ImageSender *)sender{
    if(self.showImageBlock)
        self.showImageBlock(sender.image);
}

- (CGRect)frameAtIndex:(int)i{
    return CGRectMake(10 + 110 * i, 10, 100, 100);
}




@end

