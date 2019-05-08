
//  Created by kyson on 2019/5/8.
//  Copyright © 2019 kyson. All rights reserved.
//

#import "CAGradientLayer+Layer.h"

@implementation CAGradientLayer (Layer)

+ (CAGradientLayer *)layerWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction {
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  switch (direction) {
    case LPDGradientDirectionTop: {
      gradientLayer.startPoint = CGPointMake(0.5, 0);
      gradientLayer.endPoint = CGPointMake(0.5, 1);
    } break;
      
    case LPDGradientDirectionLeft: {
      gradientLayer.startPoint = CGPointMake(0, 0.5);
      gradientLayer.endPoint = CGPointMake(1, 0.5);
    } break;
      
    case LPDGradientDirectionTopLeft:
    default:{
      gradientLayer.startPoint = CGPointMake(0, 0);
      gradientLayer.endPoint = CGPointMake(1, 1);
    } break;
  }
  
  NSMutableArray *CGColorArray = [[NSMutableArray alloc] init];
  for (UIColor *color in colorArray) {
    [CGColorArray addObject:(__bridge id)color.CGColor];
  }
  gradientLayer.colors = CGColorArray;
  return gradientLayer;
}

@end
