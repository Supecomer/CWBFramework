//
//  MGPropertyType.m
//  MGExtension
//
//  Created by MG on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MGPropertyType.h"
#import "MGExtension.h"
#import "MGFoundation.h"
#import "MGExtensionConst.h"

@implementation MGPropertyType

static NSMutableDictionary *types_;
+ (void)initialize
{
    types_ = [NSMutableDictionary dictionary];
}

+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    MGExtensionAssertParamNotNil2(code, nil);
    @synchronized (self) {
        MGPropertyType *type = types_[code];
        if (type == nil) {
            type = [[self alloc] init];
            type.code = code;
            types_[code] = type;
        }
        return type;
    }
}

#pragma mark - 公共方法
- (void)setCode:(NSString *)code
{
    _code = code;
    
    MGExtensionAssertParamNotNil(code);
    
    if ([code isEqualToString:MGPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [MGFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:MGPropertyTypeSEL] ||
               [code isEqualToString:MGPropertyTypeIvar] ||
               [code isEqualToString:MGPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[MGPropertyTypeInt, MGPropertyTypeShort, MGPropertyTypeBOOL1, MGPropertyTypeBOOL2, MGPropertyTypeFloat, MGPropertyTypeDouble, MGPropertyTypeLong, MGPropertyTypeLongLong, MGPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:MGPropertyTypeBOOL1]
            || [lowerCode isEqualToString:MGPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end
