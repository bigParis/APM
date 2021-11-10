//
//  YYUnifiedTaskManager.h
//  yybaseapisdk
//
//  Created by bigParis on 2021/10/14.
//  Copyright © 2021 YY.inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "IUnifiedManagementProtocol.h"
#ifdef YY
#import "YYSharedInstanceDefine.h"
#endif
NS_ASSUME_NONNULL_BEGIN

@interface YYUnifiedTaskManager : NSObject
#ifdef YY
YYSharedInstance_HEADER(YYUnifiedTaskManager);
#else
+ (instancetype)sharedManager;
#endif
/// 触发气泡、弹窗、蒙层后，先将任务放入队列，并在taskDidShowBlock实现展示逻辑
/// 可不判断是否登录、不用处理延时、不用处理是否新用户【控制中心会统一处理】
/// 需要主线程调用 completion taskId == nil说明添加失败了
- (void)addTask:(id<IUnifiedManagementProtocol>)task completion:(void(^)(NSString *taskId))completion;
/// 删除队列中已有的任务，如果生命周期提前结束，会自动释放
- (void)removeTasks:(NSArray<NSString *> *)taskIds;
/// 用户手动触发关闭，调用这个接口结束任务，并在taskShouldDismissBlock实现关闭逻辑，此任务可不再remove
- (BOOL)manualFinishTask:(NSString *)taskId;
/// 是否可以添加到任务队列
- (BOOL)canAddTask:(id<IUnifiedManagementProtocol>)task;
@end

NS_ASSUME_NONNULL_END
