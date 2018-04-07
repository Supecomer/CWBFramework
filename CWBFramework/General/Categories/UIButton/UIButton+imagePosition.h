/*********************************************************************
 * 版权所有 CWB
 *
 * 文件名称： UIButton+imagePosition.h
 * 内容摘要： UIButton 扩展
 * 其它说明：
 * 当前版本：  1.0
 * 作    者： ciome
 * 完成日期：16/7/30
 ***********************************************************************/
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CWBImagePosition) {
    CWBImagePositionLeft = 0,              //图片在左，文字在右，默认
    CWBImagePositionRight = 1,             //图片在右，文字在左
    CWBImagePositionTop = 2,               //图片在上，文字在下
    CWBImagePositionBottom = 3,            //图片在下，文字在上
};

@interface UIButton (CWBImagePosition)

/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *
 *  @param spacing 图片和文字的间隔
 */
- (void)cwb_setImagePosition:(CWBImagePosition)postion spacing:(CGFloat)spacing;
@end
