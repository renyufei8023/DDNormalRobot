//
//  SmartTipsView.h
//  DuDu-Rent
//
//  Created by dudu on 2020/1/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SmartTipsView : UIView
@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, copy) void(^didSelectBlock)(NSString *content);

@end

NS_ASSUME_NONNULL_END
