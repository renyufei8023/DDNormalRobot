//
//  SmartAlertView.m
//  DuDu-Rent
//
//  Created by dudu on 2020/1/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "SmartAlertView.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "UIView+Shadow.h"

@interface SmartAlertView () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *listView;
@property(atomic, strong) NSMutableArray *attItems;

@end
@implementation SmartAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.clipsToBounds = YES;
        _listView.rowHeight = 50;
        [_listView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _listView.separatorColor = TableViewSeparatorColor;
        _listView.layer.cornerRadius = 10;
        [self addSubview:_listView];
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.layer.cornerRadius = 10;
        self.shadowPosition = ViewShadowPositionAll;
        _attItems = [NSMutableArray array];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataSource {
    _dataArray = dataSource;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tmp = [NSMutableArray array];
        [dataSource enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[obj dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
            [tmp addObject:attributedString];
        }];
        _attItems = tmp;
        dispatch_async(dispatch_get_main_queue(), ^{
            //为了第一次显示出来
            [_listView reloadData];
        });
    });
    [self invalidateIntrinsicContentSize];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _attItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.attributedText = _attItems[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_didSelectCallBack) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        _didSelectCallBack(cell.textLabel.text);
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREEN_WIDTH - 40, _dataArray.count * 50);
}

@end
