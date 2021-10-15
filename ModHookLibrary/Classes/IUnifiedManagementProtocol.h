//
//  IUnifiedManagementProtocol.h
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import <Foundation/Foundation.h>

typedef BOOL(^YYUnifiedManagementTaskBlock)(NSString *itemId);

typedef NS_ENUM(NSUInteger, YYUnifiedTaskType) {
    YYUnifiedTaskTypeNone,
    YYUnifiedTaskTypePopup,
    YYUnifiedTaskTypeBubble,
    YYUnifiedTaskTypeMask,
};

typedef NS_ENUM(NSUInteger, YYUnifiedTaskAddFailReason) {
    YYUnifiedTaskAddFailReasonNone,
    YYUnifiedTaskAddFailReasonInvaildTask,
    YYUnifiedTaskAddFailReasonNotInMainThread,
    YYUnifiedTaskAddFailReasonTaskNotConfig,
    YYUnifiedTaskAddFailReasonSameTask,
};

typedef NS_ENUM(NSUInteger, YYUnifiedTaskDiscardReason) {
    YYUnifiedTaskDiscardReasonNone,
    YYUnifiedTaskDiscardReasonFrequencyLimit, 
    YYUnifiedTaskDiscardReasonLoginLimit,
    YYUnifiedTaskDiscardReasonUserLimit,
    YYUnifiedTaskDiscardReasonShowTimeLimit, // 后台会配置展示开始和结束时间，不在时间范围不会显示
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

@protocol IUnifiedManagementProtocol <NSObject>

@required
/// 任务(弹窗、气泡、蒙层的id，要在后台配置了才有效，传递未配置id将导致弹窗不会接入规范，还是按照原逻辑自行处理)
- (NSString *)taskId;
- (YYUnifiedTaskType)taskType;
- (void)taskDidShow:(NSString *)taskId completion:(void(^)(BOOL finished))completion;
- (void)taskShouldDismiss:(NSString *)taskId completion:(void(^)(BOOL finished))completion;
@optional

- (void)taskHasDiscarded:(NSString *)taskId completion:(void(^)(BOOL finished))completion;
- (void)taskRefresh:(NSString *)taskId completion:(void(^)(BOOL finished))completion;
- (YYUnifiedTaskShownPosition)taskShownPosition;
- (void)taskAddFailed:(YYUnifiedTaskAddFailReason)reason;
- (void)taskLog:(YYUnifiedTaskLogLevel)level msg:(NSString *)msg;
- (int)exceptedShownDuration;
- (int)delay;
@end
