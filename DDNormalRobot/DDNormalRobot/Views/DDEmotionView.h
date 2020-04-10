//
//  DDEmotionView.h
//  TestSocket
//
//  Created by dudu on 2019/12/25.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDEmotionView : UIView
@property(nonatomic, strong) NSArray<QMUIEmotion *> *emotions;
@property(nonatomic, copy) void(^selectEmotionBlock)(QMUIEmotion *emotion);

@end

NS_ASSUME_NONNULL_END
