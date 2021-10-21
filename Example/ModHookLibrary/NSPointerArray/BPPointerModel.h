//
//  BPPointerModel.h
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/21.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBPPointerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BPPointerModel : NSObject<IBPPointerProtocol>
@property (nonatomic, copy) NSString *name;
@end

NS_ASSUME_NONNULL_END
