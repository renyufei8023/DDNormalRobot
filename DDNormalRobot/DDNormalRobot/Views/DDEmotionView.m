//
//  DDEmotionView.m
//  TestSocket
//
//  Created by dudu on 2019/12/25.
//  Copyright © 2019 dudu. All rights reserved.
//

#import "DDEmotionView.h"
#import <Masonry.h>

@interface DDEmotionItemView : UICollectionViewCell
@property(nonatomic, strong) QMUIButton *itemBtn;
@property(nonatomic, strong) QMUIEmotion *emotion;

@end
@implementation DDEmotionItemView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _itemBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _itemBtn.userInteractionEnabled = false;
        [self.contentView addSubview:_itemBtn];
        [_itemBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setEmotion:(QMUIEmotion *)emotion {
    _emotion = emotion;
    [_itemBtn setImage:emotion.image forState:UIControlStateNormal];
}

@end

@interface DDEmotionView () <UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@end
@implementation DDEmotionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionViewLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 11 * 18) / 10.0, (SCREEN_WIDTH - 11 * 18) / 10.0);
        self.collectionViewLayout.minimumLineSpacing = 18;
        self.collectionViewLayout.minimumInteritemSpacing = 18;
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(18, 18, 18, 18);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.qmui_safeAreaInsets.left, self.qmui_safeAreaInsets.top, CGRectGetWidth(frame) - UIEdgeInsetsGetHorizontalValue(self.qmui_safeAreaInsets), CGRectGetHeight(frame) - UIEdgeInsetsGetVerticalValue(self.qmui_safeAreaInsets)) collectionViewLayout:self.collectionViewLayout];
        self.collectionView.backgroundColor = UIColorClear;
        self.collectionView.scrollsToTop = NO;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[DDEmotionItemView class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:self.collectionView];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setEmotions:(NSArray<QMUIEmotion *> *)emotions {
    _emotions = emotions;
    [self.collectionView reloadData];
    [self invalidateIntrinsicContentSize];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emotions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDEmotionItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.emotion = self.emotions[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectEmotionBlock) {
        _selectEmotionBlock(self.emotions[indexPath.row]);
    }
}

- (CGSize)intrinsicContentSize {
    NSInteger left = 0; // 列数
    NSInteger rows = 0; // 行数
    NSInteger totalNum = self.emotions.count;
    rows = totalNum / 10;
    left = totalNum % 10;
    if (left > 0) {
        rows++;
    }
    CGFloat itemWidth = (SCREEN_WIDTH - 11 * 18) / 10.0;
    CGFloat height = (rows * itemWidth) + 18 * (rows + 1);
    return CGSizeMake(SCREEN_WIDTH, height);
}
@end
