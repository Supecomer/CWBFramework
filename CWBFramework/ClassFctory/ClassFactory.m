/*********************************************************************
 * 版权所有  CWB
 *
 * 文件名称： ClassFactory.m
 * 文件标识：
 * 内容摘要： 类工厂
 * 其它说明：
 * 当前版本：
 * 作    者： cimoe
 * 完成日期： 16/07/30
 **********************************************************************/


/*************************************************************************** 
 *                                文件引用 
 ***************************************************************************/ 
#import "ClassFactory.h"


/*************************************************************************** 
 *                                 宏定义 
 ***************************************************************************/ 


/*************************************************************************** 
 *                                 常量 
 ***************************************************************************/ 


/*************************************************************************** 
 *                                类型定义 
 ***************************************************************************/ 


/*************************************************************************** 
 *                                全局变量 
 ***************************************************************************/ 



/*************************************************************************** 
 *                                 原型 
 ***************************************************************************/ 


/*************************************************************************** 
 *                                类特性
 ***************************************************************************/ 
@implementation ClassFactory


/*************************************************************************** 
 *                                类的实现 
 ***************************************************************************/ 

/***********************************************************************
 * 方法名称： init
 * 功能描述： 对象初始化
 * 输入参数：        
 * 输出参数： 
 * 返 回 值： 
 * 其它说明： 
 ***********************************************************************/
- (id) init
{
    if (self = [super init])
    {

    }
    
	return self;
}


/***********************************************************************
 * 方法名称： getLocalCfg
 * 功能描述： 获取本地配置对象
 * 输入参数：        
 * 输出参数： 
 * 返 回 值： 
 * 其它说明： 
 ***********************************************************************/
+ (ClassFactory *)getInstance
{
    static  ClassFactory  *shareClassFactory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
    
        shareClassFactory = [[self alloc] init];
    });
    
    return shareClassFactory;
}



@end
