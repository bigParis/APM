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
@property (nonatomic, assign) YYUnifiedTaskShownPosition position;
@property (nonatomic, weak) id<IUnifiedManagementDelegate> delegate;

@end
@implementation YYUnifiedTaskModel
- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay position:(YYUnifiedTaskShownPosition)position delegate:(id<IUnifiedManagementDelegate>)delegate {
    if (self = [super init]) {
        _taskId = taskId;
        _taskType = taskType;
        _expectedDuration = expectedDuration;
        _delay = delay;
        _position = position;
        _delegate = delegate;
    }
    return self;
}
- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay {
    return [self initWithTaskId:taskId taskType:taskType expectedDuration:expectedDuration delay:delay position:YYUnifiedTaskShownPositionNone];
}
- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay position:(YYUnifiedTaskShownPosition)position
{
    return [self initWithTaskId:taskId taskType:taskType expectedDuration:expectedDuration delay:delay position:position delegate:nil];
}

- (NSString *)taskId
{
    return _taskId;
}

- (YYUnifiedTaskType)taskType
{
    return _taskType;
}

- (YYUnifiedTaskShownPosition)taskShownPosition
{
    return _position;
}

- (id<IUnifiedManagementDelegate>)delegate
{
    return _delegate;
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
