//
//  CarClass.m
//  CoverOCClassDemo
//
//  Created by song.meng on 2022/9/21.
//

#import "CarClass.h"

@implementation CarClass

- (instancetype)init {
    if (self = [super init]) {
        _name = @"car";
    }
    return self;
}

- (void)study {
    NSLog(@"car instance study");
}

+ (void)study {
    NSLog(@"car class study");
}


@end
