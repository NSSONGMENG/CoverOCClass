//
//  CoverClassTool.h
//  CoverOCClassDemo
//
//  Created by song.meng on 2022/9/21.
//
// 需考虑两个类的成员变量问题，该工具仅处理函数，不处理成员变量
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CoverRiskLevel) {
    CoverRiskLevelLow,      // 成员变量顺序相同，且布局相同
    CoverRiskLevelAccept,   // 成员变量顺序不同，强弱引用相同
    CoverRiskLevelMiddle,   // 成员变量相同，强弱引用不相同
    CoverRiskLevelHigh,     // 成员变量不相同，个数不同，名字不同
};


@interface CoverClassTool : NSObject


/// 使用uClass覆盖cClass，将uClass的所有函数添加到cClass，合并替换掉cClass中方法相同的实现
/// - Parameters:
///   - uClass: 覆盖class
///   - cClass: 被覆盖class
+ (void)useClass:(Class)uClass coverClass:(Class)cClass;


/// 获取某个类的所有函数
/// - Parameter cls: 目标类
+ (NSSet <NSString *>*)getClassMethods:(Class)cls;


/// 获取某个类的所有成员变量名
/// - Parameter cls: 目标类
+ (NSSet <NSString *>*)getInstanceIvars:(Class)cls;

/// 检查用uClass的方法覆盖cClass的风险等级
+ (CoverRiskLevel)getRiskLevelWithClass:(Class)uClass beCoveredClass:(Class)cClass;

@end

NS_ASSUME_NONNULL_END
