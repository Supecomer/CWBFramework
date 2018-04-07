
#ifndef __MGExtensionConst__H__
#define __MGExtensionConst__H__

#import <Foundation/Foundation.h>

// 过期
#define MGExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define MGExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setMG_error:error];

// 日志输出
#ifdef DEBUG
#define MGExtensionLog(...) NSLog(__VA_ARGS__)
#else
#define MGExtensionLog(...)
#endif

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define MGExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setMG_error:nil]; \
if ((condition) == NO) { \
    MGExtensionBuildError(clazz, msg); \
    return returnValue;\
}

#define MGExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define MGExtensionAssert(condition) MGExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define MGExtensionAssertParamNotNil2(param, returnValue) \
MGExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define MGExtensionAssertParamNotNil(param) MGExtensionAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define MGLogAllIvars \
-(NSString *)description \
{ \
    return [self MG_keyValues].description; \
}
#define MGExtensionLogAllProperties MGLogAllIvars

/**
 *  类型（属性类型）
 */
extern NSString *const MGPropertyTypeInt;
extern NSString *const MGPropertyTypeShort;
extern NSString *const MGPropertyTypeFloat;
extern NSString *const MGPropertyTypeDouble;
extern NSString *const MGPropertyTypeLong;
extern NSString *const MGPropertyTypeLongLong;
extern NSString *const MGPropertyTypeChar;
extern NSString *const MGPropertyTypeBOOL1;
extern NSString *const MGPropertyTypeBOOL2;
extern NSString *const MGPropertyTypePointer;

extern NSString *const MGPropertyTypeIvar;
extern NSString *const MGPropertyTypeMethod;
extern NSString *const MGPropertyTypeBlock;
extern NSString *const MGPropertyTypeClass;
extern NSString *const MGPropertyTypeSEL;
extern NSString *const MGPropertyTypeId;

#endif
