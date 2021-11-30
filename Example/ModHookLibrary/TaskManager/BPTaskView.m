//
//  BPTaskView.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/29.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPTaskView.h"
#import "YYBubbleTask.h"
#import <YYUnifiedTaskManager.h>

static NSString * const kTaskManagerTag = @"YYUnifiedTaskManager";
static const CGFloat kAnimatedDuration = 0.2;

@implementation BPTaskView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.yellowColor;
    }
    return self;
}

- (void)showInView:(UIView *)showView position:(YYBubblePostionType)position duration:(NSTimeInterval)duration taskId:(NSString *)taskId expectedDelay:(NSInteger)expectedDelay showImmediately:(BOOL)showImmediately
{
    if (!showView) {
        return;
    }
    
    if (taskId == nil || YYBubblePostionTypeNone == position || YYBubblePostionTypeFullScreen == position) {
        [self realShowBubble:duration showView:showView];
    } else {
        YYBubbleTask *task = [[YYBubbleTask alloc] init];
        task.expectedShownDuration = round(duration);
        task.delegate = self;
        task.taskId = taskId;
        task.immediately = showImmediately;
        task.taskExpectedDelay = (int)expectedDelay;
        task.showInView = showView;
        task.preConditionBlock = self.preConditionBlock;
        task.postConditionBlock = self.postConditionBlock;
        
        if (YYBubblePostionTypeTop == position) {
            task.taskShownPosition = YYUnifiedTaskShownPositionTop;
        } else if (YYBubblePostionTypeBottom == position) {
            task.taskShownPosition = YYUnifiedTaskShownPositionBottom;
        }
        
        [self info:kTaskManagerTag message:@"will add task:%@(view:%@) to task manager", taskId, self];
        [[YYUnifiedTaskManager sharedManager] addTask:task completion:^(NSString *taskId) {
            if (taskId != nil) {
                [self info:@"YYBubbleView" message:@"add task success:%@", taskId];
            } else {
                if (self.discardBubbleBlock) {
                    self.discardBubbleBlock();
                    self.discardBubbleBlock = nil;
                }
            }
        }];
    }
}

- (void)realShowBubble:(NSTimeInterval)duration showView:(UIView *)showView
{
    [showView addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:kAnimatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if (duration > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self) {
                        [self _hideAnimated:YES];
                    }
                });
            }
        }
    }];
}

- (void)taskShouldShow:(NSString *)taskId showInview:(UIView *)showInview completion:(void(^)(BOOL finished))completion
{
    [showInview addSubview:self];
    self.alpha = 0;
    [self info:kTaskManagerTag message:@"taskId:%@(%@) will show, %p frame:%@, showInview %@(%p)", taskId, NSStringFromClass(self.class), self, NSStringFromCGRect(self.frame), NSStringFromClass(showInview.class), showInview];
    if (self.willShowBlock) {
        self.willShowBlock();
    }
    [UIView animateWithDuration:kAnimatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self info:kTaskManagerTag message:@"taskId:%@(%@) did show, %p frame:%@, showInview %@(%p)", taskId, NSStringFromClass(self.class), self, NSStringFromCGRect(self.frame), NSStringFromClass(showInview.class), showInview];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)taskShouldDismiss:(NSString *)taskId completion:(void(^)(BOOL finished))completion
{
    [self info:kTaskManagerTag message:@"bubble:%@ dismiss", taskId];
    [self _hideAnimated:YES completion:completion];
}

- (void)taskHasDiscarded:(NSString *)taskId reason:(YYUnifiedTaskDiscardReason)reason completion:(void (^)(BOOL))completion
{
    [self info:kTaskManagerTag message:@"bubble:%@ not shown because:%@", taskId, @(reason)];
    if (self.discardBubbleBlock) {
        self.discardBubbleBlock();
        self.discardBubbleBlock = nil;
    }
    
    if (self.willShowBlock) {
        self.willShowBlock = nil;
    }
    
    if (completion) {
        completion(YES);
    }
}

- (void)hide:(BOOL)animated
{
    [self _hideAnimated:animated];
}

- (void)hide:(BOOL)animated taskId:(NSString *)taskId
{
    if (!self.superview) {
        return;
    }
    
    if (taskId) {
        [[YYUnifiedTaskManager sharedManager] removeTasks:@[taskId]];
    } else {
        [self _hideAnimated:animated];
    }
}

- (void)_hideAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    if (!animated) {
        [self removeAction];
        return;
    }
    
    CGFloat duration = animated ? kAnimatedDuration : 0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeAction];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)_hideAnimated:(BOOL)animated
{
    [self _hideAnimated:animated completion:nil];
}

- (void)removeAction
{
    [self removeFromSuperview];
    if (self.removeFromSuperBlock) {
        self.removeFromSuperBlock();
    }
}

- (void)info:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    NSString *input = [[NSString alloc] initWithFormat:format arguments:args];
#if YYEnv
    [YYLogger info:tag message:@"%@", input];
#else
    NSLog(@"%@", input);
#endif
    va_end(args);
}

- (void)error:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    NSString *input = [[NSString alloc] initWithFormat:format arguments:args];
#if YYEnv
    [YYLogger error:tag message:@"%@", input];
#else
    NSLog(@"%@", input);
#endif
    va_end(args);
}
@end
