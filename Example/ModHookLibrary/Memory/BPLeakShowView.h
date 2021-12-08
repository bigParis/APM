//
//  BPLeakShowView.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPLeakShowView : UIView

@property (nonatomic, copy) dispatch_block_t leakBlock;
- (void)testLeak;
@end

NS_ASSUME_NONNULL_END
