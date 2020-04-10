//
//  AttributedStringTool.m
//  FurnitureHelp
//
//  Created by 智剿 on 2018/2/2.
//  Copyright © 2018年 智剿. All rights reserved.
//

#import "AttributedStringTool.h"

@implementation AttributedStringTool

+ (NSMutableAttributedString *)attributeWithColor:(UIColor *)color range:(NSRange)range string:(NSString *)string {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:string];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    return str;
}

+ (NSMutableAttributedString *)attributeWithColor:(UIColor *)color firstRange:(NSRange)range1 secondRange:(NSRange)range2 string:(NSString *)string {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:string];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range1];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range2];
    return str;
}

+ (NSMutableAttributedString *)attributeWithFont:(UIFont *)font andColor:(UIColor *)color range:(NSRange)range string:(NSString *)string {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:string];
    [str addAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color} range:range];
    return str;
}

+ (NSMutableAttributedString *)attributeWithFont:(UIFont *)font range:(NSRange)range string:(NSString *)string {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:string];
    [str addAttribute:NSFontAttributeName value:font range:range];
    return str;
}

+ (NSMutableAttributedString *)attributeCententLine:(NSRange)range string:(NSString *)string {
     NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:string];
    [str addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:range];
    return str;
}
@end
