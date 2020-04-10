//
//  DDChatCell.h
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SenderType) {
    SenderTypeOther,
    SenderTypeMe,
};
@class MessageItemModel;
@interface DDChatCell : UITableViewCell
@property(nonatomic, assign) SenderType senderType;
@property(nonatomic, strong) MessageItemModel *model;
@property(nonatomic, copy) void(^selectQuestionBlock)(NSString *content, NSString *questionID);

@end

NS_ASSUME_NONNULL_END
