//
//  BPMultiManager.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/26.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPMultiManager : NSObject
+ (instancetype)sharedManager;
- (void)beginTask;
- (void)cancelAll;
@end

NS_ASSUME_NONNULL_END
