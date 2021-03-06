//
//  ChooseQuestionTypeCell.h
//  TestSocket
//
//  Created by dudu on 2019/12/24.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MessageItemModel,BusinessItemModel;
@interface ChooseQuestionTypeCell : UITableViewCell
@property(nonatomic, strong) MessageItemModel *model;
@property(nonatomic, copy) void(^chooseBlock)(BusinessItemModel *businessModel);

@end

NS_ASSUME_NONNULL_END
