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


+ (void) PKOneUnit{
  
    int M = (rand() % 10) + 1;
    int round = 1;
    while(M--){
        Liubei *l = [Liubei new];
        Guanyu * g = [Guanyu new];
        Zhangfei * z = [Zhangfei new];
        Machao * m = [Machao new];
        Sunquan *s = [Sunquan new];
        Luxun *lx = [Luxun new];
        Zhouyu *zy = [Zhouyu new];
        Caocao *c = [Caocao new];
        Xiahoudun *xhd = [Xiahoudun new];
        Xunyu *xy = [Xunyu new];
        
        
        NSLog(@"------- Round: %d -------", round++);
        
        Hero * heros[10] = {l,s,c,g,z,m,lx,zy,xhd,xy};
        
        int rand_num = (int)random()%10;
        int rand_num2 = (int)random()%10;
        while(rand_num2 == rand_num)
            rand_num2 = (int)random()%10;
        
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
        }else if([h1 getBlood_value] < [h2 getBlood_value]) {
            NSLog(@"获胜者是：%@", [h2 getName]);
        }
        
    }
};

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

@implementation Zhangfei : Hero

- (instancetype)init{
    if(self = [super init]){
        self->blood_value = 8;
        self->energy_value = 12;
    }
    return self;
}

- (NSString *)getCountry{
    return @"蜀";
};

- (NSString *)getName{
    return @"张飞";
};

- (void) zhangkill : (Hero*) ene {
    NSLog(@"张飞发起了攻击: 画地为牢，恢复1点血量，消耗2点法力值。");
    ene->blood_value -= 3;
    self->energy_value -= 4;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self zhangkill:h2];
    return true;
};
@end


@implementation Guanyu : Hero

- (instancetype)init{
    if(self = [super init]){
        self->blood_value = 10;
        self->energy_value = 10;
    }
    return self;
}

- (NSString *)getCountry{
    return @"蜀";
};

- (NSString *)getName{
    return @"关羽";
};

- (void) guankill : (Hero*) ene {
    NSLog(@"关羽发起了攻击: 一骑当千，造成2点伤害，消耗2点法力值。");
    ene->blood_value -= 2;
    self->energy_value -= 2;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self guankill:h2];
    return true;
};
@end

@implementation Machao : Hero

- (instancetype)init{
    if(self = [super init]){
        self->blood_value = 12;
        self->energy_value = 12;
    }
    return self;
}

- (NSString *)getCountry{
    return @"蜀";
};

- (NSString *)getName{
    return @"马超";
};

- (void) makill : (Hero*) ene {
    NSLog(@"马超发起了攻击: 马刺，造成3点伤害，消耗3点法力值。");
    ene->blood_value -= 3;
    self->energy_value -= 3;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self makill:h2];
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

@implementation Luxun : Hero
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
    return @"陆逊";
};

- (void) lukill : (Hero*) ene {
    NSLog(@"陆逊发起了攻击: 乾坤，造成2点伤害，消耗2点法力值。");
    ene->blood_value -= 2;
    self->energy_value -= 2;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self lukill:h2];
    return true;
};

@end

@implementation Zhouyu : Hero
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
    return @"周瑜";
};

- (void) zhoukill : (Hero*) ene {
    NSLog(@"周瑜发起了攻击: 引燃，造成3点伤害，消耗3点法力值。");
    ene->blood_value -= 3;
    self->energy_value -= 3;
};

- (BOOL)kill : (Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self zhoukill:h2];
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

@implementation Xiahoudun : Hero

- (instancetype) init {
    if(self = [super init]){
        self->blood_value = 12;
        self->energy_value = 12;
    }
    return self;
}


- (NSString *)getCountry{
    return @"魏";
};

- (NSString *)getName{
    return @"夏侯惇";
};

- (void) xiakill : (Hero*) ene {
    NSLog(@"夏侯惇发起了攻击: 不羁之刃，造成3点伤害，消耗3点法力值。");
    ene->blood_value -= 3;
    ene->energy_value -= 3;
};

- (BOOL)kill :(Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self xiakill:h2];
    return true;
};

@end

@implementation Xunyu : Hero

- (instancetype) init {
    if(self = [super init]){
        self->blood_value = 10;
        self->energy_value = 10;
    }
    return self;
}


- (NSString *)getCountry{
    return @"魏";
};

- (NSString *)getName{
    return @"荀彧";
};

- (void) xunkill : (Hero*) ene {
    NSLog(@"荀彧发起了攻击: 驱虎，造成2点伤害，消耗2点法力值。");
    ene->blood_value -= 2;
    ene->energy_value -= 2;
};

- (BOOL)kill :(Hero*) h2{
    if(self->energy_value <= 0) return false;
    [self xunkill:h2];
    return true;
};

@end
