/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： AppMacro.h
 * 内容摘要： app相关的宏定义
 * 其它说明： 系统相关 全部以 SYS_ 打头
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/

#ifndef AppMacro_h
#define AppMacro_h

/************  获取屏幕 宽度、高度   *************/
#define SYS_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SYS_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

/************  DEBUG  模式下打印日志,当前行   *************/
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
//重写NSLog,Debug模式下打印日志和当前行数
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif


/************  系统相关  *************/
// 是否iPad
#define SYS_isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//获取系统版本
#define SYS_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define SYS_CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define SYS_CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是否 Retina屏、设备是否%fhone 5、是否是iPad
#define SYS_isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define SYS_isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


//判断设备的操做系统是不是ios7
#define SYS_IOS7 ([[[UIDevice currentDevice].systemVersion doubleValue] >= 7.0]


#endif /* AppMacro_h */
