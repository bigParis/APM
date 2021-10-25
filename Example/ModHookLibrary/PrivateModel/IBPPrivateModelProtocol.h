//
//  IBPPrivateModelProtocol.h
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/25.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface PrivateModel : NSObject
@property (nonatomic, copy) NSString *name;
@end

@protocol IBPPrivateModelProtocol <NSObject>

- (void)shouldUseModel:(PrivateModel *)model;
@end

NS_ASSUME_NONNULL_END
