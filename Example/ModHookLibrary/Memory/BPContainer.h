//
//  BPContainer.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/9.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BPLeakModel;

NS_ASSUME_NONNULL_BEGIN

@interface BPContainer : NSObject
- (void)addModel:(BPLeakModel *)model;
- (BPLeakModel *)takeModel;
@end

NS_ASSUME_NONNULL_END
