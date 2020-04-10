//
//  EmojTextUtil.m
//  DDNormalRobot
//
//  Created by dudu on 2020/4/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "DDHelper.h"
#import "YYText.h"

NSString *const QMUIEmotionString = @"smile;laughing;blush;heart_eyes;smirk;flushed;grin;kissing_smiling_eyes;wink;kissing_closed_eyes;stuck_out_tongue_winking_eye;sleeping;worried;sweat_smile;cold_sweat;joy;sob;angry;mask;scream;sunglasses;thumbsup;clap;ok_hand";

static NSArray<QMUIEmotion *> *QMUIEmotionArray;

@implementation DDHelper

#pragma mark 云阁表情相关处理
+ (NSArray<QMUIEmotion *> *)ddEmotions {
    if (QMUIEmotionArray) {
        return QMUIEmotionArray;
    }
    
    NSMutableArray<QMUIEmotion *> *emotions = [[NSMutableArray alloc] init];
    NSArray<NSString *> *emotionStringArray = [QMUIEmotionString componentsSeparatedByString:@";"];
    for (NSString *emotionString in emotionStringArray) {
        NSString *displayName = [@"[/" stringByAppendingFormat:@"%@]",emotionString];
        QMUIEmotion *emotion = [QMUIEmotion emotionWithIdentifier:emotionString displayName:displayName];
        [emotions addObject:emotion];
    }
    
    QMUIEmotionArray = [NSArray arrayWithArray:emotions];
    [self asyncLoadImages:emotions];
    return QMUIEmotionArray;
}

// 在子线程预加载
+ (void)asyncLoadImages:(NSArray<QMUIEmotion *> *)emotions {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (QMUIEmotion *e in emotions) {
            e.image = UIImageMake(e.identifier);
        }
    });
}

#pragma mark 获取含自定义的图片的字符串
+ (NSMutableAttributedString *)emojTextToAtt:(NSString *)string {
    if (!string) {
        return [NSMutableAttributedString new];
    }
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
    [result addAttributes:@{NSFontAttributeName:UIFontMake(13)} range:NSMakeRange(0, string.length)];
    
    //所有表情数组
    NSArray<QMUIEmotion *> *expressionList = [self ddEmotions];
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

+ (UIImage *)imageWithName:(NSString *)name {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle bundleForClass:self];
        NSString *resourcePath = [mainBundle pathForResource:@"DDResources" ofType:@"bundle"];
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    return image;
}
@end
