//
//  YYUnifiedTaskManager.m
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import "YYUnifiedTaskManager.h"
//#import <yymediatorsdk/YYCoresService.h>
//#import <yymediatorInterface/IAuthCore.h>
//#import <yymediatorInterface/AuthClient.h>
//#import <yymediatorInterface/ChannelCoreClient.h>
//#import <yymediatorInterface/IChannelCore.h>
//#import <yybaseapisdk/YYLogger.h>
#import <YYModel/YYModel.h>
//#import "YYWeakTimer.h"
//#import "YYUserDefaults.h"
#import "NSDate+Util.h"
static NSString * const kTag = @"YYUnifiedTaskManager";
static NSString * const kYYUnifiedTaskStorageSuffix = @"UnifiedTaskStorage";
#define safetyCallblock(block, ...) if((block)) { block(__VA_ARGS__); }

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
@property (nonatomic, strong) YYUnifiedTaskInfo *preTask;
@property (nonatomic, strong) YYUnifiedTaskInfo *nextTask;
@property (nonatomic, strong) YYUnifiedTaskConfigItem *itemConfig;
#ifdef YY
@property (nonatomic, strong) YYWeakTimer *showTimer;
#else
@property (nonatomic, strong) NSTimer *showTimer;
#endif

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

@interface YYUnifiedTaskStorageSidItem : NSObject

@property (nonatomic, assign) int todayTimes;
@property (nonatomic, assign) int totalTimes;
@property (nonatomic, assign) int roomTimes;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@end

@implementation YYUnifiedTaskStorageSidItem

@end

@interface YYUnifiedTaskStorageModel : NSObject

@property (nonatomic, strong) YYUnifiedTaskStorageSidItem *item;
@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, copy) NSString *taskId;

@end


@implementation YYUnifiedTaskStorageModel

@end

@interface YYUnifiedTaskManager ()

@property (nonatomic, strong) NSPointerArray *taskArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, YYUnifiedTaskConfig *> *taskConfigMap;
@property (nonatomic, strong) YYUnifiedTaskInfo *currentDialogTaskInfo;
@property (nonatomic, strong) YYUnifiedTaskInfo *currentBubbleTopTaskInfo;
@property (nonatomic, strong) YYUnifiedTaskInfo *currentBubbleBottomTaskInfo;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *showTimer;
@property (nonatomic, copy) NSArray<YYUnifiedTaskStorageModel *> *savedModels;
@property (nonatomic, strong) NSMutableArray *pendingTasks;

@end

@implementation YYUnifiedTaskManager
#ifdef YY
YYSharedInstance_IMPLEMENTATION(YYUnifiedTaskManager);
#else
+ (instancetype)sharedManager
{
    static YYUnifiedTaskManager *instance = nil;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[YYUnifiedTaskManager alloc] init];
        });
    }
    return instance;
}
#endif

- (instancetype)init
{
    if (self = [super init]) {
        [self p_configManager];
        [self p_loadLocalStorage];
#ifdef DEBUG
        [self p_initTestData];
        [self p_queryConfig];
        [self p_initTimer];
#endif
    }
    return self;
}

- (void)p_configManager
{
#ifdef YY
    AddCoreClient(AuthClient, self);
    AddCoreClient(ChannelCoreClient, self);
#endif
}

- (void)p_loadLocalStorage
{
    NSArray *savedData = nil;
#ifdef YY
    savedData = [YYUserDefaults objectForKey:[NSString stringWithFormat:@"%@_%@", @([YYGetCoreI(IAuthCore) getUserId]), kYYUnifiedTaskStorageSuffix] forModule:YYUserDefaults_UnifiedTask];
#else
    savedData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@", @(123), kYYUnifiedTaskStorageSuffix]];
#endif
    NSArray <YYUnifiedTaskStorageModel *> *models = [NSArray yy_modelArrayWithClass:YYUnifiedTaskStorageModel.class json:savedData];
    self.savedModels = models;
    
    [self p_refreshTodayTimes];
}

