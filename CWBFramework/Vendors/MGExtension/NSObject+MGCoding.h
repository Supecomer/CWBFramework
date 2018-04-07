//
//  NSObject+MGCoding.h
//  MGExtension
//
//  Created by MG on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGExtensionConst.h"

/**
 *  Codeing协议
 */
@protocol MGCoding <NSObject>
@optional
/**
 *  这个数组中的属性名才会进行归档
 */
+ (NSArray *)MG_allowedCodingPropertyNames;
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSArray *)MG_ignoredCodingPropertyNames;
@end

@interface NSObject (MGCoding) <MGCoding>
/**
 *  解码（从文件中解析对象）
 */
- (void)MG_decode:(NSCoder *)decoder;
/**
 *  编码（将对象写入文件中）
 */
- (void)MG_encode:(NSCoder *)encoder;
@end

/**
 归档的实现
 */
#define MGCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self MG_decode:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self MG_encode:encoder]; \
}

#define MGExtensionCodingImplementation MGCodingImplementation
