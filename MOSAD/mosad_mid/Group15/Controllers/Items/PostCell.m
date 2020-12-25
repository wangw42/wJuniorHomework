//
//  PostCell.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "PostCell.h"
#import "CommentTableViewController.h"
#import "ImageSender.h"
#import <AFNetworking/AFNetworking.h>

@interface PostCell()


@property (nonatomic, strong) UIView *insidePicView;
@property (nonatomic, strong) IBOutlet UIScrollView *picView;


@end



@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // 仅用于测试
    [self initWithTestData];
    //[self initWithGivenData:@"1" andEachPage:@"100"];
    
    // 必调用
    [self initPicView];
    [self initStyle];
    
    _liked = false;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

- (NSString *)timeStampToTime:(long)time{
   NSDate *date=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time];
   NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
   dataformatter.dateFormat = @"MM-dd HH:mm a";
   return [dataformatter stringFromDate:date];
}


# pragma mark 测试
- (void)initWithTestData {
    _timeLabel.text = @"2020-12-01";
    _userNameLabel.text = @"w";
    _textContentLabel.text = @"空が僕を笑っている。その青さに憧れた。君のように生きられたらと、何度願っただろう。きっと愛されることが怖くて、無彩の部屋に逃げ込んだ。彩られた世界の中でもう一度生きてみたい。歩き出した感情の音は、水色、淡くささめいて。溢れ出した言の葉達を、まだ覚えている。いつからだろう、ずっと前に凍りついていた僕の感情が色づいてく。";
    
    [_portraitButton setImage:[UIImage imageNamed:@"avatar.png"] forState:UIControlStateNormal];
    
    
    [_likeNumberLabel setText:@"10"];
    [_commentNumberLabel setText:@"2"];
}




- (void)initStyle{
    _portraitButton.layer.cornerRadius = 3;
    _portraitButton.layer.masksToBounds = YES;
}

- (IBAction)pressLikeButton:(id)sender{
    if(_liked)
        [self cancelLike];
    
    else
        [self like];
    
}

- (void)like {
    
    [_likeButton setImage:[UIImage systemImageNamed:@"hand.thumbsup.fill"] forState:UIControlStateNormal];
    _liked = YES;
}

- (void)cancelLike{
    [_likeButton setImage:[UIImage systemImageNamed:@"hand.thumbsup"] forState:UIControlStateNormal];
    _liked = NO;
}




# pragma mark 图片区域
- (void)dontShowPicView{
    [_picView removeFromSuperview];
}

- (void)initPicView {
    int w = _picView.frame.size.width;
    int h = _picView.frame.size.height;
    _insidePicView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    
    [_picView addSubview:_insidePicView];
    [_picView setContentSize:CGSizeMake(110, h)];
    [_picView setClipsToBounds:YES]; // 使内部view不会超出外部view
    
    [_picView.layer setCornerRadius:5];
    [_insidePicView.layer setCornerRadius:5];
    UIColor *backgroundColor = [UIColor whiteColor];
    //UIColor *backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [_insidePicView setBackgroundColor:backgroundColor];
    [_picView setBackgroundColor:backgroundColor];
    
    _picNum = 0;
}

- (void)addPic:(UIImage *)img {
    if(_picNum >= 2){
        [_insidePicView setFrame:CGRectMake(0, 0, 110 * (_picNum + 1) + 10, 120)];
        [_picView setContentSize:_insidePicView.frame.size];
    }
    
    UIImageView *newPicView = [[UIImageView alloc] initWithFrame:[self frameAtIndex:_picNum]];
    [newPicView setImage:img];
    [newPicView.layer setCornerRadius:5];
    [newPicView.layer setMasksToBounds:YES];
    
    ImageSender *tapGesture = [[ImageSender alloc] initWithTarget:self
                                                                   action:@selector(showFullImage:)];
    
    tapGesture.image = img;
    [newPicView setUserInteractionEnabled: YES];
    [newPicView addGestureRecognizer:tapGesture];
    
    [_insidePicView addSubview:newPicView];
    _picNum ++;
}

- (void)showFullImage:(ImageSender *)sender{
    if(self.showImageBlock)
        self.showImageBlock(sender.image);
    
}

- (CGRect)frameAtIndex:(int)i {
    return CGRectMake(10 + 110 * i, 10, 100, 100);
}




@end

