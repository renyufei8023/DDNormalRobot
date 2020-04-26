//
//  WebSocketManager.m
//  TestSocket
//
//  Created by dudu on 2019/11/12.
//  Copyright © 2019 dudu. All rights reserved.
//

#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) {\
        block();\
    } else {\
        dispatch_async(queue, block);\
    }
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

#import "WebSocketManager.h"
#import "MessageHub.h"
#import "MessageItemModel.h"
#import "ClientParamsModel.h"
#import "QMUIKit.h"
#import "YYModel.h"
#import "AFNetworking.h"
#import "DDNetworkHelper.h"
#import "UserToken.h"

@interface WebSocketManager () <SRWebSocketDelegate>
@property (nonatomic, strong) NSTimer *heartBeatTimer; //心跳定时器
@property (nonatomic, strong) NSTimer *netWorkTestingTimer; //没有网络的时候检测网络定时器
@property (nonatomic, assign) NSTimeInterval reConnectTime; //重连时间
@property (nonatomic, strong) NSMutableArray *sendDataArray; //存储要发送给服务端的数据
@property (nonatomic, assign) BOOL isActivelyClose;//用于判断是否主动关闭长连接，如果是主动断开连接，连接失败的代理中，就不用执行 重新连接方法
@property (nonatomic, assign) NSInteger connectIndex;

@end
@implementation WebSocketManager

+ (instancetype)sharedManager {
    static WebSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init {
    if (self == [super init]) {
        self.reConnectTime = 0;
        self.isActivelyClose = NO;
        self.sendDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//建立长连接
- (void)connectServerIsRobot:(BOOL)isRobot {
    self.isActivelyClose = NO;
    self.isRobot = isRobot;
    if (_webSocket) {
        _webSocket.delegate = nil;
        [self.webSocket close];
        _webSocket = nil;
    }
    NSString *wbUrl;
    ClientParamsModel *clientParams = [ClientParamsModel getClientParams];
    MessageHub *hub = [MessageHub getMessageHub];
    if (isRobot) {
        wbUrl = [NSString stringWithFormat:@"ws://implus.dd373.com/cors/connect?transport=webSockets&clientProtocol=1.5&tag=0&appid=00c90442c2a3446d89eb80744bf88f73&&dialogId=%@&senderId=%@&serviceType=null&connectionToken=%@&connectionData=%@&tid=6",clientParams.DialogId,clientParams.CustomerId,[self URLEncodedString:hub.ConnectionToken], [self URLEncodedString:[@[@{@"name":@"implushub"}] yy_modelToJSONString]]];
    }else {
        wbUrl = [NSString stringWithFormat:@"ws://imservice.dd373.com/cors/connect?transport=webSockets&clientProtocol=1.5&userToken=%@&connectionToken=%@&connectionData=%@&tid=3",[UserToken getUserToken].UserToken,[self URLEncodedString:hub.ConnectionToken], [self URLEncodedString:[@[@{@"name":@"implushub"}] yy_modelToJSONString]]];
    }
    
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:wbUrl]];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

- (void)sendPing:(id)sender {
    [_webSocket sendPing:sender];
}

#pragma mark --------------------------------------------------
#pragma mark - socket delegate
///开始连接
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    if (self.delegate && [self.delegate respondsToSelector:@selector(webSocketDidOpenIsRobot:)]) {
        [self.delegate webSocketDidOpenIsRobot:_isRobot];
    }
    _connectIndex++;
    if (_connectIndex == 1) {
        
        [self sendCompanyInfo];
        if (_SocketDidOpenBlock) {
            _SocketDidOpenBlock();
        }
    }
    self.isConnect = YES;
    self.connectType = WebSocketConnect;
}

///连接失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败");
    self.isConnect = NO;
    self.connectType = WebSocketDisconnect;
    
    //判断网络环境
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable){ //没有网络
        [self noNetWorkStartTestingTimer];//开启网络检测定时器
    }else{ //有网络
    
        [self reConnectServer];//连接失败就重连
    }
}

///关闭连接
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    self.isConnect = NO;

    if (self.isActivelyClose){
        self.connectType = WebSocketDefault;
        return;
    }else{
        self.connectType = WebSocketDisconnect;
    }
    
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    [self destoryHeartBeat]; //断开连接时销毁心跳
    
    //判断网络环境
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) { //没有网络
        [self noNetWorkStartTestingTimer];//开启网络检测
    }else { //有网络
        NSLog(@"关闭连接");
        _webSocket = nil;
        [self reConnectServer];//连接失败就重连
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webSocketManagerDidReceiveMessageWithString:)]) {
        [self.delegate webSocketManagerDidReceiveMessageWithString:message];
    }
}

