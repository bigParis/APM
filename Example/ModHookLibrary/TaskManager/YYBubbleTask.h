//
//  YYBubbleTask.h
//  yybaseapisdk
//
//  Created by zhangqiantong on 2021/11/11.
//

#import <Foundation/Foundation.h>
#import <IYYUnifiedTaskManagerProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYBubbleTask : NSObject <IUnifiedManagementProtocol>

/// 任务(弹窗、气泡、蒙层的id，要在后台配置了才有效，传递未配置id将导致弹窗不会接入规范，还是按照原逻辑自行处理)
@property (nonatomic, copy) NSString *taskId;

/// 处理回调的代理类
@property (nonatomic, weak) id<IUnifiedManagementDelegate> delegate;

/// 提供给控制中心，用来告诉UI显示的位置，目前只用于气泡，上下的气泡是可以同时显示的
@property (nonatomic, assign) YYUnifiedTaskShownPosition taskShownPosition;
/// 预期的显示停留时间，如果服务器配置了时间，会以服务器为准
@property (nonatomic, assign) int expectedShownDuration;
/// 预期多少秒后显示，调用方不要本地计时，而应该在满足其它条件后
/// 调用addTask把任务添加到队列里，当预期的时间达到后，控制中心会根据情况处理
@property (nonatomic, assign) int taskExpectedDelay;
/// 是否需要当前频道有效(切换频道会取消任务)，默认是
@property (nonatomic, assign) BOOL requireCurrentChannel;
/// 是否需要当前账号有效(游客切用户，或者账号间切换失效)，默认是
@property (nonatomic, assign) BOOL requireCurrentUser;
/// 是否立即展示，默认否
@property (nonatomic, assign) BOOL immediately;
/// 要显示的气泡的父view
@property (nonatomic, weak) UIView *showInView;
/// 前置判断，添加任务前校验
@property (nonatomic, copy) YYUnifiedTaskConditionSatisfiedBlcok preConditionBlock;
/// 后置判断，显示前校验
@property (nonatomic, copy) YYUnifiedTaskConditionSatisfiedBlcok postConditionBlock;
@end

NS_ASSUME_NONNULL_END