- (void)p_refreshTodayTimes
{
    if (nil == self.savedModels) {
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
    if (nil == self.savedModels) {
        return;
    }
    NSArray *savedData = [self.savedModels yy_modelToJSONObject];
#ifdef YY
    [YYUserDefaults setObject:savedData forKey:[NSString stringWithFormat:@"%@_%@", @([YYGetCoreI(IAuthCore) getUserId]), kYYUnifiedTaskStorageSuffix] forModule:YYUserDefaults_UnifiedTask];
#else
    [[NSUserDefaults standardUserDefaults] setObject:savedData forKey:[NSString stringWithFormat:@"%@_%@", @(123), kYYUnifiedTaskStorageSuffix]];
#endif
}

#ifdef YY
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
#endif

- (void)p_initTestData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (int i = 0; i < 100; ++i) {
            YYUnifiedTaskConfigItem *item = [[YYUnifiedTaskConfigItem alloc] init];
            item.isManual = i <= 5;
            item.isForce = (i+1) % 2;
            item.priorty = i+1;
            item.duration = 10;
            item.stay = 5;
            item.roomLimit = 90;
            item.todayLimit = 100;
            item.totalLimit = 1000;
            item.taskId = [NSString stringWithFormat:@"bubble_task%@", @(i+1)];
            [tempArray addObject:item];
        }
        YYUnifiedTaskConfigData *data = [[YYUnifiedTaskConfigData alloc] init];
        data.itemsArray = [tempArray copy];
        
        YYUnifiedTaskConfig *config = [[YYUnifiedTaskConfig alloc] init];
        config.configData = data;
        config.taskType = YYUnifiedTaskTypeBubble;
        config.taskGap = 5000;
        
        self.taskConfigMap[@"bubble"] = config;
        if (self.pendingTasks.count != 0) {
            for (int i = 0; i < self.pendingTasks.count; ++i) {
                dispatch_block_t block = self.pendingTasks[i];
                block();
            }
            [self.pendingTasks removeAllObjects];
        }
    });
}

- (void)p_queryConfig
{
#ifdef YY
    WEAKIFYSELF;
    [[YYHttpClient sharedClient] GET:[self p_taskConfigURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self info:kTag message:@"query config success %@", responseObject];
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        [_weak_self p_processConfigData:responseDict];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [self error:kTag message:@"query config failed %@", error];
    }];
#endif
}

- (void)p_processConfigData:(NSDictionary *)responseDict
{
#ifdef YY
    NSDictionary *data = [responseDict dictionaryForKey:@"data" or:nil];
    NSArray *bubbleArray = [data arrayForKey:@"bubble" or:nil];
    
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (int i = 0; i < bubbleArray.count; ++i) {
        YYUnifiedTaskConfigItem *item = [[YYUnifiedTaskConfigItem alloc] init];
        NSDictionary *dict = bubbleArray[i];
        NSNumber *taskIdNum = [dict numberForKey:@"id" or:@(0)];
        item.taskId = [NSString stringWithFormat:@"%@", taskIdNum];
        item.duration = [[dict numberForKey:@"duration" or:@(0)] intValue];
        [tempArray addObject:item];
    }
    
    YYUnifiedTaskConfigData *dataConfig = [[YYUnifiedTaskConfigData alloc] init];
    dataConfig.itemsArray = [tempArray copy];
    
    YYUnifiedTaskConfig *config = [[YYUnifiedTaskConfig alloc] init];
    config.configData = dataConfig;
    config.taskType = YYUnifiedTaskTypeBubble;
//    config.taskGap = 5000;
    
    self.taskConfigMap[@"bubble"] = config;
#endif
}

- (NSString *)p_taskConfigURL
{
    NSString *serverDomain = [self p_serverDomain];
    return [NSString stringWithFormat:@"%@/material/standard", serverDomain];
}

- (NSString *)p_serverDomain
{
    NSString *serverDomain;
    
#ifdef YY
#if OFFICIAL_RELEASE
    serverDomain = @"https://cfg-material.yy.com";
#else
    if ([[YYModuleEnvironment sharedObject] isTestServer]) {
        serverDomain = @"https://test-cfg-material.yy.com";
    } else {
        serverDomain = @"https://cfg-material.yy.com";
    }
#endif
#else
    serverDomain = @"https://test-cfg-material.yy.com";
#endif
    return serverDomain;
}
- (void)p_initTimer
{
#ifdef YY
    self.timer = [YYWeakTimer scheduledTimerToMainQueueWithTimeInterval:1.f target:self selector:@selector(onTimePassedOneSecond) userInfo:nil repeats:YES];
#endif
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimePassedOneSecond) userInfo:nil repeats:YES];
}

