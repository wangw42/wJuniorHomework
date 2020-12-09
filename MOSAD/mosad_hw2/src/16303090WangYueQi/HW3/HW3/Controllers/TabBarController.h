//
//  TabBarController.h
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#ifndef TabBarController_h
#define TabBarController_h

#import <UIKit/UIKit.h>



@interface TabBarController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UIColor *themeColor;

@end


#endif /* TabBarController_h */
