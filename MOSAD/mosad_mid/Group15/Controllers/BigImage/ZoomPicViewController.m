//
//  ZoomPicViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "ZoomPicViewController.h"

@interface ZoomPicViewController ()

@end

@implementation ZoomPicViewController

- (void)loadView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view = imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIImageView *imageView = (UIImageView *)self.view;
    imageView.image = self.image;
}



@end
