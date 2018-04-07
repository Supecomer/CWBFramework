#ifndef __MGExtensionConst__M__
#define __MGExtensionConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const MGPropertyTypeInt = @"i";
NSString *const MGPropertyTypeShort = @"s";
NSString *const MGPropertyTypeFloat = @"f";
NSString *const MGPropertyTypeDouble = @"d";
NSString *const MGPropertyTypeLong = @"l";
NSString *const MGPropertyTypeLongLong = @"q";
NSString *const MGPropertyTypeChar = @"c";
NSString *const MGPropertyTypeBOOL1 = @"c";
NSString *const MGPropertyTypeBOOL2 = @"b";
NSString *const MGPropertyTypePointer = @"*";

NSString *const MGPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const MGPropertyTypeMethod = @"^{objc_method=}";
NSString *const MGPropertyTypeBlock = @"@?";
NSString *const MGPropertyTypeClass = @"#";
NSString *const MGPropertyTypeSEL = @":";
NSString *const MGPropertyTypeId = @"@";

#endif
