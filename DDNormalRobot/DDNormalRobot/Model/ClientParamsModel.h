//
//  ClientParamsModel.h
//  TestSocket
//
//  Created by dudu on 2019/12/11.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClientParamsModel : NSObject <NSSecureCoding>
@property(nonatomic, copy) NSString *CustomerId;
@property(nonatomic, copy) NSString *DialogId;
@property(nonatomic, copy) NSString *CustomerName;
@property(nonatomic, assign) BOOL IsBlack;

+ (instancetype)getClientParams;
+ (void)saveClientParams:(ClientParamsModel *)params;
+ (void)clearClientParams;
@end

NS_ASSUME_NONNULL_END
