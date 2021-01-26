//
//  DWPasswordNumberButton.m
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "DWPasswordNumberButton.h"

@interface DWPasswordNumberButton()

@end

@implementation DWPasswordNumberButton

- (instancetype)initWithFrame:(CGRect)frame number:(NSUInteger)number {
    self = [[self class] buttonWithType:UIButtonTypeCustom];
    if (self) {
        [self setFrame:frame];
        [self setTitle:[NSString stringWithFormat:@"%lu", number] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont fontWithName:@"CourierNewPSMT" size:36];
        
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorRef = CGColorCreate(colorSpace, (CGFloat[]){0, 0, 0, 1});
        self.layer.borderColor = colorRef;
        
        [self setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    }
    return self;
}

//  颜色转换为背景图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
