/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： WriteLog.m
 * 内容摘要： 打印，方便调试
 * 其它说明：
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/

#import "WriteLog.h"

#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;"
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;"
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"


/**  不同等级的Log，也可开关，当前已开  */
#define LOG_LEVEL_WARN
#define LOG_LEVEL_INFO
#define LOG_LEVEL_ERROR
#define LOG_LEVEL_DEBUG
//如需关闭，就将你需要关闭的宏定义注销那么该种形式的Log将不显示或者以默认颜色显示
#ifdef LOG_LEVEL_ERROR
#define KKLogError(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"bg255,0,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#else
#define KKLogError(...) //NSLog(__VA_ARGS__)
#endif

#ifdef LOG_LEVEL_INFO
#define KKLogInfo(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg65,105,225;" frmt  XCODE_COLORS_RESET), ##__VA_ARGS__)
#else
#define KKLogInfo(...) //NSLog(__VA_ARGS__)
#endif

#ifdef LOG_LEVEL_DEBUG
#define KKLogDebug(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,200,0;" frmt  XCODE_COLORS_RESET), ##__VA_ARGS__)
#else
#define KKLogDebug(...) //NSLog(__VA_ARGS__)
#endif


#ifdef LOG_LEVEL_WARN
#define KKLogWarn(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"bg255,255,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#else
#define KKLogWarn(...) //NSLog(__VA_ARGS__)
#endif


@implementation WriteLog



void writeLog(int ulErrorLevel, const char *func, int lineNumber, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *strFormat = [NSString stringWithFormat:@"%@%s, %@%i, %@%@",@"Function: ",func,@"Line: ",lineNumber, @"Format: ",string];
    
    NSString * strModelName = @"WriteLogTest"; //模块名
    
     NSString  *strLog = [NSString stringWithFormat:@"ModalName: %@, %@.",strModelName, strFormat];
    
    switch (ulErrorLevel) {
        case ERR_LOG:
            KKLogError(@"%@",strLog);
            
            break;
        case WARN_LOG:
            KKLogWarn(@"%@",strLog);
            break;
        case NOTICE_LOG:
            KKLogInfo(@"%@",strLog);
            break;
        case DEBUG_LOG:
            KKLogDebug(@"%@",strLog);
            break;
        default:
            break;
    }
    
   
   
}



@end
