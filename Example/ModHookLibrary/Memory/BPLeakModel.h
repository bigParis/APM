//
//  BPLeakModel.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPLeakModel : NSObject

- (instancetype)initWithView:(UIView *)view;
@property (nonatomic, copy) dispatch_block_t leakBlock;
@property (nonatomic, copy) NSString *modelName;
- (void)testLeak;
- (NSDictionary *)leakMap;
@end

NS_ASSUME_NONNULL_END
