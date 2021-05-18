//
//  YHZChatManager.h
//  YHZChatManager
//
//  Created by dudu on 2019/12/19.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MessageItemModel;
typedef void(^CompleteBlcok)(MessageItemModel *message);

@protocol DDChatDelegate <NSObject>
- (void)chatManagerDidReceiveMessageWithMessageItem:(MessageItemModel *)message;
- (void)robotInfoChange;
@end
@interface YHZChatManager : NSObject
@property(nonatomic, weak) id<DDChatDelegate> delegate;

+ (instancetype)shareInstance;
- (void)yhz_getHistoryMessageWithComplete:(CompleteBlcok)completeBlock;//获取历史消息
- (void)yhz_getRobotSmartTipsWithMessageContent:(NSString *)messageContent WithComplete:(CompleteBlcok)completeBlock;//获取智能提示
- (void)yhz_questionMarkAsResolved:(BOOL)isResolved withAdditionContent:(NSString *)additionContent WithComplete:(CompleteBlcok)completeBlock;//标记问题是否解决
- (void)yhz_sendNormalMessage:(NSString *)messageContent additionContent:(NSString *__nullable)additionContent isRobot:(BOOL)isRobot  WithComplete:(CompleteBlcok)completeBlock;
- (void)yhz_getRobotDetail;
- (void)yhz_sendImageMessageWithImageUrl:(NSString *)imageUrl isRobot:(BOOL)isRobot WithComplete:(CompleteBlcok)completeBlock;
- (void)yhz_startNewSession;//开始新会话
- (void)yhz_endSession;//结束会话
- (void)yhz_startOrderSession;//开始订单聊天

@end

NS_ASSUME_NONNULL_END
