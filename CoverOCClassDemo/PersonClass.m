//
//  PersonClass.m
//  CoverOCClassDemo
//
//  Created by song.meng on 2022/9/21.
//

#import "PersonClass.h"

@implementation PersonClass

- (void)study {
    NSLog(@"person instance study : %@", self.name);
}

+ (void)study {
    NSLog(@"person class study");
}

@end
