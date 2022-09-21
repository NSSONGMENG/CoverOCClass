//
//  PersonClass.h
//  CoverOCClassDemo
//
//  Created by song.meng on 2022/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonClass : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *age1;

- (void)study;
+ (void)study;

@end

NS_ASSUME_NONNULL_END
