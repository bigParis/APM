//
//  BPTimerMonitor.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/5/12.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPTimerMonitor : NSObject
+ (instancetype)sharedManager;
- (void)enableLog;
- (void)addTimer:(NSTimer *)timer block:(void (^)(NSTimer *timer))block;
- (void)addTimer:(NSTimer *)timer aSelector:(SEL)aSelector;
- (void)removeTimer:(NSTimer *)timer;

@end

NS_ASSUME_NONNULL_END
