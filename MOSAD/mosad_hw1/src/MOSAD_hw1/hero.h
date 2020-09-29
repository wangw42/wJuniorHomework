//
//  hero.h
//  MOSAD_hw1
//
//  Created by Yqi on 2020/9/25.
//  Copyright © 2020 Yqi. All rights reserved.
//

#ifndef hero_h
#define hero_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Hero : NSObject {
    @private
    NSString *country;
    @private
    NSString *name;
    @public
    NSInteger blood_value;
    @public
    NSInteger energy_value;
}

- (NSInteger)getBlood_value;
- (NSInteger)getenergy_value;
- (NSString *)getCountry;
- (NSString *)getName;
- (BOOL)kill : (Hero*)h1 andEnemy: (Hero*) h2;

@end


@interface Liubei : Hero {
}

@end


@interface Sunquan : Hero {
}

@end


@interface Caocao : Hero {
}

@end



NS_ASSUME_NONNULL_END

#endif /* hero_h */
