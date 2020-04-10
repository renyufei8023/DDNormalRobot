//
//  DDChatImageCell.m
//  TestSocket
//
//  Created by dudu on 2019/12/25.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "DDChatImageCell.h"
#import "ClientParamsModel.h"
#import "MessageItemModel.h"
#import <QMUIKit.h>
#import <YYCategories.h>
#import <Masonry.h>
#import <QMUIKit.h>
#import <SDWebImage.h>
#import <YBImageBrowser/YBImageBrowser.h>

@interface DDChatImageCell ()
@property(nonatomic, strong) UILabel *nameLab;
@property(nonatomic, strong) UILabel *timeLab;
@property(nonatomic, strong) UIView *topContentView;//时间和昵称的容器
@property(nonatomic, strong) UIImageView *content;
@property(nonatomic, strong) UIView *chatBubbleImage;//气泡

@end
@implementation DDChatImageCell

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

- (UIImageView *)content {
    if (!_content) {
        _content = [UIImageView new];
        _content.contentMode = UIViewContentModeScaleAspectFill;
        _content.clipsToBounds = YES;
        _content.userInteractionEnabled = YES;
    }
    return _content;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
        __weak __typeof(self)weakSelf = self;
        [self.content addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            NSMutableArray *datas = [NSMutableArray array];
            YBIBImageData *data = [YBIBImageData new];
            data.imageURL = [NSURL URLWithString:weakSelf.model.Content];
            [datas addObject:data];
            YBImageBrowser *browser = [YBImageBrowser new];
            browser.defaultToolViewHandler.topView.operationButton.hidden = YES;
            browser.distanceBetweenPages = SCREEN_WIDTH / 2.0;
            browser.dataSourceArray = datas;
            browser.currentPage = 0;
            [browser show];
        }]];
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
    [self.chatBubbleImage addSubview:self.content];
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.chatBubbleImage).inset(8);
        make.top.bottom.equalTo(self.chatBubbleImage).inset(8);
        make.size.mas_offset(CGSizeMake(200, 200));
    }];
}

- (void)setModel:(MessageItemModel *)model {
    _model = model;
    self.nameLab.text = model.SenderName;
    self.timeLab.text = model.CreateTime;
    if ([model.SenderName isEqualToString:[ClientParamsModel getClientParams].CustomerName]) {//自己发的
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
    [self.content sd_setImageWithURL:[NSURL URLWithString:model.Content]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
