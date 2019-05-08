
//  Created by kyson on 2019/5/8.
//  Copyright © 2019 kyson. All rights reserved.
//

#import "UIImage+LPDAddition.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (LPDAddition)

+ (UIImage *)createImageFromView:(UIView *)sourceView {
  NSParameterAssert(sourceView);
  
  UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, NO, [UIScreen mainScreen].scale);
  [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

+ (UIImage *)createImageWithColor:(UIColor *)color {
  return [UIImage createImageWithColor:color size:CGSizeMake(1.f, 1.f)];
}

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
  NSParameterAssert(color);
  
  CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

- (UIImage *)imageWithAlpha:(CGFloat)alpha {
  UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
  
  CGContextScaleCTM(ctx, 1, -1);
  CGContextTranslateCTM(ctx, 0, -area.size.height);
  
  CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
  
  CGContextSetAlpha(ctx, alpha);
  
  CGContextDrawImage(ctx, area, self.CGImage);
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return newImage;
}

- (UIImage *)resizeTo:(CGSize)size {
    // 保证处理多张图片时，应保证内存被及时释放
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        [self drawInRect:rect];
        UIImage *imageContext = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(imageContext);
        return [UIImage imageWithData:imageData];
    }
}

- (UIImage *)resizeTo:(CGSize)size quality:(CGFloat)compressionQuality {
    // 保证处理多张图片时，应保证内存被及时释放
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        [self drawInRect:rect];
        UIImage *imageContext = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImageJPEGRepresentation(imageContext, compressionQuality);
        return [UIImage imageWithData:imageData];
    }
}

-(UIImage *)imageWithBlurNumber:(CGFloat)blur {
  if (blur < 0.f || blur > 1.f) {
    blur = 0.5f;
  }
  int boxSize = (int)(blur * 40);
  boxSize = boxSize - (boxSize % 2) + 1;
  CGImageRef img = self.CGImage;
  vImage_Buffer inBuffer, outBuffer;
  vImage_Error error;
  void *pixelBuffer;
  //从CGImage中获取数据
  CGDataProviderRef inProvider = CGImageGetDataProvider(img);
  CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
  //设置从CGImage获取对象的属性
  inBuffer.width = CGImageGetWidth(img);
  inBuffer.height = CGImageGetHeight(img);
  inBuffer.rowBytes = CGImageGetBytesPerRow(img);
  inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
  pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
  if(pixelBuffer == NULL)
    NSLog(@"No pixelbuffer");
  outBuffer.data = pixelBuffer;
  outBuffer.width = CGImageGetWidth(img);
  outBuffer.height = CGImageGetHeight(img);
  outBuffer.rowBytes = CGImageGetBytesPerRow(img);
  error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
  if (error) {
    NSLog(@"error from convolution %ld", error);
  }
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
  CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
  UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
  //clean up CGContextRelease(ctx);
  CGColorSpaceRelease(colorSpace);
  free(pixelBuffer);
  CFRelease(inBitmapData);
  CGColorSpaceRelease(colorSpace);
  CGImageRelease(imageRef);
  return returnImage;
}

+ (UIImage *)watermarkWithImage:(UIImage *)image withText:(NSString *)text textRect:(CGRect)textRect attributes:(NSDictionary *)dic {

    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //2.绘制图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //添加水印文字
    [text drawInRect:textRect withAttributes:dic];
    //3.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
    
}

+ (nullable UIImage *)imageCacheWithName:(NSString *)imageName {
  return [UIImage imageNamed:imageName];
}

+ (nullable UIImage *)imageNoCacheWithName:(NSString *)imageName {
  NSString *fullName = nil;
  if ([UIScreen mainScreen].scale > 2.0) {
    fullName = [imageName stringByAppendingString:@"@3x"];
  } else {
    fullName = [imageName stringByAppendingString:@"@2x"];
  }
  NSString *path = [[NSBundle mainBundle] pathForResource:fullName ofType:@"png"];
  UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
  if (!image) {
    if ([UIScreen mainScreen].scale > 2.0) {
      fullName = [imageName stringByAppendingString:@"@2x"];
      NSString *path = [[NSBundle mainBundle] pathForResource:fullName ofType:@"png"];
      image = [[UIImage alloc] initWithContentsOfFile:path];
    }
  }
  return [[UIImage alloc] initWithContentsOfFile:path];
}

+ (nullable UIImage *)imageJPGName:(NSString *)imageName {
  NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
  return [[UIImage alloc] initWithContentsOfFile:path];
}

+ (nullable UIImage *)opacityImage:(UIImage *)image opacity:(float)opacity {
  UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
  CGContextScaleCTM(ctx, 1, -1);
  CGContextTranslateCTM(ctx, 0, -area.size.height);
  CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
  CGContextSetAlpha(ctx, opacity);
  CGContextDrawImage(ctx, area, image.CGImage);
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

+ (nullable UIImage *)maskImage:(UIImage *)image withColor:(UIColor *)maskColor {
  CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextClipToMask(context, rect, image.CGImage);
  CGContextSetFillColorWithColor(context, maskColor.CGColor);
  CGContextFillRect(context, rect);
  UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return smallImage;
}

+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
  if (fabs((size.width) - (0.0)) < 0.001 || fabs((size.height) - (0.0)) < 0.001) {
    return nil;
  }
  UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (nullable UIImage *)roundImageWithOriginImage:(UIImage *)image withDiameter:(CGFloat)diameter {
  CGSize imageSize = CGSizeMake(diameter, diameter);
  CGRect imageRect = CGRectMake(0, 0, diameter, diameter);
  
  UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextAddEllipseInRect(context, imageRect);
  CGContextClip(context);
  
  [image drawInRect:imageRect];
  UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultImage;
}

+ (nullable UIImage *)roundedRectImageWithColor:(UIColor *)color cornerRadius:(CGFloat)radius size:(CGSize)size {
  UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
  [color set];
  UIBezierPath *path =
  [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:radius];
  [path fill];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (nullable UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
  UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return scaledImage;
}

+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
  CAGradientLayer *layer = [CAGradientLayer layerWithColors:colorArray direction:direction];
  layer.frame = CGRectMake(0, 0, size.width, size.height);
  layer.cornerRadius = cornerRadius;
  UIGraphicsBeginImageContextWithOptions(size, NO, 3);
  [layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return gradientImage;
}

+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction size:(CGSize)size {
  return [self gradientImageWithColors:colorArray direction:direction size:size cornerRadius:0];
}

+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction {
  return [self gradientImageWithColors:colorArray direction:direction size:CGSizeMake(10, 10)];
}

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        case UIImageOrientationUp:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = 0;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    CFRelease(context);
    return newPic;
}

@end

