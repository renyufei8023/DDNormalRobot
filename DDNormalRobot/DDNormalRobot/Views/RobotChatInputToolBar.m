//
//  DDInputView.m
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "RobotChatInputToolBar.h"
#import "YYText.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "DDNetworkHelper.h"
#import "YHZEmotionsHelper.h"
#import "TZImagePickerController/TZImagePickerController.h"

@interface RobotChatInputToolBar () <QMUITextViewDelegate>
@property(nonatomic, strong) UIView *yhz_toolBarView;
@property(nonatomic, strong) QMUITextView *userInputView;
@property(nonatomic, strong) QMUIButton *endSessionBtn;
@property(nonatomic, strong) QMUIButton *sendMessageBtn;
@property(nonatomic, strong) YYLabel *endSessionLabel;

@end
@implementation RobotChatInputToolBar

- (UIView *)yhz_toolBarView {
    if (!_yhz_toolBarView) {
        _yhz_toolBarView = [[UIView alloc] init];
        _yhz_toolBarView.backgroundColor = UIColorMakeWithRGBA(250, 250, 250, 1.0);
        _yhz_toolBarView.qmui_borderPosition = QMUIViewBorderPositionTop | QMUIViewBorderPositionBottom;
    }
    return _yhz_toolBarView;
}

- (QMUITextView *)userInputView {
    if (!_userInputView) {
        _userInputView = [[QMUITextView alloc] init];
        _userInputView.delegate = self;
        _userInputView.placeholder = @"请输入";
        _userInputView.font = UIFontMake(15);
    }
    return _userInputView;
}

- (QMUIButton *)endSessionBtn {
    if (!_endSessionBtn) {
        _endSessionBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _endSessionBtn.titleLabel.font = UIFontMake(13);
        [_endSessionBtn setTitle:@"结束会话" forState:UIControlStateNormal];
        [_endSessionBtn setTitleColor:UIColorMakeWithHex(@"333333") forState:UIControlStateNormal];
        _endSessionBtn.hidden = YES;
        [_endSessionBtn addTarget:self action:@selector(endSession) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endSessionBtn;
}

- (QMUIButton *)sendMessageBtn {
    if (!_sendMessageBtn) {
        _sendMessageBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _sendMessageBtn.titleLabel.font = UIFontMake(13);
        [_sendMessageBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendMessageBtn.clipsToBounds = YES;
        _sendMessageBtn.layer.cornerRadius = 2;
        [_sendMessageBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_sendMessageBtn setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithRGBA(234, 102, 44, 1.0)] forState:UIControlStateNormal];
        _sendMessageBtn.enabled = false;
        [_sendMessageBtn addTarget:self action:@selector(sendMessageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendMessageBtn;
}

- (YYLabel *)endSessionLabel {
    if (!_endSessionLabel) {
        _endSessionLabel = [[YYLabel alloc] init];
        _endSessionLabel.numberOfLines = 0;
        _endSessionLabel.backgroundColor = UIColor.whiteColor;
        _endSessionLabel.numberOfLines = 0;
        _endSessionLabel.hidden = YES;
        _endSessionLabel.font = UIFontMake(13);
        _endSessionLabel.textColor = UIColorMakeWithHex(@"666666");
        _endSessionLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 100 - 16 - 30;
    }
    return _endSessionLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self updateUI];
    }
    return self;
}

- (void)updateUI {
    [self addSubview:self.yhz_toolBarView];
    [self.yhz_toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_offset(44);
    }];
    
    [self addSubview:self.userInputView];
    [self.userInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self).inset(5);
        make.top.equalTo(self.yhz_toolBarView.mas_bottom).offset(5);
    }];
    
    [self addSubview:self.sendMessageBtn];
    [self.sendMessageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-10);
        make.size.mas_offset(CGSizeMake(60, 28));
    }];
    
    [self addSubview:self.endSessionBtn];
    [self.endSessionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sendMessageBtn.mas_left).inset(12);
        make.centerY.equalTo(self.sendMessageBtn);
    }];
    
    NSMutableArray *images = @[@"表情",@"发送图片",@"评价"].mutableCopy;
    UIView *lastView = self.yhz_toolBarView;
    for (int i = 0; i < images.count; i++) {
        QMUIButton *btn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100 + i;
        if (i == 2) {
            btn.hidden = YES;
        }
        [btn setImage:[YHZEmotionsHelper generateImageFromBundleWithName:images[i]] forState:UIControlStateNormal];
        [self.yhz_toolBarView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(self.yhz_toolBarView).offset(16);
            }else {
                make.left.equalTo(lastView.mas_right).offset(16);
            }
            make.centerY.equalTo(self.yhz_toolBarView);
        }];
        [btn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        lastView = btn;
    }
    
    __weak __typeof(self)weakSelf = self;
    //处理会话结束
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"对话已结束，您可以 开始新的对话"];
    att.yy_color = UIColorMakeWithHex(@"666666");
    att.yy_font = UIFontMake(13);
    att.yy_alignment = NSTextAlignmentCenter;
    att.yy_lineSpacing = 5;
    [att yy_setTextHighlightRange:NSMakeRange(10, 6) color:UIColorMakeWithRGBA(33, 99, 170, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (weakSelf.newSessionCallBack) {
            weakSelf.newSessionCallBack();
        }
        weakSelf.endSessionLabel.hidden = YES;
    }];
    self.endSessionLabel.attributedText = att;
    [self addSubview:self.endSessionLabel];
    [self.endSessionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.userInputView);
    }];
}

