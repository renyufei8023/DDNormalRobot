//
//  UIView+Shadow.h
//  DDNormalRobot
//
//  Created by dudu on 2020/8/13.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ViewShadowPosition) {
    ViewShadowPositionNone      = 0,
    ViewShadowPositionTop       = 1 << 0,
    ViewShadowPositionLeft      = 1 << 1,
    ViewShadowPositionBottom    = 1 << 2,
    ViewShadowPositionRight     = 1 << 3,
    ViewShadowPositionAll       = ViewShadowPositionTop | ViewShadowPositionLeft | ViewShadowPositionBottom | ViewShadowPositionRight
};

@interface UIView (Shadow)

/// 默认 ViewShadowPositionNone
@property(nonatomic, assign) ViewShadowPosition shadowPosition;

/// 默认 RGB(196, 200, 208)
@property(nonatomic, strong, nullable) UIColor *shadowColor;

/// [0,1], 默认 0.5
@property(nonatomic, assign) CGFloat shadowOpacity;

/// 默认4
@property(nonatomic, assign) CGFloat shadowRadius;

/// 默认  (0, 0)
@property(nonatomic, assign) CGSize shadowOffset;

@end

NS_ASSUME_NONNULL_END
