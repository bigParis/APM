//
//  BPMutableArray.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMultiThreadSafeObject.h"

@protocol MtsMutableArrayProtocol

@optional
+ (instancetype)array;
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BPMutableArray : BPMultiThreadSafeObject<MtsMutableArrayProtocol>

@end

NS_ASSUME_NONNULL_END