#pragma mark - NSTimer

//初始化心跳
- (void)initHeartBeat{
    //心跳没有被关闭
    if (self.heartBeatTimer) {
        return;
    }
    [self destoryHeartBeat];
    dispatch_main_async_safe(^{
        self.heartBeatTimer  = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];
    })
}

//重新连接
- (void)reConnectServer {
    if (self.webSocket.readyState == SR_OPEN){
        return;
    }
    
    if (self.reConnectTime > 1024) {  //重连10次 2^10 = 1024
        self.reConnectTime = 0;
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.webSocket.readyState == SR_OPEN && weakSelf.webSocket.readyState == SR_CONNECTING) {
            return;
        }
        [weakSelf connectServerIsRobot:weakSelf.isRobot];
        if (weakSelf.reConnectTime == 0){  //重连时间2的指数级增长
            weakSelf.reConnectTime = 2;
        }else{
            weakSelf.reConnectTime *= 2;
        }
    });
    
}

//发送心跳
- (void)senderheartBeat{
    //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    __weak __typeof(self)weakSelf = self;
    dispatch_main_async_safe(^{
        if (weakSelf.webSocket.readyState == SR_OPEN) {
            [weakSelf sendPing:@"{}"];
        }
    });
}

//没有网络的时候开始定时 -- 用于网络检测
- (void)noNetWorkStartTestingTimer {
    __weak __typeof(self)weakSelf = self;
    dispatch_main_async_safe(^{
        weakSelf.netWorkTestingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(noNetWorkStartTesting) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.netWorkTestingTimer forMode:NSDefaultRunLoopMode];
    });
}

//定时检测网络
- (void)noNetWorkStartTesting {
    //有网络
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        //关闭网络检测定时器
        [self destoryNetWorkStartTesting];
        //开始重连
        [self reConnectServer];
    }
}

//取消网络检测
- (void)destoryNetWorkStartTesting {
    __weak __typeof(self)weakSelf = self;
    dispatch_main_async_safe(^{
        if (weakSelf.netWorkTestingTimer) {
            [weakSelf.netWorkTestingTimer invalidate];
            weakSelf.netWorkTestingTimer = nil;
        }
    });
}


//取消心跳
- (void)destoryHeartBeat {
    __weak __typeof(self)weakSelf = self;
    dispatch_main_async_safe(^{
        if (weakSelf.heartBeatTimer) {
            [weakSelf.heartBeatTimer invalidate];
            weakSelf.heartBeatTimer = nil;
        }
    });
}


//关闭长连接
- (void)closeSocket {
    self.isActivelyClose = YES;
    self.isConnect = NO;
    self.connectType = WebSocketDefault;
    if(self.webSocket) {
        [self.webSocket close];
        _webSocket = nil;
    }
    
    //关闭心跳定时器
    [self destoryHeartBeat];
    
    //关闭网络检测定时器
    [self destoryNetWorkStartTesting];
}


//发送数据给服务器
- (void)sendDataToServer:(NSString *)data {
    [self.sendDataArray addObject:data];
    
    //没有网络
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        //开启网络检测定时器
        [self noNetWorkStartTestingTimer];
    }else {//有网络
        if(self.webSocket != nil) {
            // 只有长连接OPEN开启状态才能调 send 方法，不然会Crash
            if (self.webSocket.readyState == SR_OPEN) {
                [_webSocket send:data];
            }else if (self.webSocket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后会去自动同步数据");
            }else if (self.webSocket.readyState == SR_CLOSING || self.webSocket.readyState == SR_CLOSED) {
                //调用 reConnectServer 方法重连,连接成功后 继续发送数据
                [self reConnectServer];
            }
        }else {
            [self connectServerIsRobot:_isRobot]; //连接服务器
        }
    }
}

- (void)sendCompanyInfo {
    [DDNetworkHelper POST:@"http://consult.dd373.com/UserMessageApi/UserMetaData" parameters:nil headers:nil success:^(id responseObject) {
        if (!([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"])) {
            [QMUITips showWithText:responseObject[@"StatusData"][@"ResultMsg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//使用该方法可以省去调用js的encodeURIComponent
- (NSString *)URLEncodedString:(NSString *)str {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}
#pragma clang diagnostic pop

@end
