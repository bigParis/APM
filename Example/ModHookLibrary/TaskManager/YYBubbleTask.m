//
//  YYBubbleTask.m
//  yybaseapisdk
//
//  Created by zhangqiantong on 2021/11/11.
//

#import "YYBubbleTask.h"

@implementation YYBubbleTask
- (instancetype)init
{
    if (self = [super init]) {
        self.requireCurrentChannel = YES;
        self.requireCurrentUser = YES;
    }
    return self;
}

/// 任务类型：目前弹窗和蒙层算一种类型，气泡单独一种类型
- (YYUnifiedTaskType)taskType
{
    return YYUnifiedTaskTypeBubble;
}

/// 是否需要当前频道有效(切换频道会取消任务)
- (BOOL)requireCurrentChannel:(NSString *)taskId
{
    return self.requireCurrentChannel;
}
/// 是否需要当前账号有效(游客切用户，或者账号间切换失效)
- (BOOL)requireCurrentUser:(NSString *)taskId
{
    return self.requireCurrentUser;
}

- (BOOL)needImmediatelyShow
{
    return self.immediately;
}

- (UIView *)taskShowInview
{
    return self.showInView;
}

- (YYUnifiedTaskConditionSatisfiedBlcok)preConditionSatisfiedBlock:(NSString *)taskId
{
    return self.preConditionBlock;
}

- (YYUnifiedTaskConditionSatisfiedBlcok)postConditionSatisfiedBlock:(NSString *)taskId
{
    return self.postConditionBlock;
}
@end
