//
//  DDInputView.h
//  TestSocket
//
//  Created by dudu on 2019/12/23.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface RobotChatInputToolBar : UIView
@property(nonatomic, assign) BOOL hideGiftBtn;
@property(nonatomic, assign) BOOL hideEndSessionView;
@property(nonatomic, assign) BOOL hideEndSessionBtn;
@property(nonatomic, copy) void(^sendMessageCallBack)(NSString *content);
@property(nonatomic, copy) void(^smartTipsCallBack)(NSString *content);
@property(nonatomic, copy) void(^sendImageCallBack)(NSString *imageUrl);
@property(nonatomic, copy) void(^emotionCallBack)(QMUIButton *sender);
@property(nonatomic, copy) void(^evalutionCallBack)(void);
@property(nonatomic, copy) void(^newSessionCallBack)(void);
@property(nonatomic, copy) void(^endSessionCallBack)(void);
- (void)cleatInputView;
- (void)yhz_appendEmojText:(NSString *)emojText;
@end

NS_ASSUME_NONNULL_END
