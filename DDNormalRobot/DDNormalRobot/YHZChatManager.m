//
//  YHZChatManager.m
//  YHZChatManager
//
//  Created by dudu on 2019/12/19.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "YHZChatManager.h"
#import "MessageItemModel.h"
#import "YHZSocketClientManager.h"
#import "MessageHub.h"
#import "RobotDetailModel.h"
#import "ClientParamsModel.h"
#import "QMUIKit.h"
#import "YYCategories.h"
#import "DDNetworkHelper.h"
#import "YYModel.h"
#import "NSString+Emoji.h"

@interface YHZChatManager () <WebSocketManagerDelegate>

@end
@implementation YHZChatManager

+ (instancetype)shareInstance {
    static YHZChatManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)yhz_getHistoryMessageWithComplete:(CompleteBlcok)completeBlock {
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
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
    completeBlock(messageItem);
}

- (void)yhz_getRobotDetail {
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
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
}

- (void)yhz_getRobotSmartTipsWithMessageContent:(NSString *)messageContent WithComplete:(CompleteBlcok)completeBlock {
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
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
    completeBlock(messageItem);
}

- (void)yhz_questionMarkAsResolved:(BOOL)isResolved withAdditionContent:(NSString *)additionContent WithComplete:(CompleteBlcok)completeBlock {
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
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
    completeBlock(messageItem);
}

- (void)yhz_sendNormalMessage:(NSString *)messageContent additionContent:(NSString *)additionContent isRobot:(BOOL)isRobot WithComplete:(CompleteBlcok)completeBlock {
    MessageItemModel *messageItem = [MessageItemModel new];
    messageItem.AppType = isRobot ? 2 : 1;
    messageItem.Content = [messageContent stringContainsEmoji] ? [messageContent emojiEncode] : messageContent;
    messageItem.ContentType = 1;
    messageItem.AdditionContent = additionContent.isNotBlank ? additionContent : @"0";
    messageItem.DialogType = 1;
    messageItem.ReceiveId = @"";
    messageItem.ServiceType = isRobot ? @"1" : @"2";
    messageItem.SenderType = 0;

    NSString *datas = [MessageItemModel messageWithHub:@"implushub" methodName:@"SendMsg" arguments:messageItem otherArgus:nil];
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
    completeBlock(messageItem);
}

- (void)yhz_sendImageMessageWithImageUrl:(NSString *)imageUrl isRobot:(BOOL)isRobot WithComplete:(nonnull CompleteBlcok)completeBlock {
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
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
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
    [[YHZSocketClientManager sharedInstanceManager] yhz_sendData:datas];
}

- (void)yhz_endSession {
    [self sendDialogOver];
    [RobotDetailModel clearRobotDetail];
    //需要把之前的dialogid置空，
    [ClientParamsModel clearClientParams];
    [DDNetworkHelper setValue:@"" forHTTPHeaderField:@"Cookie"];
    [[YHZSocketClientManager sharedInstanceManager] yhz_closeSocket];
}

- (void)socketDidReceiveMessage:(NSString *_Nullable)string {
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
    parameters[@"tag"] = @"0";
    parameters[@"appid"] = @"00c90442c2a3446d89eb80744bf88f73";
    parameters[@"dialogId"] = [ClientParamsModel getClientParams].DialogId;
    parameters[@"senderId"] = [ClientParamsModel getClientParams].CustomerId;
    parameters[@"serviceType"] = @"1";
    parameters[@"clientProtocol"] = @"1.5";
    parameters[@"connectionToken"] = [MessageHub getMessageHub].ConnectionToken;
    parameters[@"connectionData"] = [@[@{@"name":@"implushub"}] yy_modelToJSONString];
    parameters[@"_"] = [NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
    [DDNetworkHelper GET:@"https://implus.dd373.com/cors/start?transport=webSockets" parameters:parameters headers:nil success:^(id responseObject) {
        [QMUITips hideAllTips];
        [self yhz_getRobotDetail];
        [self yhz_getHistoryMessageWithComplete:^(MessageItemModel * _Nonnull message) {
            
        }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(robotInfoChange)]) {
            [self.delegate robotInfoChange];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)yhz_startNewSession {
    __block ClientParamsModel *model;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        [DDNetworkHelper GET:[NSString stringWithFormat:@"https://consult.dd373.com/UserMessageApi/UserFirstVisit?SourcePageTitle=%@&SourcePageUrl=iOS",[[self transform:name] stringByReplacingOccurrencesOfString:@" " withString:@""]] parameters:nil headers:nil success:^(id responseObject) {
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
        [DDNetworkHelper GET:@"https://implus.dd373.com/cors/negotiate" parameters:parameters headers:nil success:^(id responseObject) {
            MessageHub *hub = [MessageHub yy_modelWithJSON:responseObject];
            [MessageHub saveMessageHubWithHub:hub];
            [[YHZSocketClientManager sharedInstanceManager] yhz_connectServer];
            [YHZSocketClientManager sharedInstanceManager].delegate = self;
        } failure:^(NSError *error) {
            
        }];
    });
}

- (void)yhz_startOrderSession {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"clientProtocol"] = @"1.5";
    parameters[@"connectionData"] = [@[@{@"name":@"implushub"}] yy_modelToJSONString];
    parameters[@"_"] = [NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
    [DDNetworkHelper GET:@"https://imservice.dd373.com/cors/negotiate" parameters:parameters headers:nil success:^(id responseObject) {
        MessageHub *hub = [MessageHub yy_modelWithJSON:responseObject];
        [MessageHub saveMessageHubWithHub:hub];
        [[YHZSocketClientManager sharedInstanceManager] yhz_connectServer];
        [YHZSocketClientManager sharedInstanceManager].delegate = self;
    } failure:^(NSError *error) {
        
    }];
}

- (void)yhz_getUnReadMessageCountWithComplete:(void(^)(NSString *count))completeBlock {
    ClientParamsModel *model = [ClientParamsModel getClientParams];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"Appid"] = @"00c90442c2a3446d89eb80744bf88f73";
    params[@"DialogId"] = model.DialogId;
    params[@"ReceiverId"] = model.CustomerId;
    [DDNetworkHelper GET:@"https://implus.dd373.com/DialogRecordApi/GetTotalUnReadMsgs" parameters:params headers:nil success:^(id responseObject) {
        if ([responseObject[@"StatusCode"] isEqualToString:@"0"]) {
            completeBlock(responseObject[@"StatusData"][@"ResultData"][@"Total"]);
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSString *)transform:(NSString *)chinese {
    if (!chinese.isNotBlank) {
        return @"";
    }
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}

@end
