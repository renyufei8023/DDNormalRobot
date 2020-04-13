//
//  EmojTextUtil.h
//  DDNormalRobot
//
//  Created by dudu on 2020/4/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDHelper : NSObject
//云阁表情相关
+ (NSArray<QMUIEmotion *> *)ddEmotions;
+ (NSMutableAttributedString *)emojTextToAtt:(NSString *)string;

+ (UIImage *)imageWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END