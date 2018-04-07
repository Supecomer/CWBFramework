/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： UIImage+ImageComperssion.h
 * 内容摘要： 改变图片大小，等比例缩放，不进行剪切
 * 其它说明：
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage(ImageComperssion) 

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;


@end
