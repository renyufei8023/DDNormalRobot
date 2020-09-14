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
#import "UIView+Shadow.h"

@interface SmartTipsView () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;

@end
@implementation SmartTipsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWhite;
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
        self.shadowPosition = ViewShadowPositionAll;
        self.layer.cornerRadius = 10;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[_dataSource[indexPath.row] dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.textLabel.attributedText = attributedString;
        });
    });

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_didSelectBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        _didSelectBlock(cell.textLabel.text);
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREEN_WIDTH - 40, _dataSource.count * 50);
}

@end
