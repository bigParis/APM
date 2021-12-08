//
//  BPLeakModelManager.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPLeakModelManager : NSObject
+ (instancetype)sharedManager;
- (void)registerModel:(id)model forKey:(NSString *)aKay;
- (void)unRegisterModel:(NSString *)aKey;
- (id)getModelForKey:(NSString *)aKey;
@end

NS_ASSUME_NONNULL_END
