//
//  BPOldTableViewDataSource.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/1/27.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BPDiffableModel;
NS_ASSUME_NONNULL_BEGIN

@interface BPOldTableViewDataSource : NSObject<UITableViewDataSource>
- (instancetype)initWithData:(NSArray<BPDiffableModel *> *)array;
@end

NS_ASSUME_NONNULL_END
