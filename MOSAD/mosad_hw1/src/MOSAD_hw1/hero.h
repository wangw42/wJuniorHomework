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
- (BOOL)kill :  (Hero*) h2;

@end


@interface Liubei : Hero {
}
- (void) liukill : (Hero*) ene;

@end


@interface Sunquan : Hero {
}
- (void) sunkill : (Hero*) ene;
@end


@interface Caocao : Hero {
}
- (void) caokill : (Hero*) ene;
@end



NS_ASSUME_NONNULL_END

#endif /* hero_h */
