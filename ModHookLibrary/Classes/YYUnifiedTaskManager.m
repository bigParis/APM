//
//  YYUnifiedTaskManager.m
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import "YYUnifiedTaskManager.h"

typedef NS_ENUM(NSUInteger, YYUnifiedTaskStatus) {
    YYUnifiedTaskStatusNone,
    YYUnifiedTaskStatusAdding,
    YYUnifiedTaskStatusAdded,
    YYUnifiedTaskStatusPending,
    YYUnifiedTaskStatusExecuting,
    YYUnifiedTaskStatusExecuted,
    YYUnifiedTaskStatusExecutingBehind,
    YYUnifiedTaskStatusFinished,
};

@interface YYUnifiedTaskConfigItem : NSObject

@property (nonatomic, assign) BOOL isManual;
@property (nonatomic, assign) BOOL isForce;
@property (nonatomic, assign) int priorty;
@property (nonatomic, assign) int duration; // 展示时长
@property (nonatomic, assign) int stay;
@property (nonatomic, copy) NSString *taskId;

@end

@implementation YYUnifiedTaskConfigItem

@end

@interface YYUnifiedTaskConfigData : NSObject

@property (nonatomic, copy) NSArray<YYUnifiedTaskConfigItem *> *itemsArray;

@end

@implementation YYUnifiedTaskConfigData

@end

@interface YYUnifiedTaskConfig: NSObject

@property (nonatomic, assign) YYUnifiedTaskType taskType;
@property (nonatomic, assign) int taskGap;
@property (nonatomic, strong) YYUnifiedTaskConfigData *configData;

@end

@implementation YYUnifiedTaskConfig

@end

@interface YYUnifiedTaskInfo : NSObject

@property (nonatomic, strong) id<IUnifiedManagementProtocol> task;
@property (nonatomic, assign) YYUnifiedTaskStatus taskStatus;
@property (nonatomic, assign) int taskRemainTimeSec;
@property (nonatomic, strong) YYUnifiedTaskInfo *nextTask;
@property (nonatomic, strong) YYUnifiedTaskConfigItem *itemConfig;
@end

@implementation YYUnifiedTaskInfo

- (instancetype)initWithTaskInfo:(id<IUnifiedManagementProtocol>)task taskStatus:(YYUnifiedTaskStatus)taskStatus
{
    if (self = [super init]) {
        _task = task;
        _taskStatus = taskStatus;
    }
    return self;
}

@end

@interface YYUnifiedTaskManager ()

@property (nonatomic, strong) NSMutableArray<YYUnifiedTaskInfo *> *taskArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, YYUnifiedTaskConfig *> *taskConfigMap;
@property (nonatomic, strong) YYUnifiedTaskInfo *currentTaskInfo;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation YYUnifiedTaskManager

- (instancetype)init
{
    self = [super init];
    
    [self regsiterEntProtocol];
    [self initTestData];
    [self initTestTimer];
    return self;
}

- (void)regsiterEntProtocol
{
    
}

- (void)initTestData
{
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (int i = 0; i < 10; ++i) {
        YYUnifiedTaskConfigItem *item = [[YYUnifiedTaskConfigItem alloc] init];
        item.isManual = i <= 5;
        item.isForce = i % 2;
        item.priorty = i+1;
        item.duration = 10;
        item.stay = 5;
        item.taskId = [NSString stringWithFormat:@"popup_task%@", @(i+1)];
        [tempArray addObject:item];
    }
    YYUnifiedTaskConfigData *data = [[YYUnifiedTaskConfigData alloc] init];
    data.itemsArray = [tempArray copy];
    
    YYUnifiedTaskConfig *config = [[YYUnifiedTaskConfig alloc] init];
    config.configData = data;
    config.taskType = YYUnifiedTaskTypePopup;
    config.taskGap = 5000;
    
    self.taskConfigMap[@"popup"] = config;
}

- (void)initTestTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        YYUnifiedTaskInfo *taskInfo = [self findATaskWhenTimePassOneSecond];
        if (taskInfo) {
            [self triggerTask:taskInfo];
        }
    }];
}

