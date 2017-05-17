/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： UtilsMacro.h
 * 内容摘要： 常用宏定义方法
 * 其它说明： 全部以 COM_  打头
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/
#ifndef UtilsMacro_h
#define UtilsMacro_h


//----------------------颜色类---------------------------
// rgb颜色转换（16进制->10进制）
#define COM_UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//带有RGBA的颜色设置
#define COM_COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

//由角度获取弧度 有弧度获取角度
#define COM_degreesToRadian(x) (M_PI * (x) / 180.0)
#define COM_radianToDegrees(radian) (radian*180.0)/(M_PI)


/* 判定字符串是否为空 */
#define COM_STRING_ISNIL(__POINTER) ((__POINTER == nil || [__POINTER isEqualToString:@""])?YES:NO)
#define COM_STRING_ISNOTNIL(__POINTER) ((__POINTER == nil || [__POINTER isEqualToString:@""])?NO:YES)


/* 自定义国际化 */

#define  COM_LocalString(str)          NSLocalizedString(str,nil)


/* 常用设置 -----------*/
#define COM_NumberInt(x)             [NSNumber numberWithInt:x]
#define COM_NumberBool(x)            [NSNumber numberWithBool:x]
#define COM_NumberFloat(x)           [NSNumber numberWithFloat:x]
#define COM_NumberDouble(x)          [NSNumber numberWithDouble:x]
#define COM_StringInt(x)             [NSString stringWithFormat:@"%d", x]
#define COM_StringLong(x)            [NSString stringWithFormat:@"%ld", x]
#define COM_StringFloat(x)           [NSString stringWithFormat:@"%f", x]
#define COM_ImageNamed(x)            [UIImage imageNamed:x]
#define COM_FontSystem(x)            [UIFont systemFontOfSize:x]
#define COM_FontBoldSystem(x)        [UIFont boldSystemFontOfSize:x]
#define COM_IntString(x)             [x intValue]

#endif /* UtilsMacro_h */
