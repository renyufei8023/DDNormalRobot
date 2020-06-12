//
//  DDChatViewController.m
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "DDChatViewController.h"
#import "DDInputToolBar.h"
#import "DDChatManager.h"
#import "DDChatCell.h"
#import "ClientParamsModel.h"
#import "MessageHub.h"
#import "DDHelper.h"
#import "BusinessItemModel.h"
#import "ChooseQuestionTypeCell.h"
#import "ChatQuestionResolveCell.h"
#import "TurnArtificalActionCell.h"
#import "DDChatImageCell.h"
#import "EvaluationView.h"
#import "DDEmotionView.h"
#import "RobotDetailModel.h"
#import "LineUpView.h"
#import "EvaluationedCell.h"
#import "SmartTipsView.h"
#import "MessageItemModel.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "YYModel.h"
#import "DDHelper.h"
#import "SDWebImage.h"
#import "YYCategories.h"
#import "DDNetworkHelper.h"

@interface DDChatViewController () <UITableViewDelegate,UITableViewDataSource,DDChatDelegate>
@property(nonatomic, strong) UIImageView *topImageBgView;
@property(nonatomic, strong) UIImageView *customerIcon;
@property(nonatomic, strong) UILabel *customerName;
@property(nonatomic, strong) UILabel *detailLab;
@property(nonatomic, strong) QMUIButton *turnToArtificial;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) DDInputToolBar *inputToolBar;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) DDEmotionView *emotionView;
@property(nonatomic, strong) SmartTipsView *tipsView;
@property(nonatomic, strong) QMUIKeyboardManager *keyboardManager;
@property(nonatomic, weak) QMUIModalPresentationViewController *lineUpModalVC;

@end

@implementation DDChatViewController

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIImageView *)topImageBgView {
    if (!_topImageBgView) {
        _topImageBgView = [[UIImageView alloc] initWithImage:[DDHelper imageWithName:@"chatTopbg"]];
        _topImageBgView.userInteractionEnabled = YES;
    }
    return _topImageBgView;
}

- (UIImageView *)customerIcon {
    if (!_customerIcon) {
        _customerIcon = [[UIImageView alloc] initWithImage:UIImageMake(@"未登录头像")];
        _customerIcon.layer.cornerRadius = 20;
        _customerIcon.clipsToBounds = YES;
    }
    return _customerIcon;
}

- (UILabel *)customerName {
    if (!_customerName) {
        _customerName = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorWhite];
        _customerName.text = @"";
    }
    return _customerName;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorWhite];
        _detailLab.text = @"";
    }
    return _detailLab;
}

- (QMUIButton *)turnToArtificial {
    if (!_turnToArtificial) {
        _turnToArtificial = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_turnToArtificial setTitle:@"转人工" forState:UIControlStateNormal];
        [_turnToArtificial setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _turnToArtificial.titleLabel.font = UIFontMake(12);
    }
    return _turnToArtificial;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 50;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DDChatCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[ChooseQuestionTypeCell class] forCellReuseIdentifier:@"questionType"];
        [_tableView registerClass:[ChatQuestionResolveCell class] forCellReuseIdentifier:@"resolve"];
        [_tableView registerClass:[TurnArtificalActionCell class] forCellReuseIdentifier:@"artifical"];
        [_tableView registerClass:[DDChatImageCell class] forCellReuseIdentifier:@"image"];
        [_tableView registerClass:[EvaluationedCell class] forCellReuseIdentifier:@"evaluation"];
    }
    return _tableView;
}

- (UIView *)inputToolBar {
    if (!_inputToolBar) {
        _inputToolBar = [[DDInputToolBar alloc] init];
    }
    return _inputToolBar;
}

- (SmartTipsView *)tipsView {
    if (!_tipsView) {
        _tipsView = [[SmartTipsView alloc] init];
        _tipsView.hidden = YES;
    }
    return _tipsView;
}

