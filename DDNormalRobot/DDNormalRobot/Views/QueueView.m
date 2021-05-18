//
//  QueueView.m
//  TestSocket
//
//  Created by dudu on 2020/1/2.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "QueueView.h"
#import "MessageItemModel.h"
#import "QMUIKit.h"
#import "Masonry.h"

@interface QueueView ()
@property(nonatomic, strong) UILabel *countLab;

@end
@implementation QueueView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWhite;
        [self updateUI];
    }
    return self;
}

- (void)updateUI {
    UILabel *topDetail = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorMakeWithHex(@"333333")];
    topDetail.numberOfLines = 0;
    topDetail.text = @"对不起，当前客服全部繁忙，请耐心等侯，当有空闲客服时将第一时间接待您，谢谢！";
    
    [self addSubview:topDetail];
    [topDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(80 + NavigationContentTopConstant);
        make.centerX.equalTo(self);
        make.left.right.equalTo(self).inset(50);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.clipsToBounds = YES;
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor = UIColorMakeWithRGBA(245, 245, 245, 1.0);
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_offset(CGSizeMake(200, 160));
    }];
    UILabel *numberDetail = [[UILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorMakeWithHex(@"#FF5B01")];
    numberDetail.text = @"当前排队人数";
    [contentView addSubview:numberDetail];
    [numberDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(40);
    }];
    
    _countLab = [[UILabel alloc] qmui_initWithFont:UIFontBoldMake(30) textColor:UIColorMakeWithHex(@"#FF5B01")];
    _countLab.text = @"2";
    [contentView addSubview:_countLab];
    [_countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-40);
    }];
}

- (void)setMessageModel:(MessageItemModel *)messageModel {
    _messageModel = messageModel;
    NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:[messageModel.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];;
    _countLab.text = [NSString stringWithFormat:@"%@",datas[@"number"]];
}

@end
