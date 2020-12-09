//
//  CheckControllerView.h
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#ifndef CheckControllerView_h
#define CheckControllerView_h

#import <UIKit/UIKit.h>

@interface CheckControllerView : UICollectionViewCell < UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic)    UILabel *label;
//@property (strong,nonatomic)    UITextField *text;

@end

#endif /* CheckControllerView_h */
