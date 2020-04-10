//
//  EvaluationView.m
//  TestSocket
//
//  Created by dudu on 2019/12/26.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "EvaluationView.h"
#import "QMUIKit.h"
#import "Masonry.h"
#import "DDHelper.h"
#import "YYCategories.h"

@interface EvaluationItemCell : UICollectionViewCell
@property(nonatomic, strong) QMUIButton *evaluationBtn;

@end

@implementation EvaluationItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _evaluationBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _evaluationBtn.imagePosition = QMUIButtonImagePositionTop;
        [_evaluationBtn setTitleColor:UIColorMakeWithHex(@"333333") forState:UIControlStateNormal];
        [_evaluationBtn setTitleColor:UIColorMakeWithHex(@"#FF5B01") forState:UIControlStateSelected];
        _evaluationBtn.titleLabel.font = UIFontMake(14);
        _evaluationBtn.spacingBetweenImageAndTitle = 9;
        _evaluationBtn.userInteractionEnabled = false;
        [self.contentView addSubview:_evaluationBtn];
        [_evaluationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = UIColorMakeWithRGBA(250, 250, 250, 1.0);
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UIColorMakeWithRGBA(240, 240, 240, 1.0).CGColor;
        self.layer.cornerRadius = 3;
    }else {
        self.backgroundColor = UIColorWhite;
        self.layer.borderWidth = 0;
    }
}
@end

@interface EvaluationView () <UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) QMUITextView *textView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *imageNames;

@end
@implementation EvaluationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageNames = @[@"好评",@"中评",@"差评"];
        [self initSubViews];
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    return self;
}

- (void)initSubViews {
    UIView *contentView = [UIView new];
    contentView.backgroundColor = UIColorWhite;
    contentView.layer.cornerRadius = 5;
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_offset(SCREEN_WIDTH - 100);
    }];
    
    UILabel *tipLab = [[UILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorMakeWithHex(@"666666")];
    tipLab.text = @"请对本次服务进行评价";
    [contentView addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(20);
        make.centerX.equalTo(contentView);
    }];
    [tipLab setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    
    __weak __typeof(self)weakSelf = self;
    QMUIButton *closeBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:UIColorMakeWithHex(@"333333")] forState:UIControlStateNormal];
    [contentView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(contentView).inset(16);
    }];
    [closeBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        if (weakSelf.closeBlock) {
            weakSelf.closeBlock();
        }
    }];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(60, 70);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColorWhite;
    [_collectionView registerClass:[EvaluationItemCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [contentView addSubview:_collectionView];
    CGFloat width = 5 * (_imageNames.count + 1) + _imageNames.count * 60;
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLab.mas_bottom).offset(10);
        make.centerX.equalTo(contentView);
        make.height.mas_offset(72);
        make.width.mas_offset(width);
    }];
    
    _textView = [QMUITextView new];
    _textView.placeholder = @"请填写评价内容（选填）";
    _textView.layer.cornerRadius = 5;
    _textView.layer.borderColor = UIColorSeparator.CGColor;
    _textView.layer.borderWidth = 1;
    [contentView addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView).inset(16);
        make.top.equalTo(_collectionView.mas_bottom).offset(10);
        make.height.mas_offset(80);
    }];
    
    QMUIButton *submitBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.layer.cornerRadius = 5;
    submitBtn.clipsToBounds = YES;
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[UIImage imageWithColor:UIColorMakeWithHex(@"#FF5B01")] forState:UIControlStateNormal];
    submitBtn.titleLabel.font = UIFontMake(16);
    [contentView addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_textView);
        make.top.equalTo(_textView.mas_bottom).offset(15);
        make.height.mas_offset(44);
        make.bottom.equalTo(contentView).offset(-20);
    }];
    [submitBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        if (weakSelf.submitBlock) {
            NSIndexPath *selectIndexPath = [weakSelf.collectionView indexPathsForSelectedItems].firstObject;
            weakSelf.submitBlock([NSString stringWithFormat:@"%@",@(selectIndexPath.row + 1)], weakSelf.textView.text);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EvaluationItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell.evaluationBtn setTitle:_imageNames[indexPath.row] forState:UIControlStateNormal];
    [cell.evaluationBtn setImage:[DDHelper imageWithName:_imageNames[indexPath.row]] forState:UIControlStateNormal];
    return cell;
}

@end
