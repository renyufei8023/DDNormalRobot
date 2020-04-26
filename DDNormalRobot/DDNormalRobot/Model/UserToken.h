//
//  UserToken.h
//  DDNormalRobot
//
//  Created by dudu on 2020/4/26.
//  Copyright © 2020 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserToken : NSObject
@property(nonatomic, copy) NSString *UserToken;

+ (instancetype)getUserToken;
+ (void)saveUserToken:(UserToken *)userToken;
@end

NS_ASSUME_NONNULL_END
