//
//  ButtonBar.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "ButtonBar.h"

@implementation ButtonBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initButtons];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initButtons {
    [_loadBtn setTitle:@"加载" forState:UIControlStateNormal];
    _loadBtn.layer.cornerRadius = 3;
    _loadBtn.layer.masksToBounds = YES;
    
    [_cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
    _cleanBtn.layer.cornerRadius = 3;
    _cleanBtn.layer.masksToBounds = YES;
    
    [_delCacheBtn setTitle:@"删除缓存" forState:UIControlStateNormal];
    _delCacheBtn.layer.cornerRadius = 3;
    _delCacheBtn.layer.masksToBounds = YES;
}

@end
