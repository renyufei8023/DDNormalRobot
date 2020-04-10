//
//  SmartTipsView.m
//  DuDu-Rent
//
//  Created by dudu on 2020/1/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "SmartTipsView.h"
#import "QMUIKit.h"
#import "Masonry.h"

@interface SmartTipsView () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;

@end
@implementation SmartTipsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWhite;
        self.clipsToBounds = YES;
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.rowHeight = 50;
        _tableView.separatorColor = TableViewSeparatorColor;
        _tableView.layer.cornerRadius = 10;
        _tableView.clipsToBounds = YES;
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [_tableView reloadData];
    [self invalidateIntrinsicContentSize];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[_dataSource[indexPath.row] dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributedString.length)];
    cell.textLabel.attributedText = attributedString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_didSelectBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        _didSelectBlock(cell.textLabel.text);
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
//    self.layer.shadowLayer.hidden = hidden;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.layer setRoundCornerShadowColor:[UIColor.blackColor colorWithAlphaComponent:.5] shadowWidth:5 radius:10 offset:CGSizeMake(0, 1)];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREEN_WIDTH - 40, _dataSource.count * 50);
}

@end
