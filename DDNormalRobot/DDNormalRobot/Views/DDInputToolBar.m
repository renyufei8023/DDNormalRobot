//
//  DDInputView.m
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "DDInputToolBar.h"
#import "YYText.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "DDNetworkHelper.h"
#import "YYCategories.h"
#import "DDHelper.h"
#import "TZImagePickerController/TZImagePickerController.h"

@interface DDInputToolBar () <QMUITextViewDelegate>
@property(nonatomic, strong) UIView *toolBarView;
@property(nonatomic, strong) QMUITextView *textView;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) QMUIButton *sendBtn;
@property(nonatomic, strong) YYLabel *endSessionView;

@end
@implementation DDInputToolBar

- (UIView *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [UIView new];
        _toolBarView.backgroundColor = UIColorMakeWithRGBA(250, 250, 250, 1.0);
        _toolBarView.qmui_borderPosition = QMUIViewBorderPositionTop | QMUIViewBorderPositionBottom;
    }
    return _toolBarView;
}

- (QMUITextView *)textView {
    if (!_textView) {
        _textView = [QMUITextView new];
        _textView.placeholder = @"请输入";
        _textView.delegate = self;
        _textView.font = UIFontMake(15);
    }
    return _textView;
}

- (QMUIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = UIFontMake(13);
        _sendBtn.clipsToBounds = YES;
        _sendBtn.layer.cornerRadius = 2;
        [_sendBtn setBackgroundImage:[UIImage imageWithColor:UIColorMakeWithRGBA(234, 102, 44, 1.0)] forState:UIControlStateNormal];
        _sendBtn.enabled = false;
    }
    return _sendBtn;
}

- (YYLabel *)endSessionView {
    if (!_endSessionView) {
        _endSessionView = [YYLabel new];
        _endSessionView.backgroundColor = UIColorWhite;
        _endSessionView.hidden = YES;
        _endSessionView.font = UIFontMake(13);
        _endSessionView.textColor = UIColorMakeWithHex(@"666666");
        _endSessionView.numberOfLines = 0;
        _endSessionView.preferredMaxLayoutWidth = SCREEN_WIDTH - 100 - 16 - 30;
    }
    return _endSessionView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    [self addSubview:self.toolBarView];
    [self.toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_offset(44);
    }];
    
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self).inset(5);
        make.top.equalTo(self.toolBarView.mas_bottom).offset(5);
    }];
    
    [self addSubview:self.sendBtn];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-10);
        make.size.mas_offset(CGSizeMake(60, 28));
    }];
    
    [self.sendBtn addTarget:self action:@selector(sendClick) forControlEvents:UIControlEventTouchUpInside];
    __weak __typeof(self)weakSelf = self;
    NSMutableArray *images = @[@"表情",@"发送图片",@"评价"].mutableCopy;
    UIView *lastView = self.toolBarView;
    for (int i = 0; i < images.count; i++) {
        QMUIButton *btn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100 + i;
        if (i == 2) {
            btn.hidden = YES;
        }
        [btn setImage:[DDHelper imageWithName:images[i]] forState:UIControlStateNormal];
        [self.toolBarView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(self.toolBarView).offset(16);
            }else {
                make.left.equalTo(lastView.mas_right).offset(16);
            }
            make.centerY.equalTo(self.toolBarView);
        }];
        [btn addBlockForControlEvents:UIControlEventTouchUpInside block:^(QMUIButton * _Nonnull sender) {
            if (i == 0) {
                sender.selected = !sender.isSelected;
                if (weakSelf.emotionBlock) {
                    weakSelf.emotionBlock(sender);
                }
            }else if (i == 1) {
                TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
                imagePicker.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                    [DDNetworkHelper uploadImagesWithURL:@"http://newupload.dd373.com/Upload/UploadFile" parameters:@{@"fileInfoType":@"5"} headers:nil name:@"fileInfoType" images:photos fileNames:nil imageScale:0.5 imageType:@"jpg" progress:^(NSProgress *progress) {
                        
                    } success:^(id responseObject) {
                        if (!([responseObject[@"StatusCode"] isEqualToString:@"0"] && [responseObject[@"StatusData"][@"ResultCode"] isEqualToString:@"0"])) {
                            [QMUITips hideAllTips];
                            [QMUITips showWithText:responseObject[@"msg"]];
                        }else {
                            if (weakSelf.sendImageBlock) {
                                weakSelf.sendImageBlock(responseObject[@"StatusData"][@"ResultData"][@"FileUrl"]);
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
                if (weakSelf.evalutionBlock) {
                    weakSelf.evalutionBlock();
                }
            }
        }];
        lastView = btn;
    }
    
    //处理会话结束
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"对话已结束，您可以 开始新的对话"];
    att.yy_font = UIFontMake(13);
    att.yy_color = UIColorMakeWithHex(@"666666");
    att.yy_lineSpacing = 5;
    att.yy_alignment = NSTextAlignmentCenter;
    [att yy_setTextHighlightRange:NSMakeRange(10, 6) color:UIColorMakeWithRGBA(33, 99, 170, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (weakSelf.newSessionBlock) {
            weakSelf.newSessionBlock();
        }
        weakSelf.endSessionView.hidden = YES;
    }];
    self.endSessionView.attributedText = att;
    [self addSubview:self.endSessionView];
    [self.endSessionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textView);
    }];
}

- (void)sendClick {
    if (self.sendMessageBlock) {
        self.sendMessageBlock(self.textView.text);
    }
    [self cleatTextView];
}

- (void)cleatTextView {
    self.textView.text = nil;
    [self.textView endEditing:YES];
}

- (void)appendEmojText:(NSString *)emojText {
    NSString *exsitText = self.textView.text;
    self.textView.text = [exsitText stringByAppendingString:emojText];
}

- (void)setShowHideGiftBtn:(BOOL)showHideGiftBtn {
    _showHideGiftBtn = showHideGiftBtn;
    QMUIButton *btn = [self.toolBarView viewWithTag:102];
    btn.hidden = !showHideGiftBtn;
}

- (void)setShowHideEndSessionView:(BOOL)showHideEndSessionView {
    _showHideEndSessionView = showHideEndSessionView;
    self.endSessionView.hidden = !showHideEndSessionView;
}

#pragma mark - QMUITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.sendBtn.enabled = textView.text.length > 0;
    if (_smartTipsBlock) {
        _smartTipsBlock(textView.text);
    }
}

//处理删除表情
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""] && range.length == 1) {//删除操作
        if ([textView.text hasSuffix:@"]"]) {
            if (textView.selectedRange.length == 0) {
                NSArray *match = [self.textView.text componentsSeparatedByString:@"]"];
                if (match.count > 0) {
                    NSString *lastMatch = [match[match.count - 2] stringByAppendingString:@"]"];
                    NSArray *prefixMatch = [lastMatch componentsSeparatedByString:@"[/"];
                    if (prefixMatch.count > 0) {
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
