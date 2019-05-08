
//  Created by kyson on 2019/5/8.
//  Copyright © 2019 kyson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LPDGradientDirection) {
  LPDGradientDirectionTopLeft = 0,
  LPDGradientDirectionTop = 1,
  LPDGradientDirectionLeft = 2,
};

@interface CAGradientLayer (Layer)

+ (CAGradientLayer *)layerWithColors:(NSArray<UIColor *> *)colorArray direction:(LPDGradientDirection)direction;

@end
