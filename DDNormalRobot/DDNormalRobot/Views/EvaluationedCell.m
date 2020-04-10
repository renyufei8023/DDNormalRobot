//
//  EvaluationCell.m
//  TestSocket
//
//  Created by dudu on 2020/1/3.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "EvaluationedCell.h"
#import "AttributedStringTool.h"
#import "MessageItemModel.h"
#import "QMUIKit.h"
#import "Masonry.h"

@interface EvaluationedCell ()
@property(nonatomic, strong) UILabel *contentLab;

@end
@implementation EvaluationedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _contentLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorMakeWithHex(@"666666")];
        _contentLab.text = @"您已评价：";
        [self.contentView addSubview:_contentLab];
        [_contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setModel:(MessageItemModel *)model {
    _model = model;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[model.AdditionContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *text;
    UIColor *color;
    switch ([data[@"AppraiseReselt"] integerValue]) {
        case 1:
            text = @"好评";
            color = UIColorGreen;
            break;
        case 2:
            text = @"中评";
            color = UIColorMakeWithHex(@"fc790a");
            break;
        case 3:
            text = @"差评";
            color = UIColorMakeWithHex(@"db341e");
            break;
        default:
            break;
    }
    _contentLab.attributedText = [AttributedStringTool attributeWithColor:color range:NSMakeRange(5, text.length) string:[@"您已评价：" stringByAppendingString:text]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
