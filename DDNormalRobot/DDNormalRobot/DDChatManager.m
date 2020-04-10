//
//  DDChatManager.m
//  DDChatManager
//
//  Created by dudu on 2019/12/19.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "DDChatManager.h"
#import "MessageItemModel.h"
#import "WebSocketManager.h"
#import "MessageHub.h"
#import "RobotDetailModel.h"
#import "ClientParamsModel.h"
#import <QMUIKit.h>
#import <YYCategories.h>
#import <DDNetworkHelper.h>
#import <YYModel/YYModel.h>

@interface DDChatManager () <WebSocketManagerDelegate>

@end
@implementation DDChatManager

+ (instancetype)shareManager {
    static DDChatManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)getHistoryMessageWithComplete:(CompleteBlcok)completeBlock {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = 1;
    messageItem.Content = @"";
    messageItem.ContentType = 1;
    messageItem.AdditionContent = @"";
    messageItem.DialogType = 2;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = @"1";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
    completeBlock(messageItem);
}

- (void)getRobotDetail {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = 1;
    messageItem.Content = @"";
    messageItem.ContentType = 1;
    messageItem.AdditionContent = @"0";
    messageItem.DialogType = 3;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = @"1";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
}

- (void)getRobotSmartTipsWithMessageContent:(NSString *)messageContent WithComplete:(CompleteBlcok)completeBlock {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = 2;
    messageItem.Content = messageContent;
    messageItem.ContentType = 1;
    messageItem.AdditionContent = @"";
    messageItem.DialogType = 3;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = @"1";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
    completeBlock(messageItem);
}

- (void)questionMarkAsResolved:(BOOL)isResolved withAdditionContent:(NSString *)additionContent WithComplete:(CompleteBlcok)completeBlock {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = 2;
    messageItem.Content = @"2";
    messageItem.ContentType = 1;
    messageItem.AdditionContent = additionContent;
    messageItem.DialogType = isResolved ? 4 : 6;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = @"1";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
    completeBlock(messageItem);
}

- (void)sendNormalMessage:(NSString *)messageContent additionContent:(NSString *)additionContent isRobot:(BOOL)isRobot WithComplete:(CompleteBlcok)completeBlock {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = isRobot ? 2 : 1;
    messageItem.Content = messageContent;
    messageItem.ContentType = 1;
    messageItem.AdditionContent = additionContent.isNotBlank ? additionContent : @"0";
    messageItem.DialogType = 1;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = isRobot ? @"1" : @"2";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
    completeBlock(messageItem);
}

- (void)sendImageMessageWithImageUrl:(NSString *)imageUrl isRobot:(BOOL)isRobot WithComplete:(nonnull CompleteBlcok)completeBlock {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = isRobot ? 2 : 1;
    messageItem.Content = imageUrl;
    messageItem.ContentType = 2;
    messageItem.AdditionContent = @"0";
    messageItem.DialogType = 1;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = isRobot ? @"2" : @"1";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
    completeBlock(messageItem);
}

- (void)sendDialogOver {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = 3;
    messageItem.Content = @"";
    messageItem.ContentType = 1;
    messageItem.AdditionContent = @"0";
    messageItem.DialogType = 7;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = @"1";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[WebSocketManager sharedManager] sendDataToServer:datas];
}

- (void)endSession {
    [self sendDialogOver];
    [RobotDetailModel clearRobotDetail];
    //需要把之前的dialogid置空，
    [ClientParamsModel clearClientParams];
    [DDNetworkHelper setValue:@"" forHTTPHeaderField:@"Cookie"];
    [[WebSocketManager sharedManager] closeSocket];
}

- (void)webSocketManagerDidReceiveMessageWithString:(NSString *_Nullable)string {
    NSDictionary *reciveData = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    if ([reciveData.allKeys containsObject:@"M"]) {
        if ([reciveData[@"M"] firstObject]) {
            if ([[[reciveData[@"M"] firstObject] allKeys] containsObject:@"A"]) {
                MessageItemModel *messageModel = [MessageItemModel yy_modelWithJSON:[[reciveData[@"M"] firstObject][@"A"] firstObject]];
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatManagerDidReceiveMessageWithMessageItem:)]) {
                    [self.delegate chatManagerDidReceiveMessageWithMessageItem:messageModel];
                }
            }
        }
    }
}

- (void)webSocketDidOpen {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"clientProtocol"] = @"1.5";
    parameters[@"tag"] = @"0";
    parameters[@"appid"] = @"00c90442c2a3446d89eb80744bf88f73";
    parameters[@"dialogId"] = [ClientParamsModel getClientParams].DialogId;
    parameters[@"senderId"] = [ClientParamsModel getClientParams].CustomerId;
    parameters[@"serviceType"] = @"1";
    parameters[@"connectionToken"] = [MessageHub getMessageHub].ConnectionToken;
    parameters[@"connectionData"] = [@[@{@"name":@"implushub"}] yy_modelToJSONString];
    parameters[@"_"] = [NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
    [DDNetworkHelper GET:@"http://implus.dd373.com/cors/start?transport=webSockets" parameters:parameters headers:nil success:^(id responseObject) {
        [QMUITips hideAllTips];
        [self getRobotDetail];
        [self getHistoryMessageWithComplete:^(MessageItemModel * _Nonnull message) {
            
        }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(robotInfoChange)]) {
            [self.delegate robotInfoChange];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)startNewSession {
    __block ClientParamsModel *model;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        [DDNetworkHelper GET:@"http://consult.dd373.com/UserMessageApi/UserFirstVisit" parameters:nil headers:nil success:^(id responseObject) {
            model = [ClientParamsModel yy_modelWithDictionary:responseObject[@"StatusData"][@"ResultData"]];
            [ClientParamsModel saveClientParams:model];
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            
        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"clientProtocol"] = @"1.5";
        parameters[@"tag"] = @"0";
        parameters[@"appid"] = @"00c90442c2a3446d89eb80744bf88f73";
        parameters[@"dialogId"] = model.DialogId;
        parameters[@"senderId"] = model.CustomerId;
        parameters[@"serviceType"] = @"1";
        parameters[@"connectionData"] = [@[@{@"name":@"implushub"}] yy_modelToJSONString];
        parameters[@"_"] = [NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
        [DDNetworkHelper GET:@"http://implus.dd373.com/cors/negotiate" parameters:parameters headers:nil success:^(id responseObject) {
            MessageHub *hub = [MessageHub yy_modelWithJSON:responseObject];
            [MessageHub saveMessageHubWithHub:hub];
            [[WebSocketManager sharedManager] connectServer];
            [WebSocketManager sharedManager].delegate = self;
        } failure:^(NSError *error) {
            
        }];
    });
}


@end
