/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： UIImage+ImageComperssion.m
 * 内容摘要： 改变图片大小，等比例缩放，不进行剪切
 * 其它说明：
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/

#import "UIImage+ImageComperssion.h"

@implementation UIImage(ImageComperssion)


/***********************************************************************
 * 方法名称： imageByScalingAndCroppingForSize
 * 功能描述： 将图片处理成固定的大小尺寸，并返回image
 * 输入参数： CGSize()图片的宽度和高度
 * 输出参数： 
 * 返 回 值：  
 * 其它说明： 包含头文件以后可以直接调用此方法
 ***********************************************************************/
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	// 创建一个bitmap的context  
    // 并把它设置成为当前正在使用的context  
    UIGraphicsBeginImageContext(targetSize);  
	
    // 绘制改变大小的图片  
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];  
	
    // 从当前context中创建一个改变大小后的图片  
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
	
    // 使当前的context出堆栈  
    UIGraphicsEndImageContext();  
	
    // 返回新的改变大小后的图片  
    return scaledImage;  
}


@end
