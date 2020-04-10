//
//  AttributedStringTool.h
//  FurnitureHelp
//
//  Created by 智剿 on 2018/2/2.
//  Copyright © 2018年 智剿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AttributedStringTool : NSObject
+ (NSMutableAttributedString *)attributeWithColor:(UIColor *)color range:(NSRange)range string:(NSString *)string;
+ (NSMutableAttributedString *)attributeWithColor:(UIColor *)color firstRange:(NSRange)range1 secondRange:(NSRange)range2 string:(NSString *)string;
+ (NSMutableAttributedString *)attributeWithFont:(UIFont *)font andColor:(UIColor *)color range:(NSRange)range string:(NSString *)string;
+ (NSMutableAttributedString *)attributeWithFont:(UIFont *)font range:(NSRange)range string:(NSString *)string;
+ (NSMutableAttributedString *)attributeCententLine:(NSRange)range string:(NSString *)string;
@end
