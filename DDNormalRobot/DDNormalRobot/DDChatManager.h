//
//  DDChatManager.h
//  DDChatManager
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
@interface DDChatManager : NSObject
@property(nonatomic, weak) id<DDChatDelegate> delegate;

+ (instancetype)shareManager;
- (void)getHistoryMessageWithComplete:(CompleteBlcok)completeBlock;//获取历史消息
- (void)getRobotSmartTipsWithMessageContent:(NSString *)messageContent WithComplete:(CompleteBlcok)completeBlock;//获取智能提示
- (void)questionMarkAsResolved:(BOOL)isResolved withAdditionContent:(NSString *)additionContent WithComplete:(CompleteBlcok)completeBlock;//标记问题是否解决
- (void)sendNormalMessage:(NSString *)messageContent additionContent:(NSString *__nullable)additionContent isRobot:(BOOL)isRobot  WithComplete:(CompleteBlcok)completeBlock;
- (void)getRobotDetail;
- (void)sendImageMessageWithImageUrl:(NSString *)imageUrl isRobot:(BOOL)isRobot WithComplete:(CompleteBlcok)completeBlock;
- (void)startNewSession;//开始新会话
- (void)endSession;//结束会话

@end

NS_ASSUME_NONNULL_END
