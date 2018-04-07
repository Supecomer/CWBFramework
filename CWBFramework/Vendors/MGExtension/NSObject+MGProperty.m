//
//  NSObject+MGProperty.m
//  MGExtensionExample
//
//  Created by MG Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+MGProperty.h"
#import "NSObject+MGKeyValue.h"
#import "NSObject+MGCoding.h"
#import "NSObject+MGClass.h"
#import "MGProperty.h"
#import "MGFoundation.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static const char MGReplacedKeyFromPropertyNameKey = '\0';
static const char MGReplacedKeyFromPropertyName121Key = '\0';
static const char MGNewValueFromOldValueKey = '\0';
static const char MGObjectClassInArrayKey = '\0';

static const char MGCachedPropertiesKey = '\0';

@implementation NSObject (Property)

static NSMutableDictionary *replacedKeyFromPropertyNameDict_;
static NSMutableDictionary *replacedKeyFromPropertyName121Dict_;
static NSMutableDictionary *newValueFromOldValueDict_;
static NSMutableDictionary *objectClassInArrayDict_;
static NSMutableDictionary *cachedPropertiesDict_;

+ (void)load
{
    replacedKeyFromPropertyNameDict_ = [NSMutableDictionary dictionary];
    replacedKeyFromPropertyName121Dict_ = [NSMutableDictionary dictionary];
    newValueFromOldValueDict_ = [NSMutableDictionary dictionary];
    objectClassInArrayDict_ = [NSMutableDictionary dictionary];
    cachedPropertiesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    @synchronized (self) {
        if (key == &MGReplacedKeyFromPropertyNameKey) return replacedKeyFromPropertyNameDict_;
        if (key == &MGReplacedKeyFromPropertyName121Key) return replacedKeyFromPropertyName121Dict_;
        if (key == &MGNewValueFromOldValueKey) return newValueFromOldValueDict_;
        if (key == &MGObjectClassInArrayKey) return objectClassInArrayDict_;
        if (key == &MGCachedPropertiesKey) return cachedPropertiesDict_;
        return nil;
    }
}

#pragma mark - --私有方法--
+ (id)propertyKey:(NSString *)propertyName
{
    MGExtensionAssertParamNotNil2(propertyName, nil);
    
    __block id key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(MG_replacedKeyFromPropertyName121:)]) {
        key = [self MG_replacedKeyFromPropertyName121:propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName121:)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName121) withObject:propertyName];
    }
    
    // 调用block
    if (!key) {
        [self MG_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            MGReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &MGReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(MG_replacedKeyFromPropertyName)]) {
        key = [self MG_replacedKeyFromPropertyName][propertyName];
    }
    // 兼容旧版本
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName)][propertyName];
    }
    
    if (!key || [key isEqual:propertyName]) {
        [self MG_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MGReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key && ![key isEqual:propertyName]) *stop = YES;
        }];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)propertyObjectClassInArray:(NSString *)propertyName
{
    __block id clazz = nil;
    if ([self respondsToSelector:@selector(MG_objectClassInArray)]) {
        clazz = [self MG_objectClassInArray][propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        clazz = [self performSelector:@selector(objectClassInArray)][propertyName];
    }
    
    if (!clazz) {
        [self MG_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MGObjectClassInArrayKey);
            if (dict) {
                clazz = dict[propertyName];
            }
            if (clazz) *stop = YES;
        }];
    }
    
    // 如果是NSString类型
    if ([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    return clazz;
}

#pragma mark - --公共方法--
+ (void)MG_enumerateProperties:(MGPropertiesEnumeration)enumeration
{
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (MGProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

#pragma mark - 公共方法
+ (NSMutableArray *)properties
{
    NSMutableArray *cachedProperties = [self dictForKey:&MGCachedPropertiesKey][NSStringFromClass(self)];
    
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self MG_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                MGProperty *property = [MGProperty cachedPropertyWithProperty:properties[i]];
                // 过滤掉Foundation框架类里面的属性
                if ([MGFoundation isClassFromFoundation:property.srcClass]) continue;
                property.srcClass = c;
                [property setOriginKey:[self propertyKey:property.name] forClass:self];
                [property setObjectClassInArray:[self propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        
        [self dictForKey:&MGCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
    }
    
    return cachedProperties;
}

#pragma mark - 新值配置
+ (void)MG_setupNewValueFromOldValue:(MGNewValueFromOldValue)newValueFormOldValue
{
    objc_setAssociatedObject(self, &MGNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)MG_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(MGProperty *__unsafe_unretained)property{
    // 如果有实现方法
    if ([object respondsToSelector:@selector(MG_newValueFromOldValue:property:)]) {
        return [object MG_newValueFromOldValue:oldValue property:property];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(newValueFromOldValue:property:)]) {
        return [self performSelector:@selector(newValueFromOldValue:property:)  withObject:oldValue  withObject:property];
    }
    
    // 查看静态设置
    __block id newValue = oldValue;
    [self MG_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        MGNewValueFromOldValue block = objc_getAssociatedObject(c, &MGNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)MG_setupObjectClassInArray:(MGObjectClassInArray)objectClassInArray
{
    [self MG_setupBlockReturnValue:objectClassInArray key:&MGObjectClassInArrayKey];
    
    [[self dictForKey:&MGCachedPropertiesKey] removeAllObjects];
}

#pragma mark - key配置
+ (void)MG_setupReplacedKeyFromPropertyName:(MGReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self MG_setupBlockReturnValue:replacedKeyFromPropertyName key:&MGReplacedKeyFromPropertyNameKey];
    
    [[self dictForKey:&MGCachedPropertiesKey] removeAllObjects];
}

+ (void)MG_setupReplacedKeyFromPropertyName121:(MGReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    objc_setAssociatedObject(self, &MGReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [[self dictForKey:&MGCachedPropertiesKey] removeAllObjects];
}
@end

@implementation NSObject (MGPropertyDeprecated_v_2_5_16)
+ (void)enumerateProperties:(MGPropertiesEnumeration)enumeration
{
    [self MG_enumerateProperties:enumeration];
}

+ (void)setupNewValueFromOldValue:(MGNewValueFromOldValue)newValueFormOldValue
{
    [self MG_setupNewValueFromOldValue:newValueFormOldValue];
}

+ (id)getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained MGProperty *)property
{
    return [self MG_getNewValueFromObject:object oldValue:oldValue property:property];
}

+ (void)setupReplacedKeyFromPropertyName:(MGReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self MG_setupReplacedKeyFromPropertyName:replacedKeyFromPropertyName];
}

+ (void)setupReplacedKeyFromPropertyName121:(MGReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    [self MG_setupReplacedKeyFromPropertyName121:replacedKeyFromPropertyName121];
}

+ (void)setupObjectClassInArray:(MGObjectClassInArray)objectClassInArray
{
    [self MG_setupObjectClassInArray:objectClassInArray];
}
@end

#pragma clang diagnostic pop
