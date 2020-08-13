//
//  NSString+Emoji.m
//  DDNormalRobot
//
//  Created by dudu on 2020/8/11.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "NSString+Emoji.h"

@implementation NSString (Emoji)

//编码
- (NSString *)emojiEncode{
    NSString *uniStr = [NSString stringWithUTF8String:[self UTF8String]];
    NSData *uniData = [uniStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *emojiText = [[NSString alloc] initWithData:uniData encoding:NSUTF8StringEncoding];
    return emojiText;
}
 
//解码
- (NSString *)emojiDecode{
    const char *jsonString = [self UTF8String];
    NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
    NSString *emojiText = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
    return emojiText;
}

//判断是否有emoji
- (BOOL)stringContainsEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        const unichar high = [substring characterAtIndex: 0];
        // Surrogate pair (U+1D000-1F9FF)
        if (0xD800 <= high && high <= 0xDBFF) {
            const unichar low = [substring characterAtIndex: 1];
            const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
            if (0x1D000 <= codepoint && codepoint <= 0x1F9FF){
                returnValue = YES;
            }
            // Not surrogate pair (U+2100-27BF)
        } else {
            if (0x2100 <= high && high <= 0x27BF){
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}

@end
