//
//  RobotDetailModel.h
//  TestSocket
//
//  Created by dudu on 2019/12/31.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RobotDetailModel : NSObject <NSSecureCoding>
@property(nonatomic, copy) NSString *NickName;
@property(nonatomic, copy) NSString *Avatar;
@property(nonatomic, copy) NSString *Motto;
@property(nonatomic, copy) NSString *ServiceType;
@property(nonatomic, copy) NSString *AppType;
+ (instancetype)getRobotDetail;
+ (void)saveRobotDetail:(RobotDetailModel *)params;
+ (void)clearRobotDetail;
@end

NS_ASSUME_NONNULL_END
