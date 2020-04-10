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
#import "YYCategories.h"

@interface ChatQuestionResolveCell ()
@property(nonatomic, strong) QMUILabel *contentLab;
@property(nonatomic, strong) UIView *chatBubbleImage;//气泡

@end
@implementation ChatQuestionResolveCell

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

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorMakeWithHex(@"333333")];
        _contentLab.numberOfLines = 0;
//        _contentLab.canPerformCopyAction = YES;
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
    [self.contentView addSubview:self.chatBubbleImage];
    [self.chatBubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.lessThanOrEqualTo(self.contentView).offset(-100);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).inset(16);
        make.top.equalTo(self.contentView).offset(10);
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
    
    __weak __typeof(self)weakSelf = self;
    NSArray *titles = @[@"解决",@"未解决"];
    for (int i = 0; i < titles.count; i++) {
        QMUIButton *resolveBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [resolveBtn setTitle:titles[i] forState:UIControlStateNormal];
        resolveBtn.titleLabel.font = UIFontMake(13);
        [resolveBtn setTitleColor:UIColorMakeWithRGBA(33, 99, 170, 1.0) forState:UIControlStateNormal];
        [resolveBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(QMUIButton * _Nonnull sender) {
            [self.chatBubbleImage.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[QMUIButton class]]) {
                    obj.hidden = YES;
                }
            }];
            UILabel *tipLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorMakeWithHex(@"666666")];
            tipLab.text = @"已反馈";
            [self.chatBubbleImage addSubview:tipLab];
            [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.chatBubbleImage);
                make.centerY.equalTo(sender);
            }];
            if (weakSelf.chooseBlock) {
                weakSelf.chooseBlock(weakSelf.model,i == 0);
            }
        }];
        [self.chatBubbleImage addSubview:resolveBtn];
        [resolveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.chatBubbleImage);
            if (i == 0) {
                make.left.equalTo(self.chatBubbleImage);
            }else {
                make.right.equalTo(self.chatBubbleImage);
            }
            make.top.equalTo(lineView.mas_bottom);
            make.height.mas_offset(44);
            make.width.equalTo(self.chatBubbleImage).multipliedBy(0.5);
        }];
    }
}

- (void)setModel:(MessageItemModel *)model {
    _model = model;
    self.contentLab.text = model.Content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
