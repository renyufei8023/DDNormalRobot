//
//  MessageItemModel.h
//  TestSocket
//
//  Created by dudu on 2019/11/12.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeOther,
    MessageTypeChoose,
    MessageTypeTurnArtifical,//转人工
    MessageTypeEvalution,//评价
};

@class BusinessItemModel;
@interface MessageItemModel : NSObject
@property(nonatomic, copy) NSString *AppId;
@property(nonatomic, assign) NSInteger AppType;//1、im服务系统2、机器人系统3、系统消息
@property(nonatomic, copy) id Content;
@property(nonatomic, assign) NSInteger ContentType;//1文本，2图片
@property(nonatomic, copy) NSString *AdditionContent;//内容附加数据集，可传任意类型
@property(nonatomic, copy) NSString *DialogId;
//appType=1、im服务系统  1消息，2历史消息   3标记已读， 4对话列表，5、客服加入组，6预发送
//appType=2、机器人系统   1，问题、2、请求机器人消息 、3智能问题，4标记解决
//appType=3、系统消息  1、客服消息推送，2排队展示， 3邀请评价，4转人工，5客服问好
@property(nonatomic, assign) NSInteger DialogType;
@property(nonatomic, copy) NSString *ReceiveId;//接收者ID,上个消息的发送者ID
@property(nonatomic, copy) NSString *ServiceType;//客服类型：1机器人，2人工
@property(nonatomic, copy) NSString *SenderId;
@property(nonatomic, assign) NSInteger SenderType;//发送者类型：0用户，1人工客服，2机器人
@property(nonatomic, copy) NSString *SenderName;
@property(nonatomic, strong) NSArray<BusinessItemModel *> *chooseOptions;//问题类型（人工的时候用）
@property(nonatomic, assign) MessageType messageType;
@property(nonatomic, assign) BOOL isSolved;//标记是否反馈

//content里面的字段
@property(nonatomic, copy) NSString *Id;
@property(nonatomic, copy) NSString *ReceiverId;
@property(nonatomic, copy) NSString *CreateTime;
@property(nonatomic, copy) NSString *sortTime;//根据这个时间进行排序
@property(nonatomic, copy) NSString *Readed;
@property(nonatomic, copy) NSString *SerialNumber;

+ (NSString *)messageWithHub:(NSString *)hub
                  methodName:(NSString *)methodName
                   arguments:(MessageItemModel *)messageItem
                  otherArgus:(NSMutableDictionary *)otherArgus;

@end

