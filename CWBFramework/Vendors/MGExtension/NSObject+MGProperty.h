//
//  NSObject+MGProperty.h
//  MGExtensionExample
//
//  Created by MG Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGExtensionConst.h"

@class MGProperty;

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^MGPropertiesEnumeration)(MGProperty *property, BOOL *stop);

/** 将属性名换为其他key去字典中取值 */
typedef NSDictionary * (^MGReplacedKeyFromPropertyName)(void);
typedef id (^MGReplacedKeyFromPropertyName121)(NSString *propertyName);
/** 数组中需要转换的模型类 */
typedef NSDictionary * (^MGObjectClassInArray)(void);
/** 用于过滤字典中的值 */
typedef id (^MGNewValueFromOldValue)(id object, id oldValue, MGProperty *property);

/**
 * 成员属性相关的扩展
 */
@interface NSObject (MGProperty)
#pragma mark - 遍历
/**
 *  遍历所有的成员
 */
+ (void)MG_enumerateProperties:(MGPropertiesEnumeration)enumeration;

#pragma mark - 新值配置
/**
 *  用于过滤字典中的值
 *
 *  @param newValueFormOldValue 用于过滤字典中的值
 */
+ (void)MG_setupNewValueFromOldValue:(MGNewValueFromOldValue)newValueFormOldValue;
+ (id)MG_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained MGProperty *)property;

#pragma mark - key配置
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName 将属性名换为其他key去字典中取值
 */
+ (void)MG_setupReplacedKeyFromPropertyName:(MGReplacedKeyFromPropertyName)replacedKeyFromPropertyName;
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName121 将属性名换为其他key去字典中取值
 */
+ (void)MG_setupReplacedKeyFromPropertyName121:(MGReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121;

#pragma mark - array model class配置
/**
 *  数组中需要转换的模型类
 *
 *  @param objectClassInArray          数组中需要转换的模型类
 */
+ (void)MG_setupObjectClassInArray:(MGObjectClassInArray)objectClassInArray;
@end

@interface NSObject (MGPropertyDeprecated_v_2_5_16)
+ (void)enumerateProperties:(MGPropertiesEnumeration)enumeration MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
+ (void)setupNewValueFromOldValue:(MGNewValueFromOldValue)newValueFormOldValue MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
+ (id)getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained MGProperty *)property MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
+ (void)setupReplacedKeyFromPropertyName:(MGReplacedKeyFromPropertyName)replacedKeyFromPropertyName MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
+ (void)setupReplacedKeyFromPropertyName121:(MGReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121 MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
+ (void)setupObjectClassInArray:(MGObjectClassInArray)objectClassInArray MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
@end
