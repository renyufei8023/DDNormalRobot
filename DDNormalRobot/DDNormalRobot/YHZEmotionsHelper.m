//
//  EmojTextUtil.m
//  DDNormalRobot
//
//  Created by dudu on 2020/4/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "YHZEmotionsHelper.h"
#import "YYText.h"
#import "NSString+Emoji.h"

NSString *const YHZEmotionString = @"smile;laughing;blush;heart_eyes;smirk;flushed;grin;kissing_smiling_eyes;wink;kissing_closed_eyes;stuck_out_tongue_winking_eye;sleeping;worried;sweat_smile;cold_sweat;joy;sob;angry;mask;scream;sunglasses;thumbsup;clap;ok_hand";

static NSArray<QMUIEmotion *> *YouHaoZhuEmotionArray;

@implementation YHZEmotionsHelper

#pragma mark 云阁表情相关处理
+ (NSArray<QMUIEmotion *> *)get_all_emotions {
    if (YouHaoZhuEmotionArray) {
        return YouHaoZhuEmotionArray;
    }
    
    NSMutableArray<QMUIEmotion *> *emotions = [NSMutableArray array];
    NSArray<NSString *> *emotionStringArray = [YHZEmotionString componentsSeparatedByString:@";"];
    for (NSString *emotionString in emotionStringArray) {
        NSString *displayName = [@"[/" stringByAppendingFormat:@"%@]",emotionString];
        QMUIEmotion *emotion = [QMUIEmotion emotionWithIdentifier:emotionString displayName:displayName];
        [emotions addObject:emotion];
    }
    
    YouHaoZhuEmotionArray = [NSArray arrayWithArray:emotions];
    [self asyncLoadImages:emotions];
    return YouHaoZhuEmotionArray;
}

// 在子线程预加载
+ (void)asyncLoadImages:(NSArray<QMUIEmotion *> *)emotions {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (QMUIEmotion *emotion in emotions) {
            emotion.image = [YHZEmotionsHelper generateImageFromBundleWithName:emotion.identifier];
        }
    });
}

#pragma mark 获取含自定义的图片的字符串
+ (NSMutableAttributedString *)generateAttributeWithEmojText:(NSString *)string {
    if (!string) {
        return [[NSMutableAttributedString alloc] init];
    }
    string = [self htmlEntityDecode:string];
    string = [self removeHtmlLabelsWithStr:string];
    string = [string emojiDecode].dd_isNotBlank ? [string emojiDecode] : string;
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
    [result addAttributes:@{NSFontAttributeName:UIFontMake(13)} range:NSMakeRange(0, result.string.length)];
 
    //所有表情数组
    NSArray<QMUIEmotion *> *expressionList = [self get_all_emotions];
    int i = 0;
    while (i < expressionList.count) {
        QMUIEmotion *item = expressionList[i];
        NSRange range = [result.string rangeOfString:item.displayName];
        if(range.location == NSNotFound){
            i++;
            continue;
        }
        NSAttributedString *attchString = [NSAttributedString yy_attachmentStringWithEmojiImage:item.image fontSize:16];
        [result replaceCharactersInRange:range withAttributedString:attchString];
    }
    return result;
}

+ (UIImage *)generateImageFromBundleWithName:(NSString *)name {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle bundleForClass:self];
        NSString *resourcePath = [mainBundle pathForResource:@"YHZRobotChat" ofType:@"bundle"];
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    return image;
}

+ (NSString *)htmlEntityDecode:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]; // Do this last so that, e.g. @"&amp;lt;" goes to @"&lt;" not @"<"
    
    return string;
}

+ (NSString *)removeHtmlLabelsWithStr:(NSString *)str {
    NSString *lastStr = str;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSString *text = nil;
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        lastStr = [lastStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return lastStr.dd_isNotBlank ? lastStr : str;
}

@end
