//
//  YYUnifiedTaskModel.m
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import "YYUnifiedTaskModel.h"
#import <UIKit/UIkit.h>

@interface YYUnifiedTaskModel ()
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, assign) YYUnifiedTaskType taskType;
@property (nonatomic, assign) int expectedDuration;
@property (nonatomic, assign) int delay;

@end
@implementation YYUnifiedTaskModel

- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay
{
    if (self = [super init]) {
        _taskId = taskId;
        _taskType = taskType;
        _expectedDuration = expectedDuration;
        _delay = delay;
    }
    return self;
}

- (NSString *)taskId
{
    return _taskId;
}

- (YYUnifiedTaskType)taskType
{
    return YYUnifiedTaskTypePopup;
}

- (void)taskDidShow:(NSString *)taskId completion:(void (^)(BOOL))completion
{
    NSLog(@"%s", __func__);
}

- (void)taskShouldDismiss:(NSString *)taskId completion:(void (^)(BOOL))completion
{
    NSLog(@"%s", __func__);
}

- (int)expectedDuration
{
    return self.expectedDuration;
}

- (int)delay
{
    return self.delay;
}
@end
