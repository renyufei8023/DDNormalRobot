//
//  MessageItemModel.m
//  TestSocket
//
//  Created by dudu on 2019/11/12.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "MessageItemModel.h"
#import "ClientParamsModel.h"
#import "YYModel.h"
#import "QMUIKit.h"
#import "NSString+Emoji.h"
#import "YHZSocketClientManager.h"

@implementation MessageItemModel

+ (NSString *)messageWithHub:(NSString *)hub methodName:(NSString *)methodName arguments:(MessageItemModel *)messageItem otherArgus:(NSMutableDictionary *)otherArgus {
    NSMutableDictionary *datas = [NSMutableDictionary dictionary];
    if (hub) {
        datas[@"H"] = hub;
    }else {
        datas[@"H"] = @"implushub";
    }
    datas[@"M"] = methodName;
    if (!messageItem.AppId.dd_isNotBlank) {
        messageItem.AppId = [YHZSocketClientManager getRobotAppID];
    }
    if (!messageItem.DialogId.dd_isNotBlank) {
        messageItem.DialogId = [ClientParamsModel getClientParams].DialogId;
    }
    if (!messageItem.SenderId.dd_isNotBlank) {
        messageItem.SenderId = [ClientParamsModel getClientParams].CustomerId;
    }
    if (!messageItem.SenderName.dd_isNotBlank) {
        messageItem.SenderName = [ClientParamsModel getClientParams].CustomerName;
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    messageItem.CreateTime = [formatter stringFromDate:date];
    datas[@"A"] = @[[messageItem yy_modelToJSONObject]];
    [datas addEntriesFromDictionary:otherArgus];
    NSString *messageStr = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:datas options:NSJSONWritingSortedKeys error:nil] encoding:NSUTF8StringEncoding];
    NSLog(@"发出消息：%@",[messageStr yy_modelDescription]);
    return [datas yy_modelToJSONString];
}

- (NSString *)description {
    return [self yy_modelDescription];
}

@end