- (void)onTimePassedOneSecond
{
//    [self p_handleDialogTask];
    [self p_handleBubbleTask];
}

- (void)p_handleDialogTask
{
    YYUnifiedTaskInfo *taskInfo = [self findATaskWhenTimePassOneSecond:YYUnifiedTaskTypePopup];
    if (taskInfo) {
        [self info:kTag message:@"find a task:%@ taskType:%@ and trigger it", taskInfo.task.taskId, @(taskInfo.task.taskType)];
        [self triggerTask:taskInfo];
    } else {
        NSMutableString *taskChain = [NSMutableString stringWithFormat:@"%@->", self.currentDialogTaskInfo.task.taskId];
        YYUnifiedTaskInfo *next = self.currentDialogTaskInfo.nextTask;
        while (next) {
            NSString *nextString = [NSString stringWithFormat:@"%@->",next.task.taskId];
            [taskChain appendString:nextString];
            next = next.nextTask;
        }
        [self info:kTag message:@"current task:%@", taskChain];
    }
}

- (void)p_handleBubbleTask
{
    YYUnifiedTaskInfo *taskInfo = [self findATaskWhenTimePassOneSecond:YYUnifiedTaskTypeBubble];
    if (taskInfo) {
        [self info:kTag message:@"find a task:%@ taskType:%@ and trigger it", taskInfo.task.taskId, @(taskInfo.task.taskType)];
        [self triggerTask:taskInfo];
    } else {
        NSString *topTaskId = self.currentBubbleTopTaskInfo.task.taskId;
        NSString *bottomTaskId = self.currentBubbleBottomTaskInfo.task.taskId;
        [self info:kTag message:@"current topTaskId:%@, bottomTaskId:%@", topTaskId, bottomTaskId];
    }
}

- (void)triggerTask:(YYUnifiedTaskInfo *)taskInfo
{
    [self info:kTag message:@"triggerTask:%@, taskType:%@", taskInfo.task.taskId, @(taskInfo.task.taskType)];
    if (YYUnifiedTaskTypePopup == taskInfo.task.taskType) {
        [self p_triggerDialogTask:taskInfo];
    } else if (YYUnifiedTaskTypeBubble == taskInfo.task.taskType) {
        [self p_triggerBubbleTask:taskInfo];
    }
}
- (void)p_triggerDialogTask:(YYUnifiedTaskInfo *)taskInfo
{
    YYUnifiedTaskConfigItem *itemConfig = taskInfo.itemConfig;
    
    if (self.currentDialogTaskInfo == nil) {
        [self info:kTag message:@"no task now, show task now:%@", taskInfo.task.taskId];
        taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
        [taskInfo.task.delegate taskShouldShow:taskInfo.task.taskId completion:^(BOOL finished) {
            taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
        }];
        [self p_startShowTimer:taskInfo];
        self.currentDialogTaskInfo = taskInfo;
        [self p_addTaskExposureTime:taskInfo.task.taskId];
        [self p_removeTask:self.currentDialogTaskInfo.task.taskId];
        return;
    }
    
    if (self.currentDialogTaskInfo != nil) {
//        1.强制触发状态：
//         1-1当前有弹窗展示时，有强制触发的弹窗触发，则叠加来展示强制触发弹窗
//        如同时触发了多个强制触发弹窗，则仅展示优先级最高的弹窗
//         1-2.非强制触发状态：
//        2当前有弹窗展示时，不展示触发的弹窗，触发的弹窗被丢弃，且不计入触发的次数
        if (!itemConfig.isForce) {
            // 非强制
            [self info:kTag message:@"has dialog show, discard it:%@", taskInfo.task.taskId];
            if ([taskInfo.task.delegate respondsToSelector:@selector(taskHasDiscarded:reason:completion:)]) {
                taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
                [taskInfo.task.delegate taskHasDiscarded:taskInfo.task.taskId reason:YYUnifiedTaskDiscardReasonATaskIsShown completion:nil];
            }
            [self p_removeTask:taskInfo.task.taskId];
        } else {
            // 强制, 需要叠加展示
            self.currentDialogTaskInfo.taskStatus = YYUnifiedTaskStatusExecutingBehind;
            taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
            [taskInfo.task.delegate taskShouldShow:taskInfo.task.taskId completion:^(BOOL finished) {
                taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
            }];
            [self p_startShowTimer:taskInfo];
            [self p_addTaskExposureTime:taskInfo.task.taskId];
            [self p_removeTask:taskInfo.task.taskId];
            // 链式存储下面的
            YYUnifiedTaskInfo *last = self.currentDialogTaskInfo;
            self.currentDialogTaskInfo = taskInfo;
            self.currentDialogTaskInfo.nextTask = last;
            last.preTask = self.currentDialogTaskInfo;
        }
    }
}

