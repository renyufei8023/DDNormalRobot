//
//  UIView+Shadow.m
//  DDNormalRobot
//
//  Created by dudu on 2020/8/13.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "UIView+Shadow.h"
#import "QMUIKit.h"

@implementation UIView (Shadow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            [selfObject setShadowDefaultStyle];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *aDecoder, UIView *originReturnValue) {
            [selfObject setShadowDefaultStyle];
            return originReturnValue;
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(layoutSublayersOfLayer:), CALayer *, ^(UIView *selfObject, CALayer *layer) {
            if (selfObject.shadowPosition == ViewShadowPositionNone) return;
            if (!selfObject.shadowColor) return;
            if (selfObject.shadowOpacity == 0) return;
            if (selfObject.shadowRadius == 0) return;
            
            selfObject.layer.masksToBounds = NO;
            selfObject.layer.shadowColor = selfObject.shadowColor.CGColor;
            selfObject.layer.shadowOpacity = selfObject.shadowOpacity;
            selfObject.layer.shadowOffset= selfObject.shadowOffset;
            selfObject.layer.shadowRadius = selfObject.shadowRadius;
            
            // 如果是四边都需要阴影，直接使用系统的方法
            if (selfObject.shadowPosition == ViewShadowPositionAll) return;
            
            // 单独绘制每个边
            BOOL shouldShowTopShadow = (selfObject.shadowPosition & ViewShadowPositionTop) == ViewShadowPositionTop;
            BOOL shouldShowLeftShadow = (selfObject.shadowPosition & ViewShadowPositionLeft) == ViewShadowPositionLeft;
            BOOL shouldShowBottomShadow = (selfObject.shadowPosition & ViewShadowPositionBottom) == ViewShadowPositionBottom;
            BOOL shouldShowRightShadow = (selfObject.shadowPosition & ViewShadowPositionRight) == ViewShadowPositionRight;
            
            // 画阴影
            CGRect shadowRect = CGRectZero;
            CGFloat shadowOriginX = 0;
            CGFloat shadowOriginY = 0;
            CGFloat shadowSizeWidth = selfObject.qmui_width;
            CGFloat shadowSizeHeight = selfObject.qmui_height;
            CGFloat shadowPathWidth = selfObject.shadowRadius;
            
            if (shouldShowTopShadow) {// 上
                shadowRect = CGRectMake(shadowOriginX, shadowOriginY - shadowPathWidth * 0.5, shadowSizeWidth,  shadowPathWidth);
            }
            if (shouldShowLeftShadow) {// 左
                shadowRect = CGRectMake(shadowOriginX - shadowPathWidth * 0.5, shadowOriginY, shadowPathWidth, shadowSizeHeight);
            }
            if (shouldShowBottomShadow) {// 下
                shadowRect = CGRectMake(shadowOriginX, shadowSizeHeight - shadowPathWidth * 0.5, shadowSizeWidth, shadowPathWidth);
            }
            if (shouldShowRightShadow) {// 右
                shadowRect = CGRectMake(shadowSizeWidth - shadowPathWidth * 0.5, shadowOriginY, shadowPathWidth, shadowSizeHeight);
            }
            
            if (!CGRectIsEmpty(shadowRect)) {
                UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:shadowRect];
                selfObject.layer.shadowPath = bezierPath.CGPath;//阴影路径
            }
        });
    });
}

/// 默认配置
- (void)setShadowDefaultStyle {
    self.shadowColor = UIColorMake(196, 200, 208);
    self.shadowOffset = CGSizeMake(0, 0);
    self.shadowRadius = 4;
    self.shadowOpacity = 0.5;
}

#pragma mark - AssociatedObject

/// shadowPosition
static char kAssociatedObjectKey_shadowPosition;
- (void)setShadowPosition:(ViewShadowPosition)shadowPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowPosition, [NSNumber numberWithUnsignedInteger:shadowPosition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (ViewShadowPosition)shadowPosition {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowPosition) unsignedIntegerValue];
}

/// shadowColor
static char kAssociatedObjectKey_shadowColor;
- (void)setShadowColor:(UIColor *)shadowColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowColor, shadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIColor *)shadowColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowColor);
}

/// shadowOpacity
static char kAssociatedObjectKey_shadowOpacity;
- (void)setShadowOpacity:(CGFloat)shadowOpacity {
#if CGFLOAT_IS_DOUBLE
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowOpacity, [NSNumber numberWithDouble:shadowOpacity], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#else
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowOpacity, [NSNumber numberWithFloat:shadowOpacity], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
    [self setNeedsLayout];
}

- (CGFloat)shadowOpacity {
#if CGFLOAT_IS_DOUBLE
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowOpacity) doubleValue];
#else
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowOpacity) floatValue];
#endif
}

/// shadowRadius
static char kAssociatedObjectKey_shadowRadius;
- (void)setShadowRadius:(CGFloat)shadowRadius {
#if CGFLOAT_IS_DOUBLE
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowRadius, [NSNumber numberWithDouble:shadowRadius], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#else
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowRadius, [NSNumber numberWithFloat:shadowRadius], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
    [self setNeedsLayout];
}

- (CGFloat)shadowRadius {
#if CGFLOAT_IS_DOUBLE
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowRadius) doubleValue];
#else
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowRadius) floatValue];
#endif
}

/// shadowOffset
static char kAssociatedObjectKey_shadowOffset;
- (void)setShadowOffset:(CGSize)shadowOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shadowOffset, [NSValue valueWithCGSize:shadowOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGSize)shadowOffset {
    return [(NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shadowOffset) CGSizeValue];
}

@end
