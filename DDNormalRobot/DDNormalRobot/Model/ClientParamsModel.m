//
//  ClientParamsModel.m
//  TestSocket
//
//  Created by dudu on 2019/12/11.
//  Copyright © 2019 dudu. All rights reserved.
//
#define ClientParamsDatas [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ClientParamsDatas.data"]

#import "ClientParamsModel.h"
#import <objc/runtime.h>

@implementation ClientParamsModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivarList = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivarList[i];
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivarList);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [encoder encodeObject:value forKey:key];
        
    }
    free(ivars);
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

+ (instancetype)getClientParams {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:ClientParamsDatas];
    id exitDatas = [NSKeyedUnarchiver unarchivedObjectOfClass:[self class] fromData:data error:&error];
    return exitDatas;
}

+ (void)saveClientParams:(ClientParamsModel *)params {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:params requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"%s:%d 错误信息=%@", __func__, __LINE__, error);
    }else {
        NSLog(@"%s:%d 保存成功", __func__, __LINE__);
    }
    [data writeToFile:ClientParamsDatas atomically:YES];
}

+ (void)clearClientParams {
    if ([[NSFileManager defaultManager] fileExistsAtPath:ClientParamsDatas]) {
        [[NSFileManager defaultManager] removeItemAtPath:ClientParamsDatas error:nil];
    }
}

@end
