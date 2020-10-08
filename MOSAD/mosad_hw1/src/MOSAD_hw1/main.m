//
//  main.m
//  MOSAD_hw1
//
//  Created by Yqi on 2020/9/18.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "hero.h"

// 不log时间戳
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

int main(int argc, char * argv[]) {
    /*
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
     */

    int M = (rand() % 10) + 1;
    int round = 1;
    while(M--){
        Liubei *l = [Liubei new];
        Sunquan *s = [Sunquan new];
        Caocao *c = [Caocao new];
        
        NSLog(@"------- Round: %d -------", round++);
        
        Hero * heros[3] = {l,s,c};
        
        int rand_num = (int)random()%3;
        int rand_num2 = (int)random()%3;
        while(rand_num2 == rand_num)
            rand_num2 = (int)random()%3;
        
        Hero * h1 = heros[rand_num];
        Hero * h2 = heros[rand_num2];
        NSLog(@"Hero1: %@, blood%ld, energy%ld; Heros2: %@, blood%ld, energy%ld", [h1 getName], (long)[h1 getBlood_value], (long)[h1 getenergy_value], [h2 getName], (long)[h2 getBlood_value], (long)[h2 getenergy_value]);
        
        while([h1 getBlood_value] > 0 && [h2 getBlood_value] > 0){
            bool flag1 = [h1 kill:h2];
            if(!flag1){
                NSLog(@"%@体力不支，失败！", [h1 getName]);
                break;
            }
            NSLog(@"攻击者: %@, blood%ld, energy%ld; 受害者: %@, blood%ld, energy%ld", [h1 getName], (long)[h1 getBlood_value], (long)[h1 getenergy_value], [h2 getName], (long)[h2 getBlood_value], (long)[h2 getenergy_value]);
            bool flag2 = [h2 kill:h1];
            if(!flag2){
                NSLog(@"%@体力不支，失败！", [h2 getName]);
                break;
            }
            NSLog(@"攻击者: %@, blood%ld, energy%ld; 受害者: %@, blood%ld, energy%ld", [h2 getName], (long)[h2 getBlood_value], (long)[h2 getenergy_value], [h1 getName], (long)[h1 getBlood_value], (long)[h1 getenergy_value]);
        }
        if([h1 getBlood_value] > [h2 getBlood_value]) {
            NSLog(@"获胜者是：%@", [h1 getName]);
        }else if([h1 getBlood_value] == [h2 getBlood_value]) {
            NSLog(@"平局！");
        }
        
    }

    
    //return UIApplicationMain(argc, argv, nil, appDelegateClassName);
    return 0;
}
