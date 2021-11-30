//
//  BPTaskView.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/29.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IYYUnifiedTaskManagerProtocol.h>

typedef NS_ENUM(NSUInteger, YYBubblePostionType) {
    YYBubblePostionTypeNone = 0, ///不需要纳入位置管理的(默认)
    YYBubblePostionTypeBottom = 1, ///位置在下的
    YYBubblePostionTypeTop = 2, ///位置在上的
    YYBubblePostionTypeFullScreen = 3, ///全屏位置的 （如果他显示 别的都不显示）
};

NS_ASSUME_NONNULL_BEGIN

@interface BPTaskView : UIView<IUnifiedManagementDelegate>
- (void)showInView:(UIView *)showView position:(YYBubblePostionType)position duration:(NSTimeInterval)duration taskId:(NSString *)taskId expectedDelay:(NSInteger)expectedDelay showImmediately:(BOOL)showImmediately;
///点击后不会自动消失 需要在clickBlock回调里面手动加上hide
@property (nonatomic, copy) dispatch_block_t clickBlock;

///用来统一处理视图被移除后置为ni的操作
@property (nonatomic, copy) dispatch_block_t removeFromSuperBlock;

/// 气泡被丢弃，需要通知上层，本次操作以失败结束，否则可能存在上层不知道结果一直重试的情况
@property (nonatomic, copy) dispatch_block_t discardBubbleBlock;

/// 气泡即将显示，可以调整布局
@property (nonatomic, copy) dispatch_block_t willShowBlock;

/// 前置判断
@property (nonatomic, copy) YYUnifiedTaskConditionSatisfiedBlcok preConditionBlock;

/// 后置判断
@property (nonatomic, copy) YYUnifiedTaskConditionSatisfiedBlcok postConditionBlock;
@end

NS_ASSUME_NONNULL_END
