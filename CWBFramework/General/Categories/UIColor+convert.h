/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： UIColor+convert.h
 * 内容摘要： 颜色转换
 * 其它说明：
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(convert)

/* 16进制颜色(html颜色值)字符串转为UIColor */
+ (UIColor *)hexStringToColor:(NSString *)stringToConvert alpha:(float)alpha;

@end
