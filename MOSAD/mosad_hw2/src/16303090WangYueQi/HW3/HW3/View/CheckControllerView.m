//
//  CheckControllerView.m
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckControllerView.h"

@implementation CheckControllerView

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,40, 30)];
        _label.font = [UIFont systemFontOfSize:16];
        _label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_label];
        /*
        _text = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 30)];
        _text.borderStyle = UITextBorderStyleRoundedRect;
        _text.returnKeyType = UIReturnKeyDefault;
        
        
        
        [_text setEnabled:YES];
        //[_text becomeFirstResponder];
        [self.contentView addSubview:_text];
         */
         
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(!textField.window.isKeyWindow){
        [textField.window makeKeyAndVisible];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    return YES;
}




@end