- (void)triggerTask:(YYUnifiedTaskInfo *)taskInfo
{
    YYUnifiedTaskConfigItem *itemConfig = taskInfo.itemConfig;
    
    if (self.currentTaskInfo == nil) {
        taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
        [taskInfo.task taskDidShow:taskInfo.task.taskId completion:^(BOOL finished) {
            taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
        }];
        self.currentTaskInfo = taskInfo;
        [self.taskArray removeObject:self.currentTaskInfo];
        return;
    }
    
    if (self.currentTaskInfo != nil) {
//        1.强制触发状态：
//         1-1当前有弹窗展示时，有强制触发的弹窗触发，则叠加来展示强制触发弹窗
//        如同时触发了多个强制触发弹窗，则仅展示优先级最高的弹窗
//         1-2.非强制触发状态：
//        2当前有弹窗展示时，不展示触发的弹窗，触发的弹窗被丢弃，且不计入触发的次数
        if (!itemConfig.isForce) {
            // 非强制
            if ([taskInfo.task respondsToSelector:@selector(taskHasDiscarded:completion:)]) {
                taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
                [taskInfo.task taskHasDiscarded:taskInfo.task.taskId completion:nil];
            }
            [self.taskArray removeObject:taskInfo];
        } else {
            // 强制
            YYUnifiedTaskConfigItem *itemConfig = [self p_configItemForTaskId:self.currentTaskInfo.task.taskId taskType:self.currentTaskInfo.task.taskType];
            
            if (itemConfig.isForce) {
                // 当前的也是强制的，需要干掉当前的，展示后来的
                self.currentTaskInfo.taskStatus = YYUnifiedTaskStatusFinished;
                [self.currentTaskInfo.task taskShouldDismiss:self.currentTaskInfo.task.taskId completion:nil];
                [self.taskArray removeObject:self.currentTaskInfo];
                taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
                [taskInfo.task taskDidShow:taskInfo.task.taskId completion:^(BOOL finished) {
                    taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
                }];
                self.currentTaskInfo = taskInfo;
                
            } else {
                // 当前的不是强制的，需要叠加展示
                self.currentTaskInfo.taskStatus = YYUnifiedTaskStatusExecutingBehind;
                taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
                [taskInfo.task taskDidShow:taskInfo.task.taskId completion:nil];
                self.currentTaskInfo.nextTask = self.currentTaskInfo;
                self.currentTaskInfo = taskInfo; // 链式存储下面的
            }
        }
    }
}

- (YYUnifiedTaskInfo *)findATaskWhenTimePassOneSecond
{
    NSMutableArray *tempArray = [@[] mutableCopy];
    [self.taskArray enumerateObjectsUsingBlock:^(YYUnifiedTaskInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.taskRemainTimeSec--;
        if (obj.taskRemainTimeSec <= 0) {
            [tempArray addObject:obj];
        }
    }];
    
    if (tempArray.count == 0) {
        return nil;
    }
    
    if (tempArray.count == 1) {
        return tempArray.firstObject;
    }
    
    // 找到满足条件的优先级最高的弹窗
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"itemConfig.priorty" ascending:NO];
    [tempArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    return tempArray.firstObject;
}

- (NSString *)addTask:(id<IUnifiedManagementProtocol>)task
{
    if (task == nil || task.taskId == nil) {
        [self p_postError:task reason:YYUnifiedTaskAddFailReasonInvaildTask msg:@"task or taskId invaild"];
        return nil;
    }
    
    if (![NSThread currentThread].isMainThread) {
        [self p_postError:task reason:YYUnifiedTaskAddFailReasonNotInMainThread msg:[NSString stringWithFormat:@"addTask:%@ not in main thread", task.taskId]];
        return nil;
    }
    
    YYUnifiedTaskConfigItem *itemConfig = [self p_configItemForTaskId:task.taskId taskType:task.taskType];
    if (!itemConfig) {
        [self p_postError:task reason:YYUnifiedTaskAddFailReasonTaskNotConfig msg:[NSString stringWithFormat:@"config not exist for task:%@", task.taskId]];
        return nil;
    }
    
    if ([self p_hasTaskForTaskId:task.taskId]) {
        if ([task respondsToSelector:@selector(taskAddFailed:)]) {
            [task taskAddFailed:YYUnifiedTaskAddFailReasonTaskNotConfig];
        }
        NSLog(@"has a same task:%@ in current list", task.taskId);
    } else {
        // 当前队列里面没有相同id的任务
        YYUnifiedTaskInfo *taskInfo = [[YYUnifiedTaskInfo alloc] initWithTaskInfo:task taskStatus:YYUnifiedTaskStatusAdding];
        taskInfo.taskRemainTimeSec = itemConfig.stay;
        taskInfo.itemConfig = itemConfig;
        [self.taskArray addObject:taskInfo];
        taskInfo.taskStatus = YYUnifiedTaskStatusAdded;
    }
    

    return task.taskId;
}

