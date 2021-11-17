//
//  YHZRobotChatViewController.m
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "YHZRobotChatViewController.h"
#import "RobotChatInputToolBar.h"
#import "YHZChatManager.h"
#import "DDChatCell.h"
#import "ClientParamsModel.h"
#import "MessageHub.h"
#import "YHZEmotionsHelper.h"
#import "BusinessItemModel.h"
#import "ChooseQuestionTypeCell.h"
#import "ChatQuestionResolveCell.h"
#import "TurnArtificalActionCell.h"
#import "DDChatImageCell.h"
#import "EvaluationView.h"
#import "DDEmotionView.h"
#import "RobotDetailModel.h"
#import "QueueView.h"
#import "EvaluationedCell.h"
#import "SmartAlertView.h"
#import "MessageItemModel.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "YYModel.h"
#import "YHZEmotionsHelper.h"
#import "SDWebImage.h"
#import "DDNetworkHelper.h"
#import "NSString+Emoji.h"
#import "YHZSocketClientManager.h"

@interface YHZRobotChatViewController () <UITableViewDelegate,UITableViewDataSource,DDChatDelegate>
@property(nonatomic, strong) UIImageView *topContainerView;
@property(nonatomic, strong) UIImageView *serviceIcon;
@property(nonatomic, strong) UILabel *serviceName;
@property(nonatomic, strong) UILabel *tipLab;
@property(nonatomic, strong) QMUIButton *onlineButton;
@property(nonatomic, strong) UITableView *listView;
@property(nonatomic, strong) RobotChatInputToolBar *inputToolBar;
@property(nonatomic, strong) NSMutableArray *messageDatas;
@property(nonatomic, strong) DDEmotionView *emotionView;
@property(nonatomic, strong) SmartAlertView *tipsView;
@property(nonatomic, strong) QMUIKeyboardManager *keyboardManager;
@property(nonatomic, weak) QMUIModalPresentationViewController *queueModalVC;

@end

@implementation YHZRobotChatViewController

- (NSMutableArray *)messageDatas {
    if (!_messageDatas) {
        _messageDatas = [NSMutableArray array];
    }
    return _messageDatas;
}

- (UIImageView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[UIImageView alloc] initWithImage:[YHZEmotionsHelper generateImageFromBundleWithName:@"chatTopbg"]];
        _topContainerView.userInteractionEnabled = YES;
    }
    return _topContainerView;
}

- (UIImageView *)serviceIcon {
    if (!_serviceIcon) {
        _serviceIcon = [[UIImageView alloc] initWithImage:UIImageMake(@"未登录头像")];
        _serviceIcon.clipsToBounds = YES;
        _serviceIcon.layer.cornerRadius = 20;
    }
    return _serviceIcon;
}

- (UILabel *)serviceName {
    if (!_serviceName) {
        _serviceName = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColor.whiteColor];
    }
    return _serviceName;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColor.whiteColor];
    }
    return _tipLab;
}

- (QMUIButton *)onlineButton {
    if (!_onlineButton) {
        _onlineButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _onlineButton.titleLabel.font = UIFontMake(12);
        [_onlineButton setTitle:@"转人工" forState:UIControlStateNormal];
        [_onlineButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    return _onlineButton;
}

- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listView registerClass:[DDChatCell class] forCellReuseIdentifier:@"cell"];
        [_listView registerClass:[ChooseQuestionTypeCell class] forCellReuseIdentifier:@"questionType"];
        [_listView registerClass:[ChatQuestionResolveCell class] forCellReuseIdentifier:@"resolve"];
        [_listView registerClass:[TurnArtificalActionCell class] forCellReuseIdentifier:@"artifical"];
        [_listView registerClass:[DDChatImageCell class] forCellReuseIdentifier:@"image"];
        [_listView registerClass:[EvaluationedCell class] forCellReuseIdentifier:@"evaluation"];
        _listView.rowHeight = UITableViewAutomaticDimension;
        _listView.estimatedRowHeight = 50;
    }
    return _listView;
}

- (UIView *)inputToolBar {
    if (!_inputToolBar) {
        _inputToolBar = [[RobotChatInputToolBar alloc] init];
    }
    return _inputToolBar;
}

