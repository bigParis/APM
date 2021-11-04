//
//  BPMultiManager.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/26.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMultiManager.h"
#import "BPMutableArray.h"

@interface BPBlockModel : NSObject
@property (nonatomic, copy) dispatch_block_t  block;
@property (nonatomic, assign) int blockCount;
//@property (nonatomic, strong) BPMutableArray *<#name#>;

@end

@implementation BPBlockModel

@end

@interface BPMultiManager()
@property (nonatomic, strong) NSMutableArray *testArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_queue_t dispathWorkQueue;
@property (nonatomic, strong) NSOperationQueue *operationWorkQueue;
@end
@implementation BPMultiManager
+ (instancetype)sharedManager
{
    static BPMultiManager *instance = nil;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[BPMultiManager alloc] init];
        });
    }
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
//        [self initTimer];
    }
    return self;
}

- (void)initTimer
{
//    static int blockCount = 0;
    dispatch_queue_t dispathWorkQueue = dispatch_queue_create("www.testcode.workQueue", DISPATCH_QUEUE_CONCURRENT);
    self.dispathWorkQueue = dispathWorkQueue;
    __block int blockCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispathWorkQueue, ^{
            blockCount++;
            dispatch_block_t blockX = dispatch_block_create(0, ^{
                NSLog(@"block%@ execute at isMainThread:%@", @(blockCount), @([NSThread isMainThread]));
            });
            NSLog(@"add block%@, thread:%@", @(blockCount), [NSThread currentThread]);
            BPBlockModel *model = [[BPBlockModel alloc] init];
            model.block = blockX;
            model.blockCount = blockCount;
            [self.testArray addObject:model];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), blockX);
//            dispatch_async(dispatch_get_main_queue(), blockX);
//            sleep(0.9);
            NSLog(@"remove block%@", @(blockCount));
//            [self.testArray removeObject:blockX];
        });
    }];
//     dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.www", DISPATCH_QUEUE_CONCURRENT);
//
//     dispatch_block_t block1 = dispatch_block_create(0, ^{
//         sleep(5);
//         NSLog(@"block1 %@",[NSThread currentThread]);
//     });
//
//     dispatch_block_t block2 = dispatch_block_create(0, ^{
//         NSLog(@"block2 %@",[NSThread currentThread]);
//     });
//
//     dispatch_block_t block3 = dispatch_block_create(0, ^{
//         NSLog(@"block3 %@",[NSThread currentThread]);
//     });
//
//     dispatch_async(queue, block1);
//     dispatch_async(queue, block2);
//     dispatch_block_cancel(block3);
}

- (void)beginOperationTestCode
{
    NSLog(@"operationTestCode begin, called from isMainThread:%@", @([NSThread isMainThread]));
//    BPMutableArray *testArray = [[BPMutableArray alloc] init];
    BPMutableArray *testArray = [BPMutableArray array];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    self.operationWorkQueue = queue;
    for (int i = 0; i < 200000; ++i) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [queue addOperationWithBlock:^{
            NSLog(@"addObject:%@", number);
            [testArray addObject:number];
        }];
    }
    NSLog(@"operationTestCode end");
}

- (void)endOperationTestCode
{
    NSLog(@"endOperationTestCode begin called from isMainThread:%@", @([NSThread isMainThread]));
    [self.operationWorkQueue cancelAllOperations];
    NSLog(@"endOperationTestCode end");
}


- (void)normalArrayTestCode
{
    NSLog(@"normalArrayTestCode begin");
    NSMutableArray *testArray = [NSMutableArray array];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
    
    for (int i = 0; i < 200; ++i) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [queue addOperationWithBlock:^{
            [testArray addObject:number];
        }];
    }
    
    [queue waitUntilAllOperationsAreFinished];
    
    NSLog(@"%@",@(testArray.count));
    NSLog(@"%@",testArray);
    NSLog(@"normalArrayTestCode end");
}

- (void)endDispathTestCode
{
    NSLog(@"====cancelAll====");
    dispatch_async(self.dispathWorkQueue, ^{
        for (BPBlockModel *blockModel in self.testArray) {
            NSLog(@"cancel block%@", @(blockModel.blockCount));
            dispatch_block_cancel(blockModel.block);
        }
        [self.testArray removeAllObjects];
    });
}

- (void)beginTask
{
//    [self initTimer];
    [self beginOperationTestCode];
}

- (void)cancelAll
{
//    [self endDispathTestCode];
    [self endOperationTestCode];
}

- (NSMutableArray *)testArray
{
    if (_testArray == nil) {
        _testArray = [NSMutableArray array];
    }
    return _testArray;
}

 @end