- (void)p_postError:(id<IUnifiedManagementProtocol>)task reason:(YYUnifiedTaskAddFailReason)reason msg:(NSString *)msg
{
    if ([task respondsToSelector:@selector(taskLog:msg:)]) {
        [task taskLog:YYUnifiedTaskLogLevelError msg:msg];
    }
    if ([task respondsToSelector:@selector(taskAddFailed:)]) {
        [task taskAddFailed:reason];
    }
}

- (BOOL)p_hasTaskForTaskId:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = [self _taskInfoForTaskId:taskId];
    return taskInfo != nil;
}

- (YYUnifiedTaskInfo *)_taskInfoForTaskId:(NSString *)taskId
{
    __block YYUnifiedTaskInfo *taskInfo = nil;
    [self.taskArray enumerateObjectsUsingBlock:^(YYUnifiedTaskInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.task.taskId isEqualToString:taskId]) {
            taskInfo = obj;
            *stop = YES;
        }
    }];
    return taskInfo;
}

- (BOOL)manualFinishTask:(NSString *)taskId
{
    if (![self.currentTaskInfo.task.taskId isEqualToString:taskId]) {
        NSLog(@"the task you want finish is not executing now");
        return NO;
    }
    
//    if (![self _configItemForTaskId:taskId].isManual) {
//        NSLog(@"the task you want finish is not manual task");
//        return NO;
//    }
    
    YYUnifiedTaskInfo *taskInfo = [self _taskInfoForTaskId:taskId];
    taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
    [taskInfo.task taskShouldDismiss:taskInfo.task.taskId completion:nil];
    taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
    [self.taskArray removeObject:taskInfo];
    
    if (taskInfo.nextTask != nil) {
        taskInfo.nextTask.taskStatus = YYUnifiedTaskStatusExecuted;
        [taskInfo.nextTask.task taskRefresh:taskInfo.task.taskId completion:nil];
    }
    return YES;
}

- (YYUnifiedTaskConfigItem *)p_configItemForTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType
{
    NSString *stringType = [self _stringForTaskType:taskType];
    if (!stringType) {
        NSLog(@"can not find taskType:%@", @(taskType));
        return nil;
    }
    YYUnifiedTaskConfig *config = self.taskConfigMap[stringType];
    if (!config) {
        NSLog(@"can not find config for taskType:%@", stringType);
        return nil;
    }
    
    __block YYUnifiedTaskConfigItem *item = nil;
    [config.configData.itemsArray enumerateObjectsUsingBlock:^(YYUnifiedTaskConfigItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.taskId isEqualToString:taskId]) {
            item = obj;
            *stop = YES;
        }
    }];
    return item;
}

- (NSString *)_stringForTaskType:(YYUnifiedTaskType)taskType
{
    NSString *stringType = nil;
    switch (taskType) {
        case YYUnifiedTaskTypePopup:
            stringType = @"popup";
            break;
        case YYUnifiedTaskTypeBubble:
            stringType = @"bubble";
            break;
        case YYUnifiedTaskTypeMask:
            stringType = @"mask";
            break;
        default:
            break;
    }
    return stringType;
}

- (void)removeTasks:(NSString *)taskIds
{
    NSMutableArray *arrayToRemove = [@[] mutableCopy];
    [self.taskArray enumerateObjectsUsingBlock:^(YYUnifiedTaskInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([taskIds containsString:obj.task.taskId]) {
            [arrayToRemove addObject:obj];
            *stop = YES;
        }
    }];
    [self.taskArray removeObjectsInArray:arrayToRemove];
}

- (NSMutableArray<YYUnifiedTaskInfo *> *)taskArray
{
    if (_taskArray == nil) {
        _taskArray = [NSMutableArray array];
    }
    return _taskArray;
}

- (NSMutableDictionary<NSString *,YYUnifiedTaskConfig *> *)taskConfigMap
{
    if (_taskConfigMap == nil) {
        _taskConfigMap = [NSMutableDictionary dictionary];
    }
    return _taskConfigMap;
}
@end
