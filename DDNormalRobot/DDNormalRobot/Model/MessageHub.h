//
//  MessageHub.h
//  TestSocket
//
//  Created by dudu on 2019/11/13.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHub : NSObject <NSSecureCoding>
@property(nonatomic, copy) NSString *Url;
@property(nonatomic, copy) NSString *ConnectionToken;
@property(nonatomic, copy) NSString *ConnectionId;
@property(nonatomic, copy) NSString *KeepAliveTimeout;
@property(nonatomic, copy) NSString *DisconnectTimeout;
@property(nonatomic, copy) NSString *ConnectionTimeout;
@property(nonatomic, copy) NSString *TryWebSockets;
@property(nonatomic, copy) NSString *ProtocolVersion;
@property(nonatomic, copy) NSString *TransportConnectTimeout;
@property(nonatomic, copy) NSString *LongPollDelay;

+ (instancetype)getMessageHub;
+ (void)saveMessageHubWithHub:(MessageHub *)hub;

@end

NS_ASSUME_NONNULL_END
