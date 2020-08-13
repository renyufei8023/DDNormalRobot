//
//  WebSocketManager.h
//  TestSocket
//
//  Created by dudu on 2019/11/12.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

typedef NS_ENUM(NSUInteger,WebSocketConnectType){
    WebSocketDefault = 0, //初始状态,未连接
    WebSocketConnect,      //已连接
    WebSocketDisconnect    //连接后断开
};

@class WebSocketManager;
@protocol WebSocketManagerDelegate <NSObject>

- (void)webSocketManagerDidReceiveMessageWithString:(NSString *_Nullable)string;
- (void)webSocketDidOpen;
@end

NS_ASSUME_NONNULL_BEGIN

@interface WebSocketManager : NSObject
@property (nonatomic, copy) void(^SocketDidOpenBlock)(void);
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, weak) id<WebSocketManagerDelegate> delegate;
@property (nonatomic, assign) BOOL isConnect;  //是否连接
@property (nonatomic, assign) BOOL isRobot;  //是否云阁系统
@property (nonatomic, assign) WebSocketConnectType connectType;

+ (instancetype)sharedManager;
- (void)connectServer;//建立长连接
- (void)reConnectServer;//重新连接
- (void)closeSocket;//关闭长连接
- (void)sendDataToServer:(NSString *)data;//发送数据给服务器

@end

NS_ASSUME_NONNULL_END
