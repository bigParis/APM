//
//  BPHoldModel.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPHoldModel : NSObject
@property (nonatomic, copy) NSString *holderName;
@property (nonatomic, strong) UIView *holdView;
@end

NS_ASSUME_NONNULL_END
