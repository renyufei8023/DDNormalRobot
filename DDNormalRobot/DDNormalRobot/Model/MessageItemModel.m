//
//  MessageItemModel.m
//  TestSocket
//
//  Created by dudu on 2019/11/12.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "MessageItemModel.h"
#import "ClientParamsModel.h"
#import <YYCategories/YYCategories.h>
#import <YYModel/YYModel.h>
#import <QMUIKit/QMUIKit.h>

@implementation MessageItemModel

+ (NSString *)messageWithHub:(NSString *)hub methodName:(NSString *)methodName arguments:(MessageItemModel *)messageItem otherArgus:(NSMutableDictionary *)otherArgus {
    NSMutableDictionary *datas = [NSMutableDictionary dictionary];
    if (hub) {
        datas[@"H"] = hub;
    }else {
        datas[@"H"] = @"implushub";
    }
    datas[@"M"] = methodName;
    if (!messageItem.AppId.isNotBlank) {
        messageItem.AppId = @"00c90442c2a3446d89eb80744bf88f73";
    }
    if (!messageItem.DialogId.isNotBlank) {
        messageItem.DialogId = [ClientParamsModel getClientParams].DialogId;
    }
    if (!messageItem.SenderId.isNotBlank) {
        messageItem.SenderId = [ClientParamsModel getClientParams].CustomerId;
    }
    if (!messageItem.SenderName.isNotBlank) {
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
    return messageStr;
}

@end
