//
//  BPModInitFuncHook.h
//  BPModInitFuncHook
//
//  Created by bigparis on 2020/4/1.
//
// Ref https://developer.apple.com/documentation/xcode/improving_your_app_s_performance/reducing_your_app_s_launch_time

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPModInitFuncHook : NSObject

@property (nonatomic, assign, class) BOOL open;

+ (nullable NSArray <NSDictionary *> *)methodCost;

+ (double)total;

+ (void)clearDatas;

@end

NS_ASSUME_NONNULL_END
