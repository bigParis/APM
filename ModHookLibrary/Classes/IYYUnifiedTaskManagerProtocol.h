//
//  IYYUnifiedTaskManagerProtocol.h
//  yybaseservice 实现
//
//  Created by bigParis on 2021/10/14.
//  Copyright © 2021 YY.inc. All rights reserved.

#import <UIKit/UIKit.h>

typedef BOOL(^YYUnifiedTaskConditionSatisfiedBlcok)(NSString *taskId);

typedef NS_ENUM(NSUInteger, YYUnifiedTaskType) {
    YYUnifiedTaskTypeNone,
    YYUnifiedTaskTypePopup,
    YYUnifiedTaskTypeBubble,
};

typedef NS_ENUM(NSUInteger, YYUnifiedTaskAddFailReason) {
    YYUnifiedTaskAddFailReasonNone,
    YYUnifiedTaskAddFailReasonInvaildTask,
    YYUnifiedTaskAddFailReasonNotInMainThread,
    YYUnifiedTaskAddFailReasonPreConditionNotSatisfied,
    YYUnifiedTaskAddFailReasonTaskNotConfig,
    YYUnifiedTaskAddFailReasonSameTask,
    YYUnifiedTaskAddFailReasonTotalLimit,
    YYUnifiedTaskAddFailReasonTodayLimit,
    YYUnifiedTaskAddFailReasonRoomLimit,
    YYUnifiedTaskAddFailReasonLoginLimit,
};

typedef NS_ENUM(NSUInteger, YYUnifiedTaskDiscardReason) {
    YYUnifiedTaskDiscardReasonNone,
    YYUnifiedTaskDiscardReasonFrequencyLimit, 
    YYUnifiedTaskDiscardReasonLoginLimit,
    YYUnifiedTaskDiscardReasonUserLimit,
    YYUnifiedTaskDiscardReasonShowTimeLimit, // 后台会配置展示开始和结束时间，不在时间范围不会显示
    YYUnifiedTaskDiscardReasonATaskIsShown,  // 有任务正在被显示，但此任务非抢占式
    YYUnifiedTaskDiscardReasonPostConditionNotSatisfied,
};

typedef NS_ENUM(NSUInteger, YYUnifiedTaskShownPosition) {
    YYUnifiedTaskShownPositionNone,
    YYUnifiedTaskShownPositionTop,
    YYUnifiedTaskShownPositionBottom,
};

typedef NS_ENUM(NSUInteger, YYUnifiedTaskLogLevel) {
    YYUnifiedTaskLogLevelNone,
    YYUnifiedTaskLogLevelWarning,
    YYUnifiedTaskLogLevelInfo,
    YYUnifiedTaskLogLevelError,
};

@protocol IUnifiedManagementDelegate <NSObject>

@required
/// 通知调用方显示UI，不要在未回调前主动调用代码显示UI
- (void)taskShouldShow:(NSString *)taskId showInview:(UIView *)showInview completion:(void(^)(BOOL finished))completion;
/// 通知调用方隐藏UI，不要在未回调前主动调用代码隐藏UI
- (void)taskShouldDismiss:(NSString *)taskId completion:(void(^)(BOOL finished))completion;

@optional
/// 由于条件限制，任务被丢弃了
- (void)taskHasDiscarded:(NSString *)taskId reason:(YYUnifiedTaskDiscardReason)reason completion:(void(^)(BOOL finished))completion;
/// 由于任务优先级等原因，原来的任务被其它任务覆盖，当覆盖的任务消失后，被覆盖的任务重新出现时候调用
- (void)taskRefresh:(NSString *)taskId completion:(void(^)(BOOL finished))completion;
/// 任务添加失败回调
- (void)taskAddFailed:(YYUnifiedTaskAddFailReason)reason;
/// 打印日志回调
- (void)taskLog:(YYUnifiedTaskLogLevel)level msg:(NSString *)msg;
@end

@protocol IUnifiedManagementProtocol <NSObject>

@required
/// 任务(弹窗、气泡、蒙层的id，要在后台配置了才有效，传递未配置id将导致弹窗不会接入规范，还是按照原逻辑自行处理)
- (NSString *)taskId;
/// 任务类型：目前弹窗和蒙层算一种类型，气泡单独一种类型
- (YYUnifiedTaskType)taskType;
/// 处理回调的代理类
- (id<IUnifiedManagementDelegate>)delegate;
/// 要显示在那个view里
- (UIView *)taskShowInview;
@optional
/// 是否需要立即显示
- (BOOL)needImmediatelyShow;
/// 提供给控制中心，用来告诉UI显示的位置，目前只用于气泡，上下的气泡是可以同时显示的
- (YYUnifiedTaskShownPosition)taskShownPosition;
/// 预期的显示停留时间，如果服务器配置了时间，会以服务器为准
- (int)expectedShownDuration;
/// 预期多少秒后显示，调用方不要本地计时，而应该在满足其它条件后
/// 调用addTask把任务添加到队列里，当预期的时间达到后，控制中心会根据情况处理
- (int)taskExpectedDelay;
/// 是否需要当前频道有效(切换频道会取消任务)
- (BOOL)requireCurrentChannel:(NSString *)taskId;
/// 是否需要当前账号有效(游客切用户，或者账号间切换失效)
- (BOOL)requireCurrentUser:(NSString *)taskId;
/// 业务前置判断条件是否满足
- (YYUnifiedTaskConditionSatisfiedBlcok)preConditionSatisfiedBlock:(NSString *)taskId;
/// 业务后置判断条件是否满足
- (YYUnifiedTaskConditionSatisfiedBlcok)postConditionSatisfiedBlock:(NSString *)taskId;
@end

@protocol IYYUnifiedTaskManagerProtocol <NSObject>
@required
/// 触发气泡、弹窗、蒙层后，先将任务放入队列，并在taskDidShowBlock实现展示逻辑
/// 可不判断是否登录、不用处理延时、不用处理是否新用户【控制中心会统一处理】
/// 需要主线程调用 completion taskId == nil说明添加失败了
- (void)addTask:(id<IUnifiedManagementProtocol>)task completion:(void(^)(NSString *taskId))completion;
/// 删除队列中已有的任务，如果生命周期提前结束，会自动释放
- (void)removeTasks:(NSArray<NSString *> *)taskIds;
/// 用户手动触发关闭，调用这个接口结束任务，并在taskShouldDismissBlock实现关闭逻辑，此任务可不再remove
- (BOOL)manualFinishTask:(NSString *)taskId;
/// 获取当前配置信息列表
- (NSArray *)taskConfigs;
/// 清楚当前配置信息，下次触发将重新拉取
- (void)clearTaskConfigs;
/// 获取当前气泡显示情况
- (NSArray *)currentShownStatus;
@end
