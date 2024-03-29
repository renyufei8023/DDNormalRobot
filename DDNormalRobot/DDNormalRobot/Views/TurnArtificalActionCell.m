//
//  TurnArtificalActionCell.m
//  TestSocket
//
//  Created by dudu on 2019/12/25.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "TurnArtificalActionCell.h"
#import "QMUIKit.h"
#import "Masonry.h"

@implementation TurnArtificalActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        QMUIButton *artiBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [artiBtn setTitle:@"转人工" forState:UIControlStateNormal];
        artiBtn.titleLabel.font = UIFontMake(13);
        [artiBtn setTitleColor:UIColorMakeWithRGBA(33, 99, 170, 1.0) forState:UIControlStateNormal];
        [artiBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:artiBtn];
        [artiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)btnClick {
    if (self.actionClick) {
        self.actionClick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
