//
//  FilterBar.h
//  Filter
//
//  Created by Zsy on 2020/8/8.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FilterBarSelectedIndex)(NSInteger index);

typedef void(^FilterBarTopBtnClickedAtIndex)(NSInteger index);


static CGFloat cellHeight = 100;

@class FilterModel;

@interface FilterBar : UIView

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, copy) FilterBarSelectedIndex selectedIndex;

@property (nonatomic, copy) FilterBarTopBtnClickedAtIndex btnClicked;


@end

NS_ASSUME_NONNULL_END
