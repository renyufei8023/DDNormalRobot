//
//  QueueView.h
//  TestSocket
//
//  Created by dudu on 2020/1/2.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MessageItemModel;
@interface QueueView : UIView
@property(nonatomic, strong) MessageItemModel *messageModel;

@end

NS_ASSUME_NONNULL_END
