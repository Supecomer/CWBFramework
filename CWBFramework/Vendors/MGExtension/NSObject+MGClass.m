//
//  NSObject+MGClass.m
//  MGExtensionExample
//
//  Created by MG Lee on 15/8/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+MGClass.h"
#import "NSObject+MGCoding.h"
#import "NSObject+MGKeyValue.h"
#import "MGFoundation.h"
#import <objc/runtime.h>

static const char MGAllowedPropertyNamesKey = '\0';
static const char MGIgnoredPropertyNamesKey = '\0';
static const char MGAllowedCodingPropertyNamesKey = '\0';
static const char MGIgnoredCodingPropertyNamesKey = '\0';

static NSMutableDictionary *allowedPropertyNamesDict_;
static NSMutableDictionary *ignoredPropertyNamesDict_;
static NSMutableDictionary *allowedCodingPropertyNamesDict_;
static NSMutableDictionary *ignoredCodingPropertyNamesDict_;

@implementation NSObject (MGClass)

+ (void)load
{
    allowedPropertyNamesDict_ = [NSMutableDictionary dictionary];
    ignoredPropertyNamesDict_ = [NSMutableDictionary dictionary];
    allowedCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
    ignoredCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    @synchronized (self) {
        if (key == &MGAllowedPropertyNamesKey) return allowedPropertyNamesDict_;
        if (key == &MGIgnoredPropertyNamesKey) return ignoredPropertyNamesDict_;
        if (key == &MGAllowedCodingPropertyNamesKey) return allowedCodingPropertyNamesDict_;
        if (key == &MGIgnoredCodingPropertyNamesKey) return ignoredCodingPropertyNamesDict_;
        return nil;
    }
}

+ (void)MG_enumerateClasses:(MGClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([MGFoundation isClassFromFoundation:c]) break;
    }
}

+ (void)MG_enumerateAllClasses:(MGClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
    }
}

#pragma mark - 属性黑名单配置
+ (void)MG_setupIgnoredPropertyNames:(MGIgnoredPropertyNames)ignoredPropertyNames
{
    [self MG_setupBlockReturnValue:ignoredPropertyNames key:&MGIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)MG_totalIgnoredPropertyNames
{
    return [self MG_totalObjectsWithSelector:@selector(MG_ignoredPropertyNames) key:&MGIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置
+ (void)MG_setupIgnoredCodingPropertyNames:(MGIgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self MG_setupBlockReturnValue:ignoredCodingPropertyNames key:&MGIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)MG_totalIgnoredCodingPropertyNames
{
    return [self MG_totalObjectsWithSelector:@selector(MG_ignoredCodingPropertyNames) key:&MGIgnoredCodingPropertyNamesKey];
}

#pragma mark - 属性白名单配置
+ (void)MG_setupAllowedPropertyNames:(MGAllowedPropertyNames)allowedPropertyNames;
{
    [self MG_setupBlockReturnValue:allowedPropertyNames key:&MGAllowedPropertyNamesKey];
}

+ (NSMutableArray *)MG_totalAllowedPropertyNames
{
    return [self MG_totalObjectsWithSelector:@selector(MG_allowedPropertyNames) key:&MGAllowedPropertyNamesKey];
}

#pragma mark - 归档属性白名单配置
+ (void)MG_setupAllowedCodingPropertyNames:(MGAllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self MG_setupBlockReturnValue:allowedCodingPropertyNames key:&MGAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)MG_totalAllowedCodingPropertyNames
{
    return [self MG_totalObjectsWithSelector:@selector(MG_allowedCodingPropertyNames) key:&MGAllowedCodingPropertyNamesKey];
}
#pragma mark - block和方法处理:存储block的返回值
+ (void)MG_setupBlockReturnValue:(id (^)(void))block key:(const char *)key
{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 清空数据
    [[self dictForKey:key] removeAllObjects];
}

+ (NSMutableArray *)MG_totalObjectsWithSelector:(SEL)selector key:(const char *)key
{
    NSMutableArray *array = [self dictForKey:key][NSStringFromClass(self)];
    if (array) return array;
    
    // 创建、存储
    [self dictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
        if (subArray) {
            [array addObjectsFromArray:subArray];
        }
    }
    
    [self MG_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}
@end
