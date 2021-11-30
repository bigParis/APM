//
//  YYUnifiedTaskManager.h
//  yybaseapisdk
//
//  Created by bigParis on 2021/10/14.
//  Copyright © 2021 YY.inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "IYYUnifiedTaskManagerProtocol.h"

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
@property (nonatomic, assign) YYUnifiedTaskType taskType;

@end

@interface YYUnifiedTaskStorageSidItem : NSObject

@property (nonatomic, assign) int roomTimes;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@end


@interface YYUnifiedTaskStorageModel : NSObject

@property (nonatomic, strong) NSDictionary<NSNumber *, YYUnifiedTaskStorageSidItem *> *storageSidMap;
@property (nonatomic, assign) int todayTimes;
@property (nonatomic, assign) int totalTimes;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, copy) NSString *taskId;

@end

@interface YYUnifiedTaskManager : NSObject<IYYUnifiedTaskManagerProtocol>

+ (instancetype)sharedManager;

@end
