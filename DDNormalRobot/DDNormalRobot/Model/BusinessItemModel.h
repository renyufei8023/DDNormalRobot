//
//  BusinessItemModel.h
//  TestSocket
//
//  Created by dudu on 2019/12/24.
//  Copyright © 2019 dudu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BusinessItemModel : NSObject
@property(nonatomic, copy) NSString *BusinessName;
@property(nonatomic, copy) NSString *CreateTime;
@property(nonatomic, copy) NSString *EditTime;
@property(nonatomic, copy) NSString *Id;

@end

NS_ASSUME_NONNULL_END
