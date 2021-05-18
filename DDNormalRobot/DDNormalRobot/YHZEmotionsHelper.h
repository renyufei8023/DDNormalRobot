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

@interface YHZEmotionsHelper : NSObject
//云阁表情相关
+ (NSArray<QMUIEmotion *> *)get_all_emotions;
+ (NSMutableAttributedString *)generateAttributeWithEmojText:(NSString *)string;

+ (UIImage *)generateImageFromBundleWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
