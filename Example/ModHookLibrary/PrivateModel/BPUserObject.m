//
//  BPUserObject.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/25.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPUserObject.h"
@implementation BPUserObject
- (void)shouldUseModel:(PrivateModel *)model
{
    NSLog(@"shouldUseModel:%@", model.name);
}
@end
