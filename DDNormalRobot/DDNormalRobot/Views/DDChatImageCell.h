//
//  DDChatImageCell.h
//  TestSocket
//
//  Created by dudu on 2019/12/25.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MessageItemModel;
@interface DDChatImageCell : UITableViewCell
@property(nonatomic, strong) MessageItemModel *model;

@end

NS_ASSUME_NONNULL_END
