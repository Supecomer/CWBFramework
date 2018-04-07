/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： UIImageView+CornerRadius.h
 * 内容摘要： 高效率处理圆角
 * 其它说明：
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (CornerRadius)


- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (void)cr_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (instancetype)initWithRoundingRectImageView;

- (void)cr_cornerRadiusRoundingRect;

- (void)cr_attachBorderWidth:(CGFloat)width color:(UIColor *)color;

@end
