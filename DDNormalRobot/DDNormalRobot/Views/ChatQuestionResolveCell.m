//
//  ChatQuestionResolveCell.m
//  TestSocket
//
//  Created by dudu on 2019/12/24.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "ChatQuestionResolveCell.h"
#import "MessageItemModel.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "YYText.h"

@interface ChatQuestionResolveCell ()
@property(nonatomic, strong) UILabel *nameLab;
@property(nonatomic, strong) UILabel *timeLab;
@property(nonatomic, strong) UIView *topContentView;//时间和昵称的容器
@property(nonatomic, strong) YYLabel *contentLab;
@property(nonatomic, strong) UIView *chatBubbleImage;//气泡
@property(nonatomic, strong) UILabel *tipLab;

@end
@implementation ChatQuestionResolveCell

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorMakeWithHex(@"333333")];
        _nameLab.text = @"机器人";
    }
    return _nameLab;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorMakeWithRGBA(177, 178,180, 1.0)];
        _timeLab.text = @"2019-12-23 10:00:00";
    }
    return _timeLab;
}

- (UIView *)chatBubbleImage {
    if (!_chatBubbleImage) {
        _chatBubbleImage = [UIView new];
        _chatBubbleImage.clipsToBounds = YES;
        _chatBubbleImage.layer.cornerRadius = 5;
        _chatBubbleImage.userInteractionEnabled = YES;
        _chatBubbleImage.backgroundColor = UIColorMakeWithRGBA(245, 245, 245, 1.0);
    }
    return _chatBubbleImage;
}

- (YYLabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [YYLabel new];
        _contentLab.font = UIFontMake(14);
        _contentLab.textColor = UIColorMakeWithHex(@"333333");
        _contentLab.numberOfLines = 0;
        _contentLab.userInteractionEnabled = YES;
        _contentLab.preferredMaxLayoutWidth = SCREEN_WIDTH - 100 - 16 - 30;
    }
    return _contentLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorMakeWithHex(@"666666")];
        _tipLab.text = @"已反馈";
        _tipLab.hidden = YES;
    }
    return _tipLab;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.topContentView = [UIView new];
    [self.contentView addSubview:self.topContentView];
    [self.topContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView);
    }];
    
    [self.topContentView addSubview:self.nameLab];
    [self.topContentView addSubview:self.timeLab];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topContentView);
        make.centerY.equalTo(self.topContentView);
        make.bottom.top.equalTo(self.topContentView).inset(5);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_right).offset(10);
        make.centerY.right.equalTo(self.topContentView);
    }];
    
    [self.contentView addSubview:self.chatBubbleImage];
    [self.chatBubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.lessThanOrEqualTo(self.contentView).offset(-100);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).inset(16);
        make.top.equalTo(self.topContentView.mas_bottom).offset(10);
    }];
    
    [self.chatBubbleImage addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.chatBubbleImage).inset(15);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = UIColorWhite;
    [self.chatBubbleImage addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.chatBubbleImage);
        make.top.equalTo(self.contentLab.mas_bottom).offset(16);
        make.height.mas_offset(0.5);
    }];
    
    [self.chatBubbleImage addSubview:self.tipLab];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.chatBubbleImage);
        make.bottom.equalTo(self.chatBubbleImage.mas_bottom).inset(15);
    }];
}

- (void)setModel:(MessageItemModel *)model {
    _model = model;
    self.timeLab.text = model.CreateTime;
    self.nameLab.text = model.SenderName;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:model.Content];
    [self resolveUrlWithAtt:att];
    self.contentLab.attributedText = att;
    [self updateUI];
}

- (void)resolveUrlWithAtt:(NSMutableAttributedString *)att {
    NSString *regulaStr = @"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSArray *arrayOfAllMatches = [regex matchesInString:att.string options:0 range:NSMakeRange(0, [att length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        [att yy_setTextHighlightRange:match.range color:UIColorMakeWithRGBA(33, 99, 170, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[text.string substringWithRange:range]] options:@{} completionHandler:nil];
        }];
    }
}

- (void)resolveClick:(QMUIButton *)sender {
    self.model.isSolved = YES;
    [self updateUI];
    if (self.chooseBlock) {
        self.chooseBlock(self.model,sender.tag == 100);
    }
}

- (void)updateUI {
    if (self.model.isSolved) {
        [self.chatBubbleImage.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[QMUIButton class]]) {
                obj.hidden = YES;
            }
        }];
        self.tipLab.hidden = NO;
    }else {
        self.tipLab.hidden = YES;
        NSArray *titles = @[@"解决",@"未解决"];
        for (int i = 0; i < titles.count; i++) {
            QMUIButton *resolveBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
            resolveBtn.tag = 100 + i;
            [resolveBtn setTitle:titles[i] forState:UIControlStateNormal];
            resolveBtn.titleLabel.font = UIFontMake(13);
            [resolveBtn setTitleColor:UIColorMakeWithRGBA(33, 99, 170, 1.0) forState:UIControlStateNormal];
            [resolveBtn addTarget:self action:@selector(resolveClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.chatBubbleImage addSubview:resolveBtn];
            [resolveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.chatBubbleImage);
                if (i == 0) {
                    make.left.equalTo(self.chatBubbleImage);
                }else {
                    make.right.equalTo(self.chatBubbleImage);
                }
                make.top.equalTo(self.contentLab.mas_bottom).offset(16.5);
                make.height.mas_offset(44);
                make.width.equalTo(self.chatBubbleImage).multipliedBy(0.5);
            }];
        }
    }
}

@end
