//
//  BPPrivateModelVC.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/25.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPPrivateModelVC.h"
#import "BPUserObject.h"

/// BPUserObject 是调用方，需要实现IBPPrivateModelProtocol协议中shouldUseModel接口，并接受回传的数据PrivateModel
/// PrivateModel的持有者是BPPrivateModelVC，所以BPPrivateModelVC在BPPrivateModelVC文件中实现（implementation）
/// 但定义在IBPPrivateModelProtocol协议中，这样外部拿到IBPPrivateModelProtocol，就可以进行开发了。

@interface BPPrivateModelVC ()
@end

@implementation PrivateModel

@end

@implementation BPPrivateModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    id<IBPPrivateModelProtocol> obj = [[BPUserObject alloc] init];
    PrivateModel *model = [[PrivateModel alloc] init];
    model.name = @"test data";
    [obj shouldUseModel:model];
}
@end
