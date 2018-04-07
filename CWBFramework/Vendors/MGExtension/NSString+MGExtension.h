//
//  NSString+MGExtension.h
//  MGExtensionExample
//
//  Created by MG Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGExtensionConst.h"

@interface NSString (MGExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)MG_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)MG_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)MG_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)MG_firstCharLower;

- (BOOL)MG_isPureInt;

- (NSURL *)MG_url;
@end

@interface NSString (MGExtensionDeprecated_v_2_5_16)
- (NSString *)underlineFromCamel MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
- (NSString *)camelFromUnderline MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
- (NSString *)firstCharUpper MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
- (NSString *)firstCharLower MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
- (BOOL)isPureInt MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
- (NSURL *)url MGExtensionDeprecated("请在方法名前面加上MG_前缀，使用MG_***");
@end
