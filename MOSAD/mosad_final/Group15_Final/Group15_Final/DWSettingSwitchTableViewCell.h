//
//  DWSettingSwitchTableViewCell.h
//  Group15_Final
//
//  Created by Yqi on 2020/12/28.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWSettingSwitchCellDelegate <NSObject>

- (void)switcherValueChanged:(UISwitch *)sender;

@end

@interface DWSettingSwitchTableViewCell : UITableViewCell

@property (strong, nonatomic) UISwitch *switcher;
@property (weak, nonatomic) id<DWSettingSwitchCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)title;

@end
