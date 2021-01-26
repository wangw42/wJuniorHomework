//
//  DWDiaryTableViewCell.m
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "DWDiaryTableViewCell.h"
#import "DWDiaryCellContentView.h"

#define DWScreenWidth [UIScreen mainScreen].bounds.size.width

@interface DWDiaryTableViewCell()

@property (strong, nonatomic) DWDiaryCellContentView *cellContentView;

@end

@implementation DWDiaryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        _cellContentView = [[DWDiaryCellContentView alloc] initWithFrame:CGRectMake(8, 8, DWScreenWidth - 16, 74)];
        [self.contentView addSubview:_cellContentView];
        
    }
    return self;
}

- (void)setDicDate:(NSDictionary *)dicDate {
    if (dicDate) {
        _dicDate = dicDate;
        _cellContentView.dicDate = dicDate;
    }
}

- (void)setTitle:(NSString *)title {
    if (title) {
        _title = title;
        _cellContentView.title = title;
    }
}

- (void)setDetail:(NSString *)detail {
    if (detail) {
        _detail = detail;
        _cellContentView.detail = detail;
    }
}

- (void)setEmotion:(NSString *)emotion {
    if (emotion) {
        _emotion = emotion;
        _cellContentView.emotion = emotion;
    }
}

- (void)setWeather:(NSString *)weather {
    if (weather) {
        _weather = weather;
        _cellContentView.weather = weather;
    }
}

@end