- (DDEmotionView *)emotionView {
    if (!_emotionView) {
        _emotionView = [DDEmotionView new];
        _emotionView.qmui_borderPosition = QMUIViewBorderPositionTop;
        _emotionView.emotions = [DDHelper ddEmotions];
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
    
    self.view.backgroundColor = UIColorWhite;
    
    DDChatManager *chatManager = [DDChatManager shareManager];
    chatManager.delegate = self;
    [chatManager startNewSession];//开始新会话
    
    __weak __typeof(self)weakSelf = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"serviceType"] integerValue] == 2) {
        self.turnToArtificial.hidden = YES;
    }
    
    self.inputToolBar.sendMessageBlock = ^(NSString * _Nonnull content) {
        if ([[userDefaults objectForKey:@"serviceType"] integerValue] == 2) {//这里说明接入人工了
            [chatManager sendNormalMessage:content additionContent:nil isRobot:false WithComplete:^(MessageItemModel * _Nonnull message) {
                
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
            [chatManager sendNormalMessage:content additionContent:additionContent isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {
                
            }];
        }
    };
    
    self.inputToolBar.smartTipsBlock = ^(NSString * _Nonnull content) {
        if ([[userDefaults objectForKey:@"serviceType"] integerValue] != 2) {//机器人的时候才需要智能提示
            [chatManager getRobotSmartTipsWithMessageContent:content WithComplete:^(MessageItemModel * _Nonnull message) {
                
            }];
        }
    };
    
    self.inputToolBar.sendImageBlock = ^(NSString * _Nonnull imageUrl) {
        [chatManager sendImageMessageWithImageUrl:imageUrl isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {

        }];
    };
    
    //表情按钮的回调
    self.inputToolBar.emotionBlock = ^(QMUIButton *sender) {
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
    self.inputToolBar.evalutionBlock = ^{
        EvaluationView *evaluationView = [[EvaluationView alloc] initWithFrame:weakSelf.view.bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:evaluationView];
        evaluationView.submitBlock = ^(NSString * _Nonnull type, NSString * _Nonnull content) {
            [weakSelf evaluationWithType:type memo:content];
        };
    };
    
    //新对话回调
    self.inputToolBar.newSessionBlock = ^{
        [chatManager startNewSession];
    };
    
    self.emotionView.selectEmotionBlock = ^(QMUIEmotion * _Nonnull emotion) {
        [weakSelf.inputToolBar appendEmojText:emotion.displayName];
        [weakSelf.emotionView removeFromSuperview];
    };
    
    self.tipsView.didSelectBlock = ^(NSString * _Nonnull content) {
        weakSelf.tipsView.hidden = YES;
        [weakSelf.inputToolBar cleatTextView];//清空输入框
        [[DDChatManager shareManager] sendNormalMessage:content additionContent:nil isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {

        }];
    };
    
    [self.turnToArtificial addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [weakSelf turnArtificalClick];
    }];
}

- (void)updateRobotInfo {
    if ([RobotDetailModel getRobotDetail]) {
        RobotDetailModel *robotDetail = [RobotDetailModel getRobotDetail];
        [self.customerIcon sd_setImageWithURL:[NSURL URLWithString:robotDetail.Avatar] placeholderImage:[UIImage imageWithColor:[UIColor qmui_randomColor]]];
        self.customerName.text = robotDetail.NickName;
        self.detailLab.text = robotDetail.Motto;
    }
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.topImageBgView];
    [self.topImageBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NavigationContentTopConstant);
        make.left.right.equalTo(self.view);
        make.height.mas_offset(60);
    }];
    
    [self.topImageBgView addSubview:self.customerIcon];
    [self.customerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topImageBgView).offset(16);
        make.centerY.equalTo(self.topImageBgView);
        make.height.width.mas_offset(40);
    }];
    
    [self.topImageBgView addSubview:self.customerName];
    [self.customerName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customerIcon.mas_right).offset(12);
        make.top.equalTo(self.topImageBgView).offset(11);
    }];
    
    [self.topImageBgView addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customerName);
        make.bottom.equalTo(self.topImageBgView).offset(-11);
        make.right.equalTo(self.topImageBgView).offset(-40);
    }];
    
    [self.topImageBgView addSubview:self.turnToArtificial];
    [self.turnToArtificial mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topImageBgView).inset(16);
        make.centerY.equalTo(self.topImageBgView);
    }];
    
    [self.view addSubview:self.inputToolBar];
    [self.inputToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_offset(150);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topImageBgView.mas_bottom);
        make.bottom.equalTo(self.inputToolBar.mas_top);
    }];
    
    [self.view addSubview:self.tipsView];
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputToolBar.mas_top).offset(-5);
        make.centerX.equalTo(self.view);
    }];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceType"] integerValue] == 2) {
        self.inputToolBar.showHideGiftBtn = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageItemModel *model = self.dataSource[indexPath.row];
    if (model.AppType == 2 && model.DialogType == 1) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[model.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (data[@"Pid"] && [data[@"RelatedQuestion"] count] == 0) {
            ChatQuestionResolveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resolve" forIndexPath:indexPath];
            cell.model = model;
            cell.chooseBlock = ^(MessageItemModel *model, BOOL resolve) {
                [[DDChatManager shareManager] questionMarkAsResolved:resolve withAdditionContent:data[@"Pid"] WithComplete:^(MessageItemModel * _Nonnull message) {
                    if (!resolve) {
                        MessageItemModel *model = [MessageItemModel new];
                        model.messageType = MessageTypeTurnArtifical;
                        [self.dataSource addObject:model];
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
            [DDNetworkHelper GET:@"http://consult.dd373.com/TransferCustomerServiceApi/TransferPeople" parameters:params headers:nil success:^(id responseObject) {
                if ([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"]) {
                    
                }else {
                    QMUIAlertController *alertVC = [QMUIAlertController alertControllerWithTitle:responseObject[@"StatusData"][@"ResultMsg"] message:nil preferredStyle:QMUIAlertControllerStyleAlert];
                    QMUIAlertAction *sureAction = [QMUIAlertAction actionWithTitle:@"好的" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
                    }];
                    [sureAction.button setBackgroundImage:[UIImage imageWithColor:UIColorMakeWithHex(@"#FF5B01")] forState:UIControlStateNormal];
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
                [[DDChatManager shareManager] sendNormalMessage:[content stringByReplacingOccurrencesOfString:@"\n" withString:@""] additionContent:nil isRobot:YES WithComplete:^(MessageItemModel * _Nonnull message) {
                    
                }];
            };
            return cell;
        }
    }
}

- (void)scrollToBottom:(BOOL)animation {
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger row = [self.tableView numberOfRowsInSection:0] - 1;
        if (row > 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animation];
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
                            [self.dataSource addObject:obj];
                            [self scrollToBottom:YES];
                        }
                    }
                    if (obj.DialogType == 6) {
                        obj.messageType = MessageTypeEvalution;
                        [self.dataSource addObject:obj];
                        [self scrollToBottom:YES];
                    }
                }else {
                    [self.dataSource addObject:obj];
                    [self scrollToBottom:YES];
                }
            }];
            
        }else {
            if (message.AppType == 1) {
                if ([message.AdditionContent isNotBlank]) {
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([data containsObjectForKey:@"Pid"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:data[@"Pid"] forKey:@"Pid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                if (message.AppType == 1 && message.DialogType == 2 && [message.Content isEqualToString:@"[]"]) {
                    return;
                }
                [self.dataSource addObject:message];
                [self scrollToBottom:YES];
            }else if (message.AppType == 2) {
                if (message.DialogType == 3) {
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSArray *datas = data[@"list"];
                    if (datas.count > 0) {
                        self.tipsView.dataSource = datas;
                        self.tipsView.hidden = false;
                    }else {
                        self.tipsView.hidden = YES;
                    }
                }else if (message.DialogType == 4 || message.DialogType == 6) {//这个是标记为解决或者未解决，不需要显示添加到数据源
                    
                }else {
                    NSDictionary *data;
                    if ([message.AdditionContent isNotBlank]) {
                        data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    }
                    
                    id content;
                    if ([data containsObjectForKey:@"Pid"]) {
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
                    [self.dataSource addObject:message];
                    [self scrollToBottom:YES];
                }
            }else {
                if (message.DialogType == 1) {
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    RobotDetailModel *robotDetail = [RobotDetailModel yy_modelWithDictionary:data];
                    [self.customerIcon sd_setImageWithURL:[NSURL URLWithString:robotDetail.Avatar] placeholderImage:[UIImage imageWithColor:[UIColor qmui_randomColor]]];
                    self.customerName.text = robotDetail.NickName;
                    self.detailLab.text = robotDetail.Motto;
                    [RobotDetailModel saveRobotDetail:robotDetail];
                    if (message.ServiceType.integerValue == 2) { //如果是人工客服，隐藏转人工按钮
                        if (_lineUpModalVC.isVisible) {
                            [_lineUpModalVC hideWithAnimated:YES completion:NULL];
                        }
                        //这里接入人工成功了
                        self.inputToolBar.showHideGiftBtn = YES;
                        self.turnToArtificial.hidden = YES;
                    }else {
                        self.inputToolBar.showHideGiftBtn = false;
                        self.turnToArtificial.hidden = false;
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
                        [self.dataSource addObject:message];
                        [self scrollToBottom:YES];
                    }
                }else if (message.DialogType == 8) {//排队
                    NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:[message.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([datas[@"show"] boolValue] == false) {
                        if (_lineUpModalVC.isVisible) {
                            [_lineUpModalVC hideWithAnimated:YES completion:NULL];
                        }
                    }else {
                        QMUIModalPresentationViewController *modalVC = [QMUIModalPresentationViewController new];
                        _lineUpModalVC = modalVC;
                        LineUpView *waitingView = [[LineUpView alloc] initWithFrame:self.view.bounds];
                        waitingView.model = message;
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
                    [[DDChatManager shareManager] endSession];
                    self.inputToolBar.showHideEndSessionView = YES;
                    self.tipsView.hidden = YES;
                    self.inputToolBar.showHideGiftBtn = false;
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

#pragma mark - 转人工第一步先调用接口
- (void)turnArtificalClick {
    [DDNetworkHelper GET:@"http://consult.dd373.com/CustomerBusinessTypeConfigApi/GetBusinessTypeConfigList" parameters:nil headers:nil success:^(id responseObject) {
        if ([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"]) {
            NSArray *datas = [NSArray yy_modelArrayWithClass:[BusinessItemModel class] json:responseObject[@"StatusData"][@"ResultData"]];
            //创建一个空的model放到数组里面
            MessageItemModel *model = [MessageItemModel new];
            model.chooseOptions = datas;
            model.messageType = MessageTypeChoose;
            [self.dataSource addObject:model];
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
        [DDNetworkHelper GET:[NSString stringWithFormat:@"http://consult.dd373.com/TransferCustomerServiceApi/RemovePaidui?userId=%@&dialogId=%@",[ClientParamsModel getClientParams].CustomerId,[ClientParamsModel getClientParams].DialogId] parameters:nil headers:nil success:^(id responseObject) {
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
    [DDNetworkHelper POST:@"http://consult.dd373.com/UserMessageApi/DialogOver" parameters:nil headers:nil success:^(id responseObject) {
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
    [DDNetworkHelper GET:@"http://consult.dd373.com/AppraiseApi/AppraiseResult" parameters:params headers:nil success:^(id responseObject) {
        [QMUITips hideAllTips];
        if ([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"]) {
            MessageItemModel *model = [MessageItemModel new];
            model.messageType = MessageTypeEvalution;
            model.AdditionContent = [@{@"AppraiseReselt":type} yy_modelToJSONString];
            [self.dataSource addObject:model];
            [self scrollToBottom:YES];
            [QMUIModalPresentationViewController hideAllVisibleModalPresentationViewControllerIfCan];
        }else {
            [QMUITips showWithText:responseObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        [QMUITips showError:@"您的网络好像不太给力，请稍后重试" inView:DefaultTipsParentView hideAfterDelay:2.0];
    }];
}

@end
