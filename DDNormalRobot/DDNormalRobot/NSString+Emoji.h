//
//  NSString+Emoji.h
//  DDNormalRobot
//
//  Created by dudu on 2020/8/11.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Emoji)
- (NSString *)emojiEncode;
- (NSString *)emojiDecode;
- (BOOL)stringContainsEmoji;
@end

NS_ASSUME_NONNULL_END
