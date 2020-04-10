//
//  ChooseQuestionTypeCell.m
//  TestSocket
//
//  Created by dudu on 2019/12/24.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "ChooseQuestionTypeCell.h"
#import "BusinessItemModel.h"
#import "MessageItemModel.h"
#import "YYText.h"
#import "QMUIKit.h"
#import "Masonry.h"

@interface ChooseQuestionTypeCell ()
@property(nonatomic, strong) YYLabel *contentLab;
@property(nonatomic, strong) UIView *chatBubbleImage;//气泡

@end
@implementation ChooseQuestionTypeCell

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
    [self.contentView addSubview:self.chatBubbleImage];
    [self.chatBubbleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.lessThanOrEqualTo(self.contentView).offset(-100);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).inset(16);
        make.top.equalTo(self.contentView).offset(10);
    }];
    
    [self.chatBubbleImage addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.chatBubbleImage).inset(15);
        make.top.bottom.equalTo(self.chatBubbleImage).inset(10);
    }];
}

- (void)setModel:(MessageItemModel *)model {
    _model = model;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"您好，需要您选择问题类型哦~\n"];
    att.yy_font = UIFontMake(14);
    att.yy_lineSpacing = 5;
    __weak __typeof(self)weakSelf = self;
    for (int i = 0; i < model.chooseOptions.count; i++) {
        NSString *currentContent = [NSString stringWithFormat:@"%@.%@\n",@(i + 1),[model.chooseOptions objectAtIndex:i].BusinessName];
        NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:currentContent];
        att1.yy_font = UIFontMake(13);
        att1.yy_lineSpacing = 5;
        [att1 yy_setTextHighlightRange:NSMakeRange(0, currentContent.length) color:UIColorMakeWithRGBA(33, 99, 170, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            if (weakSelf.chooseBlock) {
                weakSelf.chooseBlock([model.chooseOptions objectAtIndex:i]);
            }
        }];
        [att appendAttributedString:att1];
    }
    self.contentLab.attributedText = att;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
