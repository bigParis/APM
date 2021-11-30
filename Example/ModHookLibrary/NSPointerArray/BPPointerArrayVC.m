//
//  BPPointerArrayVC.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/21.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPPointerArrayVC.h"
#import "BPPointArrayMgr.h"
#import "BPPointerModel.h"

@interface BPPointerArrayVC ()
@property (nonatomic, strong) BPPointerModel *m3;
@property (nonatomic, copy) NSString *pointerId;

@end

@implementation BPPointerArrayVC

- (void)dealloc
{
//    [[BPPointArrayMgr sharedManager] removePointer:self.pointerId];
    [[BPPointArrayMgr sharedManager] printPointer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BPPointerModel *m1 = [[BPPointerModel alloc] init];
    m1.name = @"m1";
    BPPointerModel *m2 = [[BPPointerModel alloc] init];
    m2.name = @"m2";
    self.m3 = [[BPPointerModel alloc] init];
    self.m3.name = @"m3";
    
    [[BPPointArrayMgr sharedManager] addPointer:m1];
    [[BPPointArrayMgr sharedManager] addPointer:m2];
    self.pointerId = [[BPPointArrayMgr sharedManager] addPointer:self.m3];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self testCode3];
}

- (void)testCode1
{
    [[BPPointArrayMgr sharedManager] printPointer];
}

- (void)testCode2
{
    BPPointerModel *m4 = [[BPPointerModel alloc] init];
    m4.name = @"m4";
    self.pointerId = [[BPPointArrayMgr sharedManager] addPointer:m4];
}

- (void)testCode3
{
    [[BPPointArrayMgr sharedManager] testCompact];
}

- (void)testCode4
{
    [[BPPointArrayMgr sharedManager] removePointers:[NSArray arrayWithObjects:@"m1", @"m2", @"m3", @"m4", nil]];
}
@end