- (void)sendMessageClick {
    if (self.sendMessageCallBack) {
        self.sendMessageCallBack(self.userInputView.text);
    }
    [self cleatInputView];
}

- (void)endSession {
    if (self.endSessionCallBack) {
        self.endSessionCallBack();
    }
}

- (void)menuBtnClick:(QMUIButton *)sender {
    NSInteger tage = sender.tag;
    if (tage == 100) {
        sender.selected = !sender.isSelected;
        if (self.emotionCallBack) {
            self.emotionCallBack(sender);
        }
    }else if (tage == 101) {
        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
        imagePicker.allowPickingVideo = false;
        imagePicker.allowTakeVideo = false;
        imagePicker.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = [NSString stringWithFormat:@"%@.jpg",str];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"fileInfoType"] = @"5";
            params[@"chunk"] = @"0";
            params[@"chunks"] = @"1";
            params[@"name"] = imageFileName;
            [DDNetworkHelper uploadImagesWithURL:@"https://upload.dd373.com/Api/Upload/UploadFile" parameters:params headers:nil name:@"fileInfoType" images:photos fileNames:nil imageScale:0.5 imageType:@"jpg" progress:^(NSProgress *progress) {
                
            } success:^(id responseObject) {
                if (!([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"])) {
                    [QMUITips hideAllTips];
                    [QMUITips showWithText:responseObject[@"msg"]];
                }else {
                    if (self.sendImageCallBack) {
                        self.sendImageCallBack(responseObject[@"StatusData"][@"ResultData"][@"FileUrl"]);
                    }
                }
            } failure:^(NSError *error) {
                [QMUITips hideAllTips];
                [QMUITips showError:@"您的网络好像不太给力，请稍后重试" inView:DefaultTipsParentView hideAfterDelay:2.0];
            }];
        };
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [[QMUIHelper visibleViewController] presentViewController:imagePicker animated:YES completion:NULL];
    }else {
        if (self.evalutionCallBack) {
            self.evalutionCallBack();
        }
    }
}

- (void)cleatInputView {
    self.userInputView.text = nil;
    [self.userInputView endEditing:YES];
}

- (void)yhz_appendEmojText:(NSString *)emojText {
    NSString *exsitText = self.userInputView.text;
    self.userInputView.text = [exsitText stringByAppendingString:emojText];
}

- (void)setHideGiftBtn:(BOOL)showHideGiftBtn {
    _hideGiftBtn = showHideGiftBtn;
    QMUIButton *btn = [self.yhz_toolBarView viewWithTag:102];
    btn.hidden = !showHideGiftBtn;
}

- (void)setHideEndSessionView:(BOOL)showHideEndSessionView {
    _hideEndSessionView = showHideEndSessionView;
    self.endSessionLabel.hidden = !showHideEndSessionView;
}

- (void)setHideEndSessionBtn:(BOOL)hideEndSessionBtn {
    _hideEndSessionBtn = hideEndSessionBtn;
    self.endSessionBtn.hidden = !hideEndSessionBtn;
}

#pragma mark - QMUITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.sendMessageBtn.enabled = textView.text.length > 0;
    if (_smartTipsCallBack) {
        _smartTipsCallBack(textView.text);
    }
}

//处理删除表情
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""] && range.length == 1) {//删除操作
        if ([textView.text hasSuffix:@"]"]) {
            if (textView.selectedRange.length == 0) {
                NSArray *match = [self.userInputView.text componentsSeparatedByString:@"]"];
                if (match.count > 0) {
                    NSString *lastMatch = [match[match.count - 2] stringByAppendingString:@"]"];
                    NSArray *prefixMatch = [lastMatch componentsSeparatedByString:@"[/"];
                    if (prefixMatch.count > 1) {
                        NSString *matchResult = [@"[/" stringByAppendingString:prefixMatch.lastObject];
                        NSRange matchRange = [textView.text rangeOfString:matchResult];
                        NSString *newText = [textView.text stringByReplacingCharactersInRange:matchRange withString:@""];
                        textView.text = newText;
                        return false;
                    }
                }
            }
        }
    }
    return YES;
}

@end
