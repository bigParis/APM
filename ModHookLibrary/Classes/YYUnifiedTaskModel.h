//
//  YYUnifiedTaskModel.h
//  TestLibrary
//
//  Created by bigParis on 2021/10/14.
//

#import <Foundation/Foundation.h>
#import "IUnifiedManagementProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface YYUnifiedTaskModel : NSObject<IUnifiedManagementProtocol>

- (instancetype)initWithTaskId:(NSString *)taskId taskType:(YYUnifiedTaskType)taskType expectedDuration:(int)expectedDuration delay:(int)delay;
@end

NS_ASSUME_NONNULL_END
