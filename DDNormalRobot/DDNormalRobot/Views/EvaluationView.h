//
//  EvaluationView.h
//  TestSocket
//
//  Created by dudu on 2019/12/26.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EvaluationView : UIView
@property(nonatomic, copy) void(^closeBlock)(void);
@property(nonatomic, copy) void(^submitBlock)(NSString *type, NSString *content);

@end

NS_ASSUME_NONNULL_END
