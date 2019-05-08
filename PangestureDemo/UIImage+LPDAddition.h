
//  Created by kyson on 2019/5/8.
//  Copyright © 2019 kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAGradientLayer+Layer.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LPDAddition)

/**
 *  @brief  以传入的视图为源，根据主窗口压缩比例截图
 *
 *  @param sourceView 源视图
 *
 *  @return 如果源视图为nil，则返回nil
 */
+ (UIImage *)createImageFromView:(UIView *)sourceView;

/**
 *  @brief  根据颜色生成图片，默认size为{1.f, 1.f}
 *
 *  @param color 传入颜色
 *
 *  @return 返回图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color;

/**
 *  @brief  根据颜色和传入的size生成图片
 *
 *  @param color 传入的颜色
 *  @param size  生成图片的size
 *
 *  @return 返回图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  @brief 设置图片的透明度
 *
 *  @param alpha 透明度
 *
 *  @return 返回处理后的图片
 */
- (UIImage *)imageWithAlpha:(CGFloat)alpha;

/**
 *  @brief 设置图片的size
 *
 *
 *
 *  @return 返回改变size之后的图片
 */
- (UIImage *)resizeTo:(CGSize)size;

/**
 设置图片的size，使用 UIImageJPEGRepresentation

 @param size 目标大小
 @param compressionQuality 图片质量
 @return 返回改变size之后的图片
 */
- (UIImage *)resizeTo:(CGSize)size quality:(CGFloat)compressionQuality;

/**
 *  @brief 获取高斯模糊图片
 *
 *  @param blur 模糊度
 *
 *  @return 返回处理后的图片
 */
- (UIImage *)imageWithBlurNumber:(CGFloat)blur;
/**
 *  @brief 获取带文字水印图片
 *
 *  @param image logo图片
 *  @param text logo文本
 *  @param textRect 文本位置
 *  @param dic 文本属性

 *  @return 返回处理后的图片
 */
+ (UIImage *)watermarkWithImage:(UIImage *)image withText:(NSString *)text textRect:(CGRect)textRect attributes:(NSDictionary *)dic;

+ (nullable UIImage *)imageCacheWithName:(NSString *)imageName;

+ (nullable UIImage *)imageNoCacheWithName:(NSString *)imageName;

+ (nullable UIImage *)imageJPGName:(NSString *)imageName;

+ (nullable UIImage *)opacityImage:(UIImage *)image opacity:(float)opacity;

+ (nullable UIImage *)maskImage:(UIImage *)image withColor:(UIColor *)maskColor;

+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (nullable UIImage *)roundImageWithOriginImage:(UIImage *)image withDiameter:(CGFloat)diameter;

+ (nullable UIImage *)roundedRectImageWithColor:(UIColor *)color cornerRadius:(CGFloat)radius size:(CGSize)size;

+ (nullable UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
/**
 *  @brief 生成渐变色图片
 */
+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction size:(CGSize)size;
+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction;

/**
 *  @brief 旋转图片
 */
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
