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
    
    [Hero PKOneUnit];

    
    //return UIApplicationMain(argc, argv, nil, appDelegateClassName);
    return 0;
}
