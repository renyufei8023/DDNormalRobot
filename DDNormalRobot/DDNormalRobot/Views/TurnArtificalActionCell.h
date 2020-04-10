//
//  TurnArtificalActionCell.h
//  TestSocket
//
//  Created by dudu on 2019/12/25.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TurnArtificalActionCell : UITableViewCell
@property(nonatomic, copy) void(^actionClick)(void);
@end

NS_ASSUME_NONNULL_END
