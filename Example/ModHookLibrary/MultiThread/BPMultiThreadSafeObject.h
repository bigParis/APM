//
//  BPMultiThreadSafeObject.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPMultiThreadSafeObject : NSObject

@property (nonatomic, strong) NSObject *mtsContainer;

@end

NS_ASSUME_NONNULL_END
