//
//  FilterBar.m
//  Filter
//
//  Created by Zsy on 2020/8/8.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import "FilterBar.h"

@interface FilterBarCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLbl;

@end

@implementation FilterBarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubview];
    }
    return self;
}

- (void)buildSubview {
    
    self.titleLbl               = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, cellHeight - 20, cellHeight - 20)];
    self.titleLbl.font          = [UIFont systemFontOfSize:16];
    self.titleLbl.textColor     = [UIColor blackColor];
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    self.titleLbl.layer.cornerRadius  = 15;
    self.titleLbl.layer.masksToBounds = true;
    [self.contentView addSubview:self.titleLbl];
}

- (void)stateNormal:(BOOL)normal {

    self.titleLbl.alpha            = normal ? 0.85 : 1.f;
    self.titleLbl.backgroundColor = normal ? [UIColor cyanColor] : [UIColor whiteColor];
}

@end

@interface FilterBar ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FilterBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = @[].mutableCopy;
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0];
    [collectionViewFlowLayout setMinimumLineSpacing:0];
    
    collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    collectionViewFlowLayout.itemSize = CGSizeMake(cellHeight, cellHeight);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:collectionViewFlowLayout];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate   = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator   = false;
    self.collectionView.showsHorizontalScrollIndicator = false;
    [self.collectionView registerClass:FilterBarCell.class
            forCellWithReuseIdentifier:NSStringFromClass(FilterBarCell.class)];
    [self addSubview:self.collectionView];
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterBarCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(FilterBarCell.class) forIndexPath:indexPath];
    
    cell.titleLbl.text = self.dataSource[indexPath.row];
    [cell stateNormal:self.currentIndex == indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndex = indexPath.row;
    [collectionView reloadData];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    if (self.selectedIndex) {
        self.selectedIndex(self.currentIndex);
    }
}

@end
