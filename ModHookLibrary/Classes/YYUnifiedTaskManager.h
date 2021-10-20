//
//  YYUnifiedTaskManager.h
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import <Foundation/Foundation.h>
#import "IUnifiedManagementProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYUnifiedTaskManager : NSObject
+ (instancetype)sharedManager;
/// 触发气泡、弹窗、蒙层后，先将任务放入队列，并在taskDidShowBlock实现展示逻辑，需要主线程调用，返回nil表示add失败，会在taskAddFailBlock进行回调
- (NSString *)addTask:(id<IUnifiedManagementProtocol>)task;
/// 删除队列中已有的任务
- (void)removeTasks:(NSArray<NSString *> *)taskIds;
/// 用户手动触发关闭，调用这个接口结束任务，并在taskShouldDismissBlock实现关闭逻辑，此任务可不再remove
- (BOOL)manualFinishTask:(NSString *)taskId;
/// 移除当前展示的任务列表
- (void)removeCurrentTaskList;
@end

NS_ASSUME_NONNULL_END
