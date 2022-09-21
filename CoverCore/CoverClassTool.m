//
//  CoverClassTool.m
//  CoverOCClassDemo
//
//  Created by song.meng on 2022/9/21.
//

#import "CoverClassTool.h"
#import <objc/runtime.h>

@implementation CoverClassTool

/// 使用uClass覆盖cClass，将uClass的所有函数添加到cClass，合并替换掉cClass中方法相同的实现
/// - Parameters:
///   - uClass: 覆盖class
///   - cClass: 被覆盖class
+ (void)useClass:(Class)uClass coverClass:(Class)cClass {
    NSAssert([uClass isKindOfClass:[NSObject class]], @"uClass should subclass of NSObject");
    NSAssert([cClass isKindOfClass:[NSObject class]], @"uClass should subclass of NSObject");
    
    
    void(^coverClass)(Class, Class) = ^(Class ucls, Class ccls){
        unsigned int uCount;
        Method *uList = class_copyMethodList(ucls, &uCount);
        
        for (int i = 0; i < uCount; i++) {
            Method m = uList[i];
            SEL sel = method_getName(m);
            
            // 实例方法
            if (class_getInstanceMethod(ccls, sel)) {
                class_replaceMethod(ccls, sel, method_getImplementation(m), method_getTypeEncoding(m));
            } else {
                class_addMethod(ccls, sel, method_getImplementation(m), method_getTypeEncoding(m));
            }
        }
        free(uList);
    };
    
    // 处理对象方法
    coverClass(uClass, cClass);
    
    Class umCls = objc_getMetaClass(NSStringFromClass(uClass).UTF8String);
    Class cmCls = objc_getMetaClass(NSStringFromClass(cClass).UTF8String);
    
    // 处理类方法
    coverClass(umCls, cmCls);
}


/// 获取某个类的所有函数
+ (NSSet <NSString *>*)getClassMethods:(Class)cls {
    unsigned int count;
    Method *list = class_copyMethodList(cls, &count);
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:count];
    for (int i = 1; i < count; i ++){
        Method m = list[i];
        SEL sel = method_getName(m);

        if (sel) {
            [set addObject:NSStringFromSelector(sel)];
        }
    }
    
    free(list);
    return set.copy;
}


+ (NSSet <NSString *>*)getInstanceIvars:(Class)cls {
    unsigned int count;
    Ivar *list = class_copyIvarList(cls, &count);
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:count];
    
    for (int i = 0; i < count; i ++) {
        Ivar v = list[i];
        const char *name = ivar_getName(v);
        [set addObject:[NSString stringWithUTF8String:name]];
    }
    
    free(list);
    return set.copy;
}

/// 检查用uClass的方法覆盖cClass的风险等级
/// 仅检查实例类型的变量即可，类没有真正意义上的成员变量
+ (CoverRiskLevel)getRiskLevelWithClass:(Class)uClass beCoveredClass:(Class)cClass {
    unsigned int uCount;
    Ivar *uList = class_copyIvarList(uClass, &uCount);
    
    unsigned int cCount;
    Ivar *cList = class_copyIvarList(cClass, &cCount);

    // 1. 数量不同，高风险
    if (uCount != cCount) return CoverRiskLevelHigh;
    
    // 2. 变量名不全部相同，高风险
    NSMutableSet *varSet = [NSMutableSet setWithCapacity:uCount * 2];
    for (int i = 0; i < uCount; i++) {
        Ivar uv = uList[i];
        Ivar cv = cList[i];
        
        [varSet addObject:[NSString stringWithUTF8String:ivar_getName(uv)]];
        [varSet addObject:[NSString stringWithUTF8String:ivar_getName(cv)]];
    }
    if (varSet.count > uCount) return CoverRiskLevelHigh;
    
    // 布局
    const uint8_t *uLayout = class_getIvarLayout(uClass);
    const uint8_t *cLayout = class_getIvarLayout(cClass);

    BOOL sameOrder = YES;
    for (int i = 0; i < uCount; i++) {
        Ivar uv = uList[i];
        NSString *uName = [NSString stringWithUTF8String:ivar_getName(uv)];
        
        Ivar cv = cList[i];
        NSString *cName = [NSString stringWithUTF8String:ivar_getName(cv)];
        
        if (![uName isEqualToString:cName]) {
            sameOrder = NO;
            break;
        }
    }
    
    // 3. 布局相同，var顺序也相同，低风险
    if (sameOrder && uLayout == cLayout) return CoverRiskLevelLow;
    
    // 顺序不同，强弱引用
    [varSet removeAllObjects];
    
    void(^checkLayout)(Ivar *, const uint8_t *, BOOL) = ^(Ivar *list, const uint8_t *layout, BOOL inc) {
        unsigned int ivarIndex = 0;
        while (*layout != 0x00 || ivarIndex < uCount) {
            if (*layout != 0x00) {
                int weakCnt = (*layout & 0xf0) >> 4;
                int strongCnt = *layout & 0xf;
                int repeatCnt = weakCnt + strongCnt;
                
                while (repeatCnt > 0 && ivarIndex < uCount) {
                    Ivar var = list[ivarIndex++];
                    ptrdiff_t offset = ivar_getOffset(var);
                    if ((offset & 0b111) == 0) {
                        bool isStrong = weakCnt -- <= 0;
                        if (isStrong) {
                            NSString *strongVarName = [NSString stringWithUTF8String:ivar_getName(var)];
                            if (inc) {
                                [varSet addObject:strongVarName];
                            } else {
                                [varSet removeObject:strongVarName];
                            }
                        }
                        -- repeatCnt;
                    }
                }
                ++ layout;
            } else {
                // 全是weak
                while (ivarIndex < uCount) {
                    ivarIndex++;
                }
            }
        }
    };
    
    checkLayout(uList, uLayout, YES);
    checkLayout(cList, cLayout, NO);
    
    // 4. 强弱引用不同，中风险
    if (varSet.count) return CoverRiskLevelMiddle;
    
    // 5. 顺序不同，强弱引用相同，可接受（若顺序相同强弱引用也相同，则layout相同）
    return CoverRiskLevelAccept;
}

@end
