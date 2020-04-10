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

@interface DDInputToolBar : UIView
@property(nonatomic, assign) BOOL showHideGiftBtn;
@property(nonatomic, assign) BOOL showHideEndSessionView;
@property(nonatomic, copy) void(^sendMessageBlock)(NSString *content);
@property(nonatomic, copy) void(^smartTipsBlock)(NSString *content);
@property(nonatomic, copy) void(^sendImageBlock)(NSString *imageUrl);
@property(nonatomic, copy) void(^emotionBlock)(QMUIButton *sender);
@property(nonatomic, copy) void(^evalutionBlock)(void);
@property(nonatomic, copy) void(^newSessionBlock)(void);
- (void)cleatTextView;
- (void)appendEmojText:(NSString *)emojText;
@end

NS_ASSUME_NONNULL_END
