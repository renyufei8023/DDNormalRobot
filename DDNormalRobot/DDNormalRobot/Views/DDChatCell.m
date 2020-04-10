//
//  DDChatCell.m
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "DDChatCell.h"
#import "ClientParamsModel.h"
#import "EmojTextUtil.h"
#import "MessageItemModel.h"
#import <Masonry.h>
#import <QMUIKit.h>
#import <YYText.h>
#import <YYCategories.h>

@interface DDChatCell ()
@property(nonatomic, strong) UILabel *nameLab;
@property(nonatomic, strong) UILabel *timeLab;
@property(nonatomic, strong) UIView *topContentView;//时间和昵称的容器
@property(nonatomic, strong) YYLabel *contentLab;
@property(nonatomic, strong) UIView *chatBubbleImage;//气泡

@end
@implementation DDChatCell

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
    }
    return _chatBubbleImage;
}

- (YYLabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [YYLabel new];
        _contentLab.font = UIFontMake(14);
        _contentLab.textColor = UIColorMakeWithRGBA(69, 70, 56, 1.0);
        _contentLab.numberOfLines = 0;
        _contentLab.userInteractionEnabled = YES;
        _contentLab.preferredMaxLayoutWidth = SCREEN_WIDTH - 100 - 16 - 30;
    }
    return _contentLab;
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
    [self.chatBubbleImage addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.chatBubbleImage).inset(15);
        make.top.bottom.equalTo(self.chatBubbleImage).inset(10);
    }];
}

- (void)setModel:(MessageItemModel *)model {
    _model = model;
    self.timeLab.text = model.CreateTime;
    if (model.SenderType == 0) {//自己发的
        self.nameLab.text = @"我";
        [self.topContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-16);
            make.top.equalTo(self.contentView);
        }];
        self.chatBubbleImage.backgroundColor = UIColorMakeWithRGBA(176, 231, 123, 1.0);
        [self.chatBubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.contentView).offset(100);
            make.right.equalTo(self.contentView).offset(-16);
            make.bottom.equalTo(self.contentView).inset(16);
            make.top.equalTo(self.topContentView.mas_bottom).offset(10);
        }];
    }else {
        self.nameLab.text = model.SenderName;
        self.chatBubbleImage.backgroundColor = UIColorMakeWithRGBA(245, 245, 245, 1.0);
        [self.chatBubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.lessThanOrEqualTo(self.contentView).offset(-100);
            make.left.equalTo(self.contentView).offset(16);
            make.bottom.equalTo(self.contentView).inset(16);
            make.top.equalTo(self.topContentView.mas_bottom).offset(10);
        }];
        [self.topContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.top.equalTo(self.contentView);
        }];
    }
    __weak __typeof(self)weakSelf = self;
    if (model.AdditionContent.length > 0 && model.SenderType == 2) {
        self.contentLab.text = model.AdditionContent;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[model.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *question = data[@"RelatedQuestion"];
        NSString *content = [model.Content isNotBlank] ? [model.Content stringByAppendingString:@"\n"] : nil;
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content];
        att.yy_font = UIFontMake(14);
        att.yy_lineSpacing = 5;
        for (int i = 0; i < question.count; i++) {
            NSString *currentContent = [NSString stringWithFormat:@"%@.%@\n",@(i + 1),question[[NSString stringWithFormat:@"%@",@(i + 1)]]];
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:currentContent];
            att1.yy_font = UIFontMake(13);
            att1.yy_lineSpacing = 5;
            [att1 yy_setTextHighlightRange:NSMakeRange(0, currentContent.length) color:UIColorMakeWithRGBA(33, 99, 170, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NSString *str = [[text string] substringWithRange:range];
                if (weakSelf.selectQuestionBlock) {
                    weakSelf.selectQuestionBlock([str componentsSeparatedByString:@"."].lastObject,question[@"Pid"]);
                }
            }];
            [att appendAttributedString:att1];
        }
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"点击问题或回复数字查看答案"]];
        self.contentLab.attributedText = att;
    }else {
        self.contentLab.attributedText = [EmojTextUtil emojTextToAtt:model.Content];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
