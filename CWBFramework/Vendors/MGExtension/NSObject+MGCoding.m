//
//  NSObject+MGCoding.m
//  MGExtension
//
//  Created by MG on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "NSObject+MGCoding.h"
#import "NSObject+MGClass.h"
#import "NSObject+MGProperty.h"
#import "MGProperty.h"

@implementation NSObject (MGCoding)

- (void)MG_encode:(NSCoder *)encoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz MG_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz MG_totalIgnoredCodingPropertyNames];
    
    [clazz MG_enumerateProperties:^(MGProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)MG_decode:(NSCoder *)decoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz MG_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz MG_totalIgnoredCodingPropertyNames];
    
    [clazz MG_enumerateProperties:^(MGProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) { // 兼容以前的MGExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