- (SmartAlertView *)tipsView {
    if (!_tipsView) {
        _tipsView = [[SmartAlertView alloc] init];
        _tipsView.hidden = YES;
    }
    return _tipsView;
}

- (DDEmotionView *)emotionView {
    if (!_emotionView) {
        _emotionView = [DDEmotionView new];
        _emotionView.qmui_borderPosition = QMUIViewBorderPositionTop;
        _emotionView.emotions = [YHZEmotionsHelper get_all_emotions];
        _emotionView.backgroundColor = UIColorWhite;
    }
    return _emotionView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tipsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(UIApplication.sharedApplication.keyWindow).offset(NavigationContentTopConstant + 20);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self updateUI];
    
    YHZChatManager *chatManager = [YHZChatManager shareInstance];
    chatManager.delegate = self;
    [chatManager yhz_startNewSession];//开始新会话
    
    __weak __typeof(self)weakSelf = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"serviceType"] integerValue] == 2) {
        self.onlineButton.hidden = YES;
    }
    
    self.inputToolBar.sendMessageCallBack = ^(NSString * _Nonnull content) {
        if ([[userDefaults objectForKey:@"serviceType"] integerValue] == 2) {//这里说明接入人工了
            [chatManager yhz_sendNormalMessage:content additionContent:nil isRobot:false WithComplete:^(MessageItemModel * _Nonnull message) {
                
            }];
        }else {
            id saveContent = [userDefaults objectForKey:@"Pid"];
            NSString *additionContent;
            if (saveContent) {
                if ([saveContent isKindOfClass:[NSArray class]]) {
                    if (content.integerValue <= [saveContent count] && content.integerValue > 0) {
                        additionContent = saveContent[content.integerValue - 1];
                        additionContent = [additionContent stringByAppendingString:@"#"];
                    }else {
                        additionContent = @"0";
                    }
                }else {
                    additionContent = saveContent;
                }
            }
            [chatManager yhz_sendNormalMessage:content additionContent:additionContent isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {
                
            }];
        }
    };
    
    self.inputToolBar.smartTipsCallBack = ^(NSString * _Nonnull content) {
        if ([[userDefaults objectForKey:@"serviceType"] integerValue] != 2) {//机器人的时候才需要智能提示
            [chatManager yhz_getRobotSmartTipsWithMessageContent:content WithComplete:^(MessageItemModel * _Nonnull message) {
                
            }];
        }
    };
    
    self.inputToolBar.sendImageCallBack = ^(NSString * _Nonnull imageUrl) {
        [chatManager yhz_sendImageMessageWithImageUrl:imageUrl isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {

        }];
    };
    
    //表情按钮的回调
    self.inputToolBar.emotionCallBack = ^(QMUIButton *sender) {
        if (sender.selected) {
            [weakSelf.view addSubview:weakSelf.emotionView];
            [weakSelf.emotionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(weakSelf.view);
                make.bottom.equalTo(weakSelf.inputToolBar.mas_top);
            }];
        }else {
            [weakSelf.emotionView removeFromSuperview];
        }
    };
    
    //评价按钮的回调
    self.inputToolBar.evalutionCallBack = ^{
        EvaluationView *evaluationView = [[EvaluationView alloc] initWithFrame:weakSelf.view.bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:evaluationView];
        evaluationView.submitBlock = ^(NSString * _Nonnull type, NSString * _Nonnull content) {
            [weakSelf evaluationWithType:type memo:content];
        };
    };
    
    self.inputToolBar.endSessionCallBack = ^{
        [weakSelf endSession];
    };
    
    //新对话回调
    self.inputToolBar.newSessionCallBack = ^{
        [chatManager yhz_startNewSession];
    };
    
    self.emotionView.selectEmotionBlock = ^(QMUIEmotion * _Nonnull emotion) {
        [weakSelf.inputToolBar yhz_appendEmojText:emotion.displayName];
        [weakSelf.emotionView removeFromSuperview];
    };
    
    self.tipsView.didSelectCallBack = ^(NSString * _Nonnull content) {
        weakSelf.tipsView.hidden = YES;
        [weakSelf.inputToolBar cleatInputView];//清空输入框
        [[YHZChatManager shareInstance] yhz_sendNormalMessage:content additionContent:nil isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {

        }];
    };
    
    [self.onlineButton addTarget:self action:@selector(customerServiceClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateRobotInfo {
    if ([RobotDetailModel getRobotDetail]) {
        RobotDetailModel *robotDetail = [RobotDetailModel getRobotDetail];
        [self.serviceIcon sd_setImageWithURL:[NSURL URLWithString:robotDetail.Avatar] placeholderImage:[UIImage qmui_imageWithColor:[UIColor qmui_randomColor]]];
        self.serviceName.text = robotDetail.NickName;
        self.tipLab.text = robotDetail.Motto;
    }
}

- (void)updateUI {
    [self.view addSubview:self.topContainerView];
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavigationContentTopConstant);
        make.left.right.equalTo(self.view);
        make.height.mas_offset(60);
    }];
    
    [self.topContainerView addSubview:self.serviceIcon];
    [self.serviceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topContainerView).offset(16);
        make.centerY.equalTo(self.topContainerView);
        make.height.width.mas_offset(40);
    }];
    
    [self.topContainerView addSubview:self.serviceName];
    [self.serviceName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.serviceIcon.mas_right).offset(12);
        make.top.equalTo(self.topContainerView).offset(11);
    }];
    
    [self.topContainerView addSubview:self.tipLab];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.serviceName);
        make.bottom.equalTo(self.topContainerView).offset(-11);
        make.right.equalTo(self.topContainerView).offset(-40);
    }];
    
    [self.topContainerView addSubview:self.onlineButton];
    [self.onlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topContainerView).inset(16);
        make.centerY.equalTo(self.topContainerView);
    }];
    
    [self.view addSubview:self.inputToolBar];
    [self.inputToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_offset(150);
    }];
    
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topContainerView.mas_bottom);
        make.bottom.equalTo(self.inputToolBar.mas_top);
    }];
    
    [self.view addSubview:self.tipsView];
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputToolBar.mas_top).offset(-5);
        make.centerX.equalTo(self.view);
    }];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceType"] integerValue] == 2) {
        self.inputToolBar.hideGiftBtn = YES;
        self.inputToolBar.hideEndSessionBtn = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageItemModel *model = self.messageDatas[indexPath.row];
    if (model.AppType == 2 && model.DialogType == 1) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[model.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (data[@"Pid"] && [data[@"RelatedQuestion"] count] == 0) {
            ChatQuestionResolveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resolve" forIndexPath:indexPath];
            cell.model = model;
            cell.chooseBlock = ^(MessageItemModel *model, BOOL resolve) {
                [[YHZChatManager shareInstance] yhz_questionMarkAsResolved:resolve withAdditionContent:data[@"Pid"] WithComplete:^(MessageItemModel * _Nonnull message) {
                    if (!resolve) {
                        MessageItemModel *model = [MessageItemModel new];
                        model.messageType = MessageTypeTurnArtifical;
                        [self.messageDatas addObject:model];
                        [self scrollToBottom:YES];
                    }
                }];
            };
            return cell;
        }
    }
    
    if (model.messageType == MessageTypeChoose) {
        ChooseQuestionTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"questionType" forIndexPath:indexPath];
        cell.model = model;
        cell.chooseBlock = ^(BusinessItemModel * _Nonnull businessModel) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"userId"] = [ClientParamsModel getClientParams].CustomerId;
            params[@"dialogId"] = [ClientParamsModel getClientParams].DialogId;
            params[@"business"] = businessModel.Id;
            [DDNetworkHelper GET:@"https://consult.dd373.com/TransferCustomerServiceApi/TransferPeople" parameters:params headers:nil success:^(id responseObject) {
                if ([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"]) {
                    
                }else {
                    QMUIAlertController *alertVC = [QMUIAlertController alertControllerWithTitle:responseObject[@"StatusData"][@"ResultMsg"] message:nil preferredStyle:QMUIAlertControllerStyleAlert];
                    QMUIAlertAction *sureAction = [QMUIAlertAction actionWithTitle:@"好的" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
                    }];
                    [sureAction.button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#FF5B01")] forState:UIControlStateNormal];
                    [alertVC addAction:sureAction];
                    [alertVC showWithAnimated:YES];
                }
            } failure:^(NSError *error) {
                [QMUITips hideAllTips];
                [QMUITips showError:@"您的网络好像不太给力，请稍后重试" inView:DefaultTipsParentView hideAfterDelay:2.0];
            }];
        };
        return cell;
    }else if (model.messageType == MessageTypeTurnArtifical) {
        TurnArtificalActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"artifical" forIndexPath:indexPath];
        cell.actionClick = ^{
            [self turnArtificalClick];
        };
        return cell;
    }else if (model.messageType == MessageTypeEvalution) {
        EvaluationedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"evaluation" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else {
        if (model.ContentType == 2 && [model.Content containsString:@"//"]) {
            DDChatImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }else {
            DDChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.model = model;
            cell.selectQuestionBlock = ^(NSString * _Nonnull content, NSString * _Nonnull questionID) {
                [[YHZChatManager shareInstance] yhz_sendNormalMessage:[content stringByReplacingOccurrencesOfString:@"\n" withString:@""] additionContent:nil isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {
                    
                }];
            };
            return cell;
        }
    }
}