- (void)p_triggerBubbleTask:(YYUnifiedTaskInfo *)taskInfo
{
    if (YYUnifiedTaskShownPositionTop == taskInfo.task.taskShownPosition) {
        if (self.currentBubbleTopTaskInfo == nil) {
            [self p_showBubbleNow:taskInfo atPosition:YYUnifiedTaskShownPositionTop];
            return;
        }
        if (self.currentBubbleTopTaskInfo != nil) {
            // 当前有气泡显示，直接丢弃
            [self info:kTag message:@"showing bubble %@", self.currentBubbleTopTaskInfo.task.taskId];
            [self p_discardBubble:taskInfo];
        }
    } else if (YYUnifiedTaskShownPositionBottom == taskInfo.task.taskShownPosition) {
        if (self.currentBubbleBottomTaskInfo == nil) {
            [self p_showBubbleNow:taskInfo atPosition:YYUnifiedTaskShownPositionBottom];
            return;
        }
        if (self.currentBubbleTopTaskInfo != nil) {
            // 当前有气泡显示，直接丢弃
            [self info:kTag message:@"showing bubble %@", self.currentBubbleTopTaskInfo.task.taskId];
            [self p_discardBubble:taskInfo];
        }
    }
}

- (void)p_showBubbleNow:(YYUnifiedTaskInfo *)taskInfo atPosition:(YYUnifiedTaskShownPosition)atPosition
{
    [self info:kTag message:@"no task now, show task now:%@ atPosition:%@", taskInfo.task.taskId, @(atPosition)];
    taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
    [taskInfo.task.delegate taskShouldShow:taskInfo.task.taskId completion:^(BOOL finished) {
        taskInfo.taskStatus = YYUnifiedTaskStatusExecuted;
    }];
    
    [self p_startShowTimer:taskInfo];
    if (YYUnifiedTaskShownPositionTop == atPosition) {
        self.currentBubbleTopTaskInfo = taskInfo;
    } else if (YYUnifiedTaskShownPositionBottom == atPosition) {
        self.currentBubbleBottomTaskInfo = taskInfo;
    }
    
//    [self p_addTaskExposureTime:taskInfo.task.taskId];
    if (YYUnifiedTaskShownPositionTop == atPosition) {
        [self p_removeTask:self.currentBubbleTopTaskInfo.task.taskId];
    } else if (YYUnifiedTaskShownPositionBottom == atPosition) {
        [self p_removeTask:self.currentBubbleBottomTaskInfo.task.taskId];
    }
}

- (void)p_discardBubble:(YYUnifiedTaskInfo *)taskInfo
{
    [self info:kTag message:@"has bubble show at same position:%@, discard it:%@", @(taskInfo.task.taskShownPosition), taskInfo.task.taskId];
    if ([taskInfo.task.delegate respondsToSelector:@selector(taskHasDiscarded:reason:completion:)]) {
        taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
        [taskInfo.task.delegate taskHasDiscarded:taskInfo.task.taskId reason:YYUnifiedTaskDiscardReasonATaskIsShown completion:nil];
    }
    [self p_removeTask:taskInfo.task.taskId];
}

