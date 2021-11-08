//
//  YYUnifiedTaskManager.m
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import "YYUnifiedTaskManager.h"
#import <yymediatorsdk/YYCoresService.h>
#import <yymediatorInterface/IAuthCore.h>
#import <yymediatorInterface/AuthClient.h>
#import <yymediatorInterface/ChannelCoreClient.h>
#import <yymediatorInterface/IChannelCore.h>
#import <yybaseapisdk/YYLogger.h>
#import <YYModel/YYModel.h>
#import "YYWeakTimer.h"
#import "YYUserDefaults.h"
#import "NSDate+Util.h"
static NSString * const kTag = @"YYUnifiedTaskManager";
static NSString * const kYYUnifiedTaskStorageSuffix = @"UnifiedTaskStorage";


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
@property (nonatomic, assign) BOOL needLogin;
@property (nonatomic, assign) int roomLimit;
@property (nonatomic, assign) int todayLimit;
@property (nonatomic, assign) int totalLimit;
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



@implementation YYUnifiedTaskStorageSidItem

@end


@implementation YYUnifiedTaskStorageModel

@end

@interface YYUnifiedTaskManager ()

@property (nonatomic, strong) NSPointerArray *taskArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, YYUnifiedTaskConfig *> *taskConfigMap;
@property (nonatomic, strong) YYUnifiedTaskInfo *currentTaskInfo;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSArray<YYUnifiedTaskStorageModel *> *savedModels;

@end

@implementation YYUnifiedTaskManager

YYSharedInstance_IMPLEMENTATION(YYUnifiedTaskManager);

- (instancetype)init
{
    self = [super init];
    
    [self p_configManager];
    [self p_loadLocalStorage];
    [self p_initTestData];
    [self p_initTimer];
    return self;
}

- (void)p_configManager
{
    AddCoreClient(AuthClient, self);
    AddCoreClient(ChannelCoreClient, self);
}

- (void)p_loadLocalStorage
{
    NSArray *savedData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@", @(12), kYYUnifiedTaskStorageSuffix]];
    NSArray <YYUnifiedTaskStorageModel *> *models = [NSArray yy_modelArrayWithClass:YYUnifiedTaskStorageModel.class json:savedData];
    self.savedModels = models;
    
    [self p_refreshTodayTimes];
}

- (void)p_refreshTodayTimes
{
    if (self.savedModels == nil) {
        return;
    }
    
    BOOL changed = NO;
    for (int i = 0; i < self.savedModels.count; ++i) {
        YYUnifiedTaskStorageModel *model = self.savedModels[i];
        NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:model.item.lastUpdateTime];
        if (![lastDate yy_isToday]) {
            model.item.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
            model.item.todayTimes = 0;
            changed = YES;
        }
    }
    
    if (changed) {
        [self p_updateDatas];
    }
}

- (void)p_updateDatas
{
    NSArray *savedData = [self.savedModels yy_modelToJSONObject];
    [[NSUserDefaults standardUserDefaults] setObject:savedData forKey:[NSString stringWithFormat:@"%@_%@", @(12), kYYUnifiedTaskStorageSuffix]];
}
#pragma mark - AuthClient
- (void)onCurrentAccountChanged:(UserID)newUserId
{
    [self removeTasksWithLoginNeed];
}

#pragma mark - ChannelCoreClient
- (void)onChannelWillChanged:(id<IChannelDetailInfo>)info
{
    [self removeTaskWithChannelNeed];
}

