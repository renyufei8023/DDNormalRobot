//
//  SmartAlertView.h
//  DuDu-Rent
//
//  Created by dudu on 2020/1/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SmartAlertView : UIView
@property(nonatomic, strong) NSArray *dataArray;
@property(nonatomic, copy) void(^didSelectCallBack)(NSString *content);

@end

NS_ASSUME_NONNULL_END
