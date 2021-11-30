//
//  YYUnifiedTaskModel.h
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import <UIKit/UIKit.h>
#import "IYYUnifiedTaskManagerProtocol.h"

@interface YYUnifiedTaskModel : NSObject<IUnifiedManagementProtocol>
- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay;
- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay position:(YYUnifiedTaskShownPosition)position;
- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay position:(YYUnifiedTaskShownPosition)position delegate:(id<IUnifiedManagementDelegate>)delegate;
@end