- (void)p_initTestData
{
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (int i = 0; i < 1000; ++i) {
        YYUnifiedTaskConfigItem *item = [[YYUnifiedTaskConfigItem alloc] init];
        item.isManual = i <= 5;
        item.isForce = i % 2;
        item.priorty = i+1;
        item.duration = 10;
        item.stay = 5;
        item.roomLimit = 3;
        item.todayLimit = 50;
        item.totalLimit = 100;
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

- (void)p_initTimer
{
//    self.timer = [NSTimer scheduledTimerToMainQueueWithTimeInterval:1.f target:self selector:@selector(onTimePassedOneSecond) userInfo:nil repeats:YES];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(onTimePassedOneSecond) userInfo:nil repeats:YES];
}

- (void)onTimePassedOneSecond
{
    YYUnifiedTaskInfo *taskInfo = [self findATaskWhenTimePassOneSecond];
    if (taskInfo) {
        [YYLogger info:kTag message:@"find a task:%@ and trigger it", taskInfo.task.taskId];
        [self triggerTask:taskInfo];
    } else {
        NSMutableString *taskChain = [NSMutableString stringWithFormat:@"%@->", self.currentTaskInfo.task.taskId];
        YYUnifiedTaskInfo *next = self.currentTaskInfo.nextTask;
        while (next) {
            NSString *nextString = [NSString stringWithFormat:@"%@->",next.task.taskId];
            [taskChain appendString:nextString];
            next = next.nextTask;
        }
        [YYLogger info:kTag message:@"current task:%@", taskChain];
    }
}

- (void)triggerTask:(YYUnifiedTaskInfo *)taskInfo
{
    [YYLogger info:kTag message:@"triggerTask:%@", taskInfo.task.taskId];
    YYUnifiedTaskConfigItem *itemConfig = taskInfo.itemConfig;
    
    if (self.currentTaskInfo == nil) {
        [YYLogger info:kTag message:@"no task now, show task now"];
        taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
        [taskInfo.task taskDidShow:taskInfo.task.taskId completion:^(BOOL finished) {
            taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
        }];
        self.currentTaskInfo = taskInfo;
        [self addTaskExposureTime:taskInfo.task.taskId];
        [self p_removeTask:self.currentTaskInfo.task.taskId];
        return;
    }
    
    if (self.currentTaskInfo != nil) {
//        1.强制触发状态：
//         1-1当前有弹窗展示时，有强制触发的弹窗触发，则叠加来展示强制触发弹窗
//        如同时触发了多个强制触发弹窗，则仅展示优先级最高的弹窗
//         1-2.非强制触发状态：
//        2当前有弹窗展示时，不展示触发的弹窗，触发的弹窗被丢弃，且不计入触发的次数
        if (!itemConfig.isForce) {
            NSLog(@"has dialog show, discard it");
            // 非强制
            if ([taskInfo.task respondsToSelector:@selector(taskHasDiscarded:reason:completion:)]) {
                taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
                [taskInfo.task taskHasDiscarded:taskInfo.task.taskId reason:YYUnifiedTaskDiscardReasonATaskIsShown completion:nil];
            }
            [self p_removeTask:taskInfo.task.taskId];
        } else {
            // 强制, 需要叠加展示
            self.currentTaskInfo.taskStatus = YYUnifiedTaskStatusExecutingBehind;
            taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
            [taskInfo.task taskDidShow:taskInfo.task.taskId completion:^(BOOL finished) {
                taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
            }];
            [self addTaskExposureTime:taskInfo.task.taskId];
            [self p_removeTask:taskInfo.task.taskId];
            // 链式存储下面的
            YYUnifiedTaskInfo *last = self.currentTaskInfo;
            self.currentTaskInfo = taskInfo;
            self.currentTaskInfo.nextTask = last;
        }
    }
}

- (YYUnifiedTaskInfo *)findATaskWhenTimePassOneSecond
{
    NSMutableArray *tempArray = [@[] mutableCopy];
    [self.taskArray addPointer:NULL];
    [self.taskArray compact];
    for (int i = 0; i < self.taskArray.count; ++i) {
        YYUnifiedTaskInfo *taskInfo = [self.taskArray pointerAtIndex:i];
        if (taskInfo.taskRemainTimeSec > 0) {
            taskInfo.taskRemainTimeSec--;
        }
        
        if (taskInfo.taskRemainTimeSec <= 0) {
            [tempArray addObject:taskInfo];
        }
    }
    
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
    
    YYUnifiedTaskAddFailReason reason = [self p_conditionsSatisfied:itemConfig];
    if (YYUnifiedTaskAddFailReasonNone != reason) {
        [self p_postError:task reason:reason msg:[NSString stringWithFormat:@"config not exist for task:%@", task.taskId]];
        return nil;
    }
    
    if ([self p_hasTaskForTaskId:task.taskId]) {
        if ([task respondsToSelector:@selector(taskAddFailed:)]) {
            [task taskAddFailed:YYUnifiedTaskAddFailReasonTaskNotConfig];
        }
        [YYLogger error:kTag message:@"has a same task:%@ in current list", task.taskId];
    } else {
        // 当前队列里面没有相同id的任务
        YYUnifiedTaskInfo *taskInfo = [[YYUnifiedTaskInfo alloc] initWithTaskInfo:task taskStatus:YYUnifiedTaskStatusAdding];
        taskInfo.taskRemainTimeSec = itemConfig.stay;
        taskInfo.itemConfig = itemConfig;
        [self.taskArray addPointer:(__bridge void * _Nullable)taskInfo];
        [YYLogger info:kTag message:@"addTask:%@", task.taskId];
        taskInfo.taskStatus = YYUnifiedTaskStatusAdded;
    }
    

    return task.taskId;
}

- (void)p_postError:(id<IUnifiedManagementProtocol>)task reason:(YYUnifiedTaskAddFailReason)reason msg:(NSString *)msg
{
    if ([task respondsToSelector:@selector(taskLog:msg:)]) {
        [task taskLog:YYUnifiedTaskLogLevelError msg:msg];
    } else {
        [YYLogger error:kTag message:@"%@", msg];
    }
    if ([task respondsToSelector:@selector(taskAddFailed:)]) {
        [task taskAddFailed:reason];
    }
}

- (BOOL)p_hasTaskForTaskId:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = [self p_taskInfoForTaskId:taskId];
    return taskInfo != nil;
}

- (YYUnifiedTaskInfo *)p_taskInfoForTaskId:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = nil;
    for (int i = 0; i < self.taskArray.count; ++i) {
        taskInfo = [self.taskArray pointerAtIndex:i];
        if (taskInfo.task.taskId && [taskId isEqualToString:taskInfo.task.taskId]) {
            break;
        }
    }
    return taskInfo;
}