- (YYUnifiedTaskInfo *)findATaskWhenTimePassOneSecond:(YYUnifiedTaskType)taskType
{
    NSMutableArray *tempArray = [@[] mutableCopy];
    [self.taskArray addPointer:NULL];
    [self.taskArray compact];
    for (int i = 0; i< self.taskArray.count; ++i) {
        YYUnifiedTaskInfo *taskInfo = [self.taskArray pointerAtIndex:i];
        if (taskInfo.taskRemainTimeSec > 0) {
            taskInfo.taskRemainTimeSec--;
        }
        
        if (taskInfo.taskRemainTimeSec <= 0 && taskType == taskInfo.task.taskType) {
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

- (BOOL)canAddTask:(id<IUnifiedManagementProtocol>)task
{
    if (self.taskArray.count != 0) {
        return NO;
    }
    
    if (YYUnifiedTaskTypeBubble == task.taskType && [task respondsToSelector:@selector(taskShownPosition)]) {
        if (YYUnifiedTaskShownPositionTop == task.taskShownPosition) {
            return self.currentBubbleTopTaskInfo == nil;
        } else if (YYUnifiedTaskShownPositionBottom == task.taskShownPosition) {
            return self.currentBubbleBottomTaskInfo == nil;
        }
    }
    return YES;
}

- (void)addTask:(id<IUnifiedManagementProtocol>)task completion:(void(^)(NSString *taskId))completion;
{
    if (task == nil || task.taskId == nil) {
        [self p_postError:task reason:YYUnifiedTaskAddFailReasonInvaildTask msg:@"task or taskId invaild"];
        safetyCallblock(completion, nil);
        return;
    }
    
    if (![NSThread currentThread].isMainThread) {
        [self p_postError:task reason:YYUnifiedTaskAddFailReasonNotInMainThread msg:[NSString stringWithFormat:@"addTask:%@ not in main thread", task.taskId]];
        safetyCallblock(completion, nil);
        return;
    }
    
    if (_taskConfigMap == nil) {
        dispatch_block_t block = ^{
            [self addTask:task completion:completion];
        };
        [self.pendingTasks addObject:block];
        safetyCallblock(completion, nil);
        return;
    }
    
    YYUnifiedTaskConfigItem *itemConfig = [self p_configItemForTaskId:task.taskId taskType:task.taskType];
        
    if (!itemConfig) {
        [self p_postError:task reason:YYUnifiedTaskAddFailReasonTaskNotConfig msg:[NSString stringWithFormat:@"config not exist for task:%@", task.taskId]];
        safetyCallblock(completion, nil);
        return;
    }
    
    YYUnifiedTaskAddFailReason reason = [self p_conditionsSatisfied:itemConfig];
    if (YYUnifiedTaskAddFailReasonNone != reason) {
        [self p_postError:task reason:reason msg:[NSString stringWithFormat:@"config not exist for task:%@", task.taskId]];
        safetyCallblock(completion, nil);
        return;
    }
    
    if ([self p_hasTaskForTaskId:task.taskId]) {
        if ([task.delegate respondsToSelector:@selector(taskAddFailed:)]) {
            [task.delegate taskAddFailed:YYUnifiedTaskAddFailReasonTaskNotConfig];
        }
        [self error:kTag message:@"has a same task:%@ in current list", task.taskId];
        safetyCallblock(completion, nil);
    } else {
        // 当前队列里面没有相同id的任务
        YYUnifiedTaskInfo *taskInfo = [[YYUnifiedTaskInfo alloc] initWithTaskInfo:task taskStatus:YYUnifiedTaskStatusAdding];
        int taskExpectedDelay = 0;
        if ([task respondsToSelector:@selector(taskExpectedDelay)]) {
            taskExpectedDelay = task.taskExpectedDelay;
        }
        taskInfo.taskRemainTimeSec = itemConfig.stay != 0 ? itemConfig.stay : taskExpectedDelay;
        taskInfo.itemConfig = itemConfig;
        [self.taskArray addPointer:(__bridge void * _Nullable)taskInfo];
        [self info:kTag message:@"addTask:%@", task.taskId];
        taskInfo.taskStatus = YYUnifiedTaskStatusAdded;
        safetyCallblock(completion, task.taskId);
    }
}

- (void)p_postError:(id<IUnifiedManagementProtocol>)task reason:(YYUnifiedTaskAddFailReason)reason msg:(NSString *)msg
{
    if ([task.delegate respondsToSelector:@selector(taskLog:msg:)]) {
        [task.delegate taskLog:YYUnifiedTaskLogLevelError msg:msg];
    } else {
        [self error:kTag message:@"%@", msg];
    }
    if ([task.delegate respondsToSelector:@selector(taskAddFailed:)]) {
        [task.delegate taskAddFailed:reason];
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
        YYUnifiedTaskInfo *tempTaskInfo = [self.taskArray pointerAtIndex:i];
        if (tempTaskInfo.task.taskId && [taskId isEqualToString:tempTaskInfo.task.taskId]) {
            taskInfo = tempTaskInfo;
            break;
        }
    }
    return taskInfo;
}

- (BOOL)manualFinishTask:(NSString *)taskId
{
    if (![self.currentDialogTaskInfo.task.taskId isEqualToString:taskId]) {
        [self error:kTag message:@"the task you want finish is not executing now"];
        return NO;
    }
    
    YYUnifiedTaskInfo *taskInfo = [self p_taskInfoForTaskId:taskId];
    if (![self p_configItemForTaskId:taskId taskType:taskInfo.task.taskType].isManual) {
        [self error:kTag message:@"the task you want finish is not manual task"];
        return NO;
    }
    
    taskInfo.taskStatus = YYUnifiedTaskStatusExecuting;
    [taskInfo.task.delegate taskShouldDismiss:taskInfo.task.taskId completion:nil];
    taskInfo.taskStatus = YYUnifiedTaskStatusFinished;
    [self p_removeTask:taskId];
    
    if (taskInfo.nextTask != nil) {
        taskInfo.nextTask.taskStatus = YYUnifiedTaskStatusExecuted;
        [taskInfo.nextTask.task.delegate taskRefresh:taskInfo.task.taskId completion:nil];
    }
    return YES;
}

- (YYUnifiedTaskConfigItem *)p_configItemForTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType
{
    NSString *stringType = [self _stringForTaskType:taskType];
    if (!stringType) {
        [self error:kTag message:@"can not find taskType:%@", @(taskType)];
        return nil;
    }
    YYUnifiedTaskConfig *config = self.taskConfigMap[stringType];
    if (!config) {
        [self error:kTag message:@"can not find config for taskType:%@", stringType];
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
        [self info:kTag message:@"current total shown tiems limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonTotalLimit;
    }

    int currentToday = [self p_loadCurrentTodayShownTimes:itemConfig.taskId];
    if (itemConfig.todayLimit != -1 && currentToday >= itemConfig.todayLimit) {
        [self info:kTag message:@"current today shown times limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonTodayLimit;
    }
    
    int currentInChannel = [self p_loadCurrentInChannelShownTimes:itemConfig.taskId];
    if (itemConfig.roomLimit != -1 && currentInChannel >= itemConfig.roomLimit) {
        [self info:kTag message:@"current room shown tiems limited for task:%@", itemConfig.taskId];
        return YYUnifiedTaskAddFailReasonRoomLimit;
    }
#ifdef YY
    BOOL isLogined = [YYGetCoreI(IAuthCore) isUserLogined];
#else
    BOOL isLogined = YES;
#endif
    if (!isLogined && itemConfig.needLogin) {
        [self info:kTag message:@"login condition limited for task:%@", itemConfig.taskId];
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

- (void)p_addTaskExposureTime:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = [self p_taskInfoForTaskId:taskId];
    BOOL found = NO;
    for (int i = 0; i < self.savedModels.count; ++i) {
        YYUnifiedTaskStorageModel *model = self.savedModels[i];
        BOOL sidEqual = NO;
#ifdef YY
        sidEqual = model.sid.unsignedIntegerValue == YYGetCoreI(IChannelCore).currentChannelInfo.sid
#endif
        
        if (sidEqual
            && model.item.todayTimes < taskInfo.itemConfig.todayLimit
            && model.item.totalTimes < taskInfo.itemConfig.totalLimit
            && model.taskId && [model.taskId isEqualToString:taskId]) {
            model.item.todayTimes++;
            model.item.totalTimes++;
            model.item.roomTimes++;
            model.item.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
            found = YES;
            [self info:kTag message:@"storage exist add one time"];
            break;
        }
    }
    
    if (!found) {
        [self info:kTag message:@"storage not exist, create first"];
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
#ifdef YY
        model.sid = @(YYGetCoreI(IChannelCore).currentChannelInfo.sid);
#endif
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
        default:
            break;
    }
    return stringType;
}

- (void)p_startShowTimer:(YYUnifiedTaskInfo *)taskInfo
{
    YYUnifiedTaskConfigItem *configItem = [self p_configItemForTaskId:taskInfo.task.taskId taskType:taskInfo.task.taskType];
    int duration = 0;
    if (configItem.duration <= 0) {
        if ([taskInfo.task respondsToSelector:@selector(expectedShownDuration)]) {
            duration = [taskInfo.task expectedShownDuration];
        } else {
            [self error:kTag message:@"both config duration and expectedShownDuration is 0"];
        }
    } else {
        if ([taskInfo.task respondsToSelector:@selector(expectedShownDuration)]) {
            duration = MIN([taskInfo.task expectedShownDuration], configItem.duration);
        } else {
            duration = configItem.duration;
        }
    }
    
    [self info:kTag message:@"startShowTimer:%@ dismiss after %@ seconds", taskInfo.task.taskId, @(duration)];
    
    NSDictionary *userInfo = @{@"taskInfo": taskInfo};
#ifdef YY
    YYWeakTimer *showTimer = [YYWeakTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(onShouldDismissCurrent:) userInfo:userInfo repeats:NO dispatchQueue:dispatch_get_main_queue()];
#else
    NSTimer *showTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(onShouldDismissCurrent:) userInfo:userInfo repeats:NO];
#endif
    taskInfo.showTimer = showTimer;
}

- (void)onShouldDismissCurrent:(NSTimer *)timer
{
    YYUnifiedTaskInfo *taskInfo = [timer.userInfo valueForKey:@"taskInfo"];
    [taskInfo.task.delegate taskShouldDismiss:taskInfo.task.taskId completion:nil];
    if (taskInfo.showTimer) {
        [taskInfo.showTimer invalidate];
        taskInfo.showTimer = nil;
    }
    
    if (YYUnifiedTaskTypePopup == taskInfo.task.taskType) {
        [self p_deleteCurrentDialogNode:taskInfo];
    } else if (YYUnifiedTaskTypeBubble == taskInfo.task.taskType) {
        [self p_deleteCurrentBubbleNode:taskInfo];
    }
}

- (void)p_deleteCurrentDialogNode:(YYUnifiedTaskInfo *)taskInfo
{
    // 删除当前节点
    taskInfo.preTask.nextTask = taskInfo.nextTask;
    taskInfo.nextTask.preTask = taskInfo.preTask;
    if (taskInfo == self.currentDialogTaskInfo) {
        self.currentDialogTaskInfo = self.currentDialogTaskInfo.preTask;
    }
}

- (void)p_deleteCurrentBubbleNode:(YYUnifiedTaskInfo *)taskInfo
{
    if (taskInfo == self.currentBubbleTopTaskInfo) {
        self.currentBubbleTopTaskInfo = nil;
    } else if (taskInfo == self.currentBubbleBottomTaskInfo) {
        self.currentBubbleBottomTaskInfo = nil;
    } else {
        [self error:kTag message:@"task has changed? taskId:%@", taskInfo.task.taskId];
    }
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
        NSString *taskId = taskIds[i];
        [self p_removeTask:taskId];
        YYUnifiedTaskInfo *taskInfo = [self p_taskInfoForTaskId:taskId];
        if (YYUnifiedTaskTypePopup == taskInfo.task.taskType) {
            [self p_dismissOnTheChain:taskIds[i]];
        }
    }
}

- (void)p_dismissOnTheChain:(NSString *)taskId
{
    YYUnifiedTaskInfo *taskInfo = self.currentDialogTaskInfo;
    if (taskInfo.task.taskId && [taskId isEqualToString:taskInfo.task.taskId]) {
        [taskInfo.task.delegate taskShouldDismiss:taskId completion:nil];
        self.currentDialogTaskInfo = self.currentDialogTaskInfo.nextTask;
        return;
    }

    YYUnifiedTaskInfo *nextTask = taskInfo.nextTask;
    while (nextTask) {
        if (nextTask.task.taskId && [taskId isEqualToString:nextTask.task.taskId]) {
            self.currentDialogTaskInfo.nextTask = nextTask.nextTask;
            break;
        }
        self.currentDialogTaskInfo.nextTask = nextTask;
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
    
//    [self p_removeCurrentDialogTaskIfNotCurrent:@selector(requireCurrentUser:)];
    [self p_removeCurrentBubbleTask:@selector(requireCurrentUser:)];
}

- (void)removeTaskWithChannelNeed
{
    for (int i = 0; self.taskArray.count; ++i) {
        YYUnifiedTaskInfo *taskInfo = [self.taskArray pointerAtIndex:i];
        if ([taskInfo.task respondsToSelector:@selector(requireCurrentChannel:)] && [taskInfo.task requireCurrentChannel:taskInfo.task.taskId]) {
            [self.taskArray removePointerAtIndex:i];
        }
    }

//    [self p_removeCurrentDialogTaskIfNotCurrent:@selector(requireCurrentChannel:)];
    [self p_removeCurrentBubbleTask:@selector(requireCurrentChannel:)];
}

- (void)p_removeCurrentDialogTaskIfNotCurrent:(SEL)aSelector
{
    YYUnifiedTaskInfo *next = self.currentDialogTaskInfo.nextTask;
    while (next) {
        if ([next.task respondsToSelector:aSelector]) {
            BOOL need = [next.task performSelector:aSelector withObject:next.task.taskId];
            if (need) {
                self.currentDialogTaskInfo.nextTask = next.nextTask;
                next.nextTask.preTask = next.preTask;
                if (next.task && next.task.taskId) {
                    [next.task.delegate taskShouldDismiss:next.task.taskId completion:nil];
                }
            }
        }
        next = next.nextTask;
    }
    
    // 处理头结点
    if (self.currentDialogTaskInfo.task && self.currentDialogTaskInfo.task.taskId && [self.currentDialogTaskInfo.task respondsToSelector:aSelector]) {
        BOOL need = [self.currentDialogTaskInfo.task performSelector:aSelector withObject:self.currentDialogTaskInfo.task.taskId];
        if (need) {
            [self.currentDialogTaskInfo.task.delegate taskShouldDismiss:self.currentDialogTaskInfo.task.taskId completion:nil];
            self.currentDialogTaskInfo.nextTask.preTask = self.currentDialogTaskInfo.preTask;
            self.currentDialogTaskInfo = self.currentDialogTaskInfo.nextTask;
            self.currentDialogTaskInfo.preTask.nextTask = self.currentDialogTaskInfo;
        }
    }
}

- (void)p_removeCurrentBubbleTask:(SEL)aSelector
{
    [self p_removeCurrentBubbleTaskIfNotCurrent:aSelector forTask:self.currentBubbleTopTaskInfo];
    [self p_removeCurrentBubbleTaskIfNotCurrent:aSelector forTask:self.currentBubbleBottomTaskInfo];
}

- (void)p_removeCurrentBubbleTaskIfNotCurrent:(SEL)aSelector forTask:(YYUnifiedTaskInfo *)taskInfo
{
    if (!taskInfo) {
        [self error:kTag message:@"task info invaild!"];
        return;
    }
    
    if (!taskInfo.task) {
        [self error:kTag message:@"task info has no task"];
        return;
    }
    
    if (!taskInfo.task.taskId) {
        [self error:kTag message:@"task has no task id"];
        return;
    }
    
    if ([taskInfo.task respondsToSelector:aSelector]) {
        BOOL need = [taskInfo.task performSelector:aSelector withObject:taskInfo.task.taskId];
        if (need) {
            [taskInfo.task.delegate taskShouldDismiss:taskInfo.task.taskId completion:nil];
        }
    }
}

- (void)info:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    NSString *input = [[NSString alloc] initWithFormat:format arguments:args];
#ifdef YY
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
#ifdef YY
    [YYLogger error:tag message:@"%@", input];
#else
    NSLog(@"%@", input);
#endif
    va_end(args);
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

- (NSMutableArray *)pendingTasks
{
    if (_pendingTasks == nil) {
        _pendingTasks = [NSMutableArray array];
    }
    return _pendingTasks;
}
@end