- (void)scrollToBottom:(BOOL)animation {
    [self.listView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger row = [self.listView numberOfRowsInSection:0] - 1;
        if (row > 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.listView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animation];
        }
    });
}

- (void)chatManagerDidReceiveMessageWithMessageItem:(MessageItemModel *)message {
    __weak __typeof(self)weakSelf = self;
    NSLog(@"---接收到消息%@",[message yy_modelDescription]);
    if (message.SenderType != 0) {//这里判断下是不是用户发的消息，不是的话把之前记录的上个问题的id清空
        if (message.DialogType != 3) {//这个是智能提示
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Pid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if (message) {
        if ([NSArray yy_modelArrayWithClass:[MessageItemModel class] json:message.Content].count > 0) {
            NSArray<MessageItemModel *> *datas = [NSArray yy_modelArrayWithClass:[MessageItemModel class] json:message.Content];
            [datas enumerateObjectsUsingBlock:^(MessageItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.AppType == 3) {
                    if (obj.DialogType == 5) {
                        if ([obj.Content length] > 0) {
                            [self.messageDatas addObject:obj];
                            [self scrollToBottom:YES];
                        }
                    }
                    if (obj.DialogType == 6) {
                        obj.messageType = MessageTypeEvalution;
                        if ([obj.ServiceType isEqualToString:@"1"]) {
                            [self.messageDatas addObject:obj];
                        }
                        [self scrollToBottom:YES];
                    }
                }else {
                    [self.messageDatas addObject:obj];
                    [self scrollToBottom:YES];
                }
            }];
            
        }else {
            if (message.AppType == 1) {
                if ([message.AdditionContent dd_isNotBlank]) {
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([[data allKeys] containsObject:@"Pid"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:data[@"Pid"] forKey:@"Pid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                if (message.AppType == 1 && message.DialogType == 2 && [message.Content isEqualToString:@"[]"]) {
                    return;
                }
                [self.messageDatas addObject:message];
                [self scrollToBottom:YES];
            }else if (message.AppType == 2) {
                if (message.DialogType == 3) {
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSArray *datas = data[@"list"];
                    if (datas.count > 0) {
                        self.tipsView.dataArray = datas;
                        self.tipsView.hidden = false;
                    }else {
                        self.tipsView.hidden = YES;
                    }
                }else if (message.DialogType == 4 || message.DialogType == 6) {//这个是标记为解决或者未解决，不需要显示添加到数据源
                    
                }else {
                    NSDictionary *data;
                    if ([message.AdditionContent dd_isNotBlank]) {
                        data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    }
                    
                    id content;
                    if ([[data allKeys] containsObject:@"Pid"]) {
                        if ([data[@"Pid"] isKindOfClass:[NSArray class]]) {
                            NSMutableArray *datas = [data[@"Pid"] mutableCopy];
                            [datas enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([obj isKindOfClass:[NSNull class]]) {
                                    [datas removeObject:obj];
                                }
                            }];
                            content = datas;
                        }else {
                            content = data[@"Pid"];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:content forKey:@"Pid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    [self.messageDatas addObject:message];
                    [self scrollToBottom:YES];
                }
            }else {
                if (message.DialogType == 1) {
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    RobotDetailModel *robotDetail = [RobotDetailModel yy_modelWithDictionary:data];
                    [self.serviceIcon sd_setImageWithURL:[NSURL URLWithString:robotDetail.Avatar] placeholderImage:[UIImage qmui_imageWithColor:[UIColor qmui_randomColor]]];
                    self.serviceName.text = robotDetail.NickName;
                    self.tipLab.text = robotDetail.Motto;
                    [RobotDetailModel saveRobotDetail:robotDetail];
                    if (message.ServiceType.integerValue == 2) { //如果是人工客服，隐藏转人工按钮
                        if (_queueModalVC.isVisible) {
                            [_queueModalVC hideWithAnimated:YES completion:NULL];
                        }
                        //这里接入人工成功了
                        self.inputToolBar.hideGiftBtn = YES;
                        self.inputToolBar.hideEndSessionBtn = YES;
                        self.onlineButton.hidden = YES;
                    }else {
                        self.inputToolBar.hideGiftBtn = false;
                        self.inputToolBar.hideEndSessionBtn = false;
                        self.onlineButton.hidden = false;
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:robotDetail.ServiceType forKey:@"serviceType"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    if ([QMUIModalPresentationViewController isAnyModalPresentationViewControllerVisible]) {
                        [QMUIModalPresentationViewController hideAllVisibleModalPresentationViewControllerIfCan];
                    }
                }else if (message.DialogType == 3) {//收到邀请评价
                    EvaluationView *evaluationView = [[EvaluationView alloc] initWithFrame:self.view.bounds];
                    [[UIApplication sharedApplication].keyWindow addSubview:evaluationView];
                    evaluationView.submitBlock = ^(NSString * _Nonnull type, NSString * _Nonnull content) {
                        [weakSelf evaluationWithType:type memo:content];
                    };
                }else if (message.DialogType == 5) {//之前没有聊天的时候回返回这个，
                    if ([message.Content length] > 0) {
                        [self.messageDatas addObject:message];
                        [self scrollToBottom:YES];
                    }
                }else if (message.DialogType == 8) {//排队
                    NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([datas[@"show"] boolValue] == false) {
                        if (_queueModalVC.isVisible) {
                            [_queueModalVC hideWithAnimated:YES completion:NULL];
                        }
                    }else {
                        QMUIModalPresentationViewController *modalVC = [QMUIModalPresentationViewController new];
                        _queueModalVC = modalVC;
                        QueueView *waitingView = [[QueueView alloc] initWithFrame:self.view.bounds];
                        waitingView.messageModel = message;
                        modalVC.contentView = waitingView;
                        modalVC.contentViewMargins = UIEdgeInsetsZero;
                        [modalVC showInView:self.view animated:YES completion:NULL];
                    }
                }else if (message.DialogType == 7) {//结束会话
                    [self DialogOver];
                    if ([QMUIModalPresentationViewController isAnyModalPresentationViewControllerVisible]) {
                        [QMUIModalPresentationViewController hideAllVisibleModalPresentationViewControllerIfCan];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"serviceType"];
                    [[YHZChatManager shareInstance] yhz_endSession];
                    self.inputToolBar.hideEndSessionView = YES;
                    self.tipsView.hidden = YES;
                    self.inputToolBar.hideGiftBtn = false;
                    self.inputToolBar.hideEndSessionBtn = false;
                }else if (message.DialogType == 6) {//评价消息
                    message.messageType = MessageTypeEvalution;
                    [self scrollToBottom:YES];
                }
            }
        }
    }
}

- (void)robotInfoChange {
    [self updateRobotInfo];
}

- (void)customerServiceClick {
    [self turnArtificalClick];
}

#pragma mark - 转人工第一步先调用接口
- (void)turnArtificalClick {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"appid"] = [YHZSocketClientManager getRobotAppID];
    [DDNetworkHelper GET:@"https://consult.dd373.com/CustomerBusinessTypeConfigApi/GetBusinessTypeConfigList" parameters:parameters headers:nil success:^(id responseObject) {
        if ([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"]) {
            NSArray *datas = [NSArray yy_modelArrayWithClass:[BusinessItemModel class] json:responseObject[@"StatusData"][@"ResultData"]];
            //创建一个空的model放到数组里面
            MessageItemModel *model = [MessageItemModel new];
            model.chooseOptions = datas;
            model.messageType = MessageTypeChoose;
            [self.messageDatas addObject:model];
            [self scrollToBottom:YES];
        }else {
            [QMUITips showWithText:responseObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 删除排队队列
- (void)delQueue {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"serviceType"] integerValue] != 2 && [[userDefaults objectForKey:@"isQueue"] integerValue] == 1) {
        [DDNetworkHelper GET:[NSString stringWithFormat:@"https://consult.dd373.com/TransferCustomerServiceApi/RemovePaidui?userId=%@&dialogId=%@",[ClientParamsModel getClientParams].CustomerId,[ClientParamsModel getClientParams].DialogId] parameters:nil headers:nil success:^(id responseObject) {
            if (!([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"])) {
                [QMUITips showWithText:responseObject[@"msg"]];
            }
        } failure:^(NSError *error) {
            [QMUITips showError:@"您的网络好像不太给力，请稍后重试" inView:DefaultTipsParentView hideAfterDelay:2.0];
        }];
    }
}

#pragma mark - 结束会话
- (void)DialogOver {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"appid"] = [YHZSocketClientManager getRobotAppID];
    params[@"customerId"] = [ClientParamsModel getClientParams].CustomerId;
    params[@"dialogId"] = [ClientParamsModel getClientParams].DialogId;
    params[@"customerName"] = [ClientParamsModel getClientParams].CustomerName;
    [DDNetworkHelper POST:@"https://consult.dd373.com/UserMessageApi/DialogOver" parameters:params headers:nil success:^(id responseObject) {
        if (!([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"])) {
            [QMUITips showWithText:responseObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        [QMUITips showError:@"您的网络好像不太给力，请稍后重试" inView:DefaultTipsParentView hideAfterDelay:2.0];
    }];
}

- (void)evaluationWithType:(NSString *)type memo:(NSString *)memo {
    [QMUITips showLoadingInView:DefaultTipsParentView];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = [ClientParamsModel getClientParams].CustomerId;
    params[@"dialogId"] = [ClientParamsModel getClientParams].DialogId;
    params[@"type"] = type;
    params[@"memo"] = memo;
    [DDNetworkHelper GET:@"https://consult.dd373.com/AppraiseApi/AppraiseResult" parameters:params headers:nil success:^(id responseObject) {
        [QMUITips hideAllTips];
        if ([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"]) {
            MessageItemModel *model = [MessageItemModel new];
            model.messageType = MessageTypeEvalution;
            model.AdditionContent = [@{@"AppraiseReselt":type} yy_modelToJSONString];
            [self.messageDatas addObject:model];
            [self scrollToBottom:YES];
            [QMUIModalPresentationViewController hideAllVisibleModalPresentationViewControllerIfCan];
            [self endSession];
        }else {
            if ([responseObject[@"msg"] dd_isNotBlank]) {
                [QMUITips showWithText:responseObject[@"msg"]];
            }
        }
    } failure:^(NSError *error) {
        [QMUITips showError:@"您的网络好像不太给力，请稍后重试" inView:DefaultTipsParentView hideAfterDelay:2.0];
    }];
}

- (void)endSession {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = [ClientParamsModel getClientParams].CustomerId;
    params[@"dialogId"] = [ClientParamsModel getClientParams].DialogId;
    [DDNetworkHelper GET:@"https://consult.dd373.com/AppraiseApi/DialogEndByUser" parameters:params headers:nil success:^(id responseObject) {
        
    } failure:^(NSError *error) {
        
    }];
}

@end