- (BOOL)manualFinishTask:(NSString *)taskId
{
    if (![self.currentTaskInfo.task.taskId isEqualToString:taskId]) {
        [YYLogger error:kTag message:@"the task you want finish is not executing now"];
        return NO;
    }
    
    YYUnifiedTaskInfo *taskInfo = [self p_taskInfoForTaskId:taskId];
    if (![self p_configItemForTaskId:taskId taskType:taskInfo.task.taskType].isManual) {
        [YYLogger error:kTag message:@"the task you want finish is not manual task"];
        return NO;
    }
    
    taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
    [taskInfo.task taskShouldDismiss:taskInfo.task.taskId completion:nil];
    taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
    [self p_removeTask:taskId];
    
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
        [YYLogger error:kTag message:@"can not find taskType:%@", @(taskType)];
        return nil;
    }
    YYUnifiedTaskConfig *config = self.taskConfigMap[stringType];
    if (!config) {
        [YYLogger error:kTag message:@"can not find config for taskType:%@", stringType];
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

- (YYUnifiedTaskAddFailReason)p_conditionsSatisfied:(YYUnifiedTaskConfigItem *)itemConfig
{
    // 前置条件判断
    int currentTotal = [self p_loadCurrentTotalShownTimes:itemConfig.taskId];
    if (itemConfig.totalLimit != -1 && currentTotal >= itemConfig.totalLimit) {
        [YYLogger info:kTag message:@"current total shown tiems limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonTotalLimit;
    }

    int currentToday = [self p_loadCurrentTodayShownTimes:itemConfig.taskId];
    if (itemConfig.todayLimit != -1 && currentToday >= itemConfig.todayLimit) {
        [YYLogger info:kTag message:@"current today shown times limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonTodayLimit;
    }
    
    int currentInChannel = [self p_loadCurrentInChannelShownTimes:itemConfig.taskId];
    if (itemConfig.roomLimit != -1 && currentInChannel >= itemConfig.roomLimit) {
        [YYLogger info:kTag message:@"current room shown tiems limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonRoomLimit;
    }
    
//    BOOL isLogined = [YYGetCoreI(IAuthCore) isUserLogined];
    BOOL isLogined = YES;
    if (!isLogined && itemConfig.needLogin) {
        [YYLogger info:kTag message:@"login condition limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonLoginLimit;
    }
    return YYUnifiedTaskAddFailReasonNone;
}


- (int)p_loadCurrentTotalShownTimes:(NSString *)taskId
{
    for (int i = 0; i < self.savedModels.count; ++i) {
        YYUnifiedTaskStorageModel *model = self.savedModels[i];
        if (model.taskId && [taskId isEqualToString:model.taskId]) {
            return model.item.totalTimes;
        }
    }
    return -1;
}

- (int)p_loadCurrentTodayShownTimes:(NSString *)taskId
{
    for (int i = 0; i < self.savedModels.count; ++i) {
        YYUnifiedTaskStorageModel *model = self.savedModels[i];
        if (model.taskId && [taskId isEqualToString:model.taskId]) {
            return model.item.todayTimes;
        }
    }
    return -1;
}

- (int)p_loadCurrentInChannelShownTimes:(NSString *)taskId
{
    for (int i = 0; i < self.savedModels.count; ++i) {
        YYUnifiedTaskStorageModel *model = self.savedModels[i];
        if (model.taskId && [taskId isEqualToString:model.taskId]) {
            return model.item.roomTimes;
        }
    }
    return -1;
}

- (void)addTaskExposureTime:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = [self p_taskInfoForTaskId:taskId];
    BOOL found = NO;
    for (int i = 0; i < self.savedModels.count; ++i) {
        YYUnifiedTaskStorageModel *model = self.savedModels[i];
        if (model.sid.unsignedIntegerValue == 123
            && model.item.todayTimes < taskInfo.itemConfig.todayLimit
            && model.item.totalTimes < taskInfo.itemConfig.totalLimit
            && model.taskId && [model.taskId isEqualToString:taskId]) {
            model.item.todayTimes++;
            model.item.totalTimes++;
            model.item.roomTimes++;
            model.item.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
            found = YES;
//            [YYLogger info:kTag message:@"storage exist add one time"];
            break;
        }
    }
    
    if (!found) {
        [YYLogger info:kTag message:@"storage not exist, create first"];
        NSMutableArray *tempArrar = nil;
        if (self.savedModels == nil) {
            tempArrar = [NSMutableArray array];
        } else {
            tempArrar = [NSMutableArray arrayWithArray:self.savedModels];
        }
         
        YYUnifiedTaskStorageModel *model = [[YYUnifiedTaskStorageModel alloc] init];
        YYUnifiedTaskStorageSidItem *item = [[YYUnifiedTaskStorageSidItem alloc] init];
        item.todayTimes = 1;
        item.totalTimes = 1;
        item.roomTimes = 1;
        item.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
        model.item = item;
        model.sid = @(123);
        model.taskId = taskId;
        [tempArrar addObject:model];
        self.savedModels = tempArrar;
    }
    
    [self p_updateDatas];
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

- (void)p_removeTask:(NSString *)taskId
{
    for (int i = 0; self.taskArray.count; ++i) {
        YYUnifiedTaskInfo *taskInfo = [self.taskArray pointerAtIndex:i];
        if (taskInfo.task.taskId && [taskId isEqualToString:taskInfo.task.taskId]) {
            [self.taskArray removePointerAtIndex:i];
            break;
        }
    }
}

- (void)removeTasks:(NSArray<NSString *> *)taskIds
{
    for (int i = 0; i < taskIds.count; ++i) {
        [self p_removeTask:taskIds[i]];
        [self p_dismissOnTheChain:taskIds[i]];
    }
}

- (void)p_dismissOnTheChain:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = self.currentTaskInfo;
    if (taskInfo.task.taskId && [taskId isEqualToString:taskInfo.task.taskId]) {
        if ([taskInfo.task respondsToSelector:@selector(taskShouldDismiss:completion:)]) {
            [taskInfo.task taskShouldDismiss:taskId completion:nil];
        }
        self.currentTaskInfo = self.currentTaskInfo.nextTask;
        return;
    }

    YYUnifiedTaskInfo *nextTask = taskInfo.nextTask;
    while (nextTask) {
        if (nextTask.task.taskId && [taskId isEqualToString:nextTask.task.taskId]) {
            self.currentTaskInfo.nextTask = nextTask.nextTask;
            break;
        }
        self.currentTaskInfo.nextTask = nextTask;
        nextTask = nextTask.nextTask;
    }
}

- (void)removeTasksWithLoginNeed
{
    for (int i = 0; self.taskArray.count; ++i) {
        YYUnifiedTaskInfo *taskInfo = [self.taskArray pointerAtIndex:i];
        if ([taskInfo.task respondsToSelector:@selector(requireCurrentUser:)] && [taskInfo.task requireCurrentUser:taskInfo.task.taskId]) {
            [self.taskArray removePointerAtIndex:i];
        }
    }
    
    YYUnifiedTaskInfo *next = self.currentTaskInfo.nextTask;
    while (next) {
        if ([next.task respondsToSelector:@selector(requireCurrentUser:)] && [next.task requireCurrentUser:next.task.taskId]) {
            self.currentTaskInfo.nextTask = next.nextTask;
        }
        next = next.nextTask;
    }
}

- (void)removeTaskWithChannelNeed
{
    for (int i = 0; self.taskArray.count; ++i) {
        YYUnifiedTaskInfo *taskInfo = [self.taskArray pointerAtIndex:i];
        if ([taskInfo.task respondsToSelector:@selector(requireCurrentChannel:)] && [taskInfo.task requireCurrentChannel:taskInfo.task.taskId]) {
            [self.taskArray removePointerAtIndex:i];
        }
    }
    
    YYUnifiedTaskInfo *next = self.currentTaskInfo.nextTask;
    while (next) {
        if ([next.task respondsToSelector:@selector(requireCurrentChannel:)] && [next.task requireCurrentChannel:next.task.taskId]) {
            self.currentTaskInfo.nextTask = next.nextTask;
        }
        next = next.nextTask;
    }
}


- (NSPointerArray *)taskArray
{
    if (_taskArray == nil) {
        _taskArray = [NSPointerArray strongObjectsPointerArray];
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
