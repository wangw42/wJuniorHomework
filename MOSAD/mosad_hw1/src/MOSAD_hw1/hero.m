//
//  hero.m
//  MOSAD_hw1
//
//  Created by Yqi on 2020/9/25.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "hero.h"

// 不log时间戳
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

@interface Hero();

@end

@implementation Hero

- (instancetype)init{
    blood_value = 10;
    energy_value = 10;
    return self;
}




- (NSInteger)getBlood_value{
    return blood_value;
};

- (NSInteger)getenergy_value{
    return energy_value;
};

- (NSString *)getCountry{
    return country;
};
- (NSString *)getName{
    return name;
};

- (BOOL)kill : (Hero*)h1 andEnemy: (Hero*) h2{
    return NO;
};


@end


@implementation Liubei : Hero

- (instancetype)init{
    if(self = [super init]){
        self->blood_value = 10;
        self->energy_value = 12;
    }
    return self;
}

- (NSString *)getCountry{
    return @"蜀";
};

- (NSString *)getName{
    return @"刘备";
};

- (void) liukill : (Hero*) ene {
    NSLog(@"刘备发起了攻击: 以德服人，造成3点伤害，消耗4点法力值。");
    ene->blood_value -= 3;
    self->energy_value -= 4;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self liukill:h2];
    return true;
};



@end


@implementation Sunquan : Hero


- (instancetype)init{
    if(self = [super init]){
        self->blood_value = 10;
        self->energy_value = 10;
    }
    return self;
}

- (NSString *)getCountry{
    return @"汉";
};

- (NSString *)getName{
    return @"孙权";
};

- (void) sunkill : (Hero*) ene {
    NSLog(@"孙权发起了攻击: 制衡，造成2点伤害，消耗2点法力值。");
    ene->blood_value -= 2;
    self->energy_value -= 2;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self sunkill:h2];
    return true;
};



@end


@implementation Caocao : Hero


- (instancetype) init {
    if(self = [super init]){
        self->blood_value = 10;
        self->energy_value = 8;
    }
    return self;
}


- (NSString *)getCountry{
    return @"魏";
};

- (NSString *)getName{
    return @"曹操";
};

- (void) caokill : (Hero*) ene {
    NSLog(@"曹操发起了攻击: 梦中杀人，造成1点伤害，吸走对方1点法力值。");
    ene->blood_value -= 1;
    ene->energy_value -= 1;
};

- (BOOL)kill :(Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self caokill:h2];
    return true;
};


@end
