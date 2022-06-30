//
//  BPYYModelTestVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/8.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPYYModelTestVC.h"
#import <YYModel/YYModel.h>
#import "YYUnifiedTaskManager.h"

@interface BPYYModelTestVC ()

@end

@implementation BPYYModelTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < 10; ++i) {
        YYUnifiedTaskStorageSidItem *item = [[YYUnifiedTaskStorageSidItem alloc] init];
        item.todayTimes = 5;
        item.roomTimes = 7;
        item.totalTimes = 9;
        item.lastUpdateTime = NSTimeIntervalSince1970;
        YYUnifiedTaskStorageModel *model = [[YYUnifiedTaskStorageModel alloc] init];
        model.item = item;
        model.sid = @(i);
        [temp addObject:model];
//        dict[sid] = item;
    }
    
//    YYUnifiedTaskStorageModel *uid1 = [[YYUnifiedTaskStorageModel alloc] init];
//    uid1.sid = 12;
//    uid1.sidDict = dict;
//
//    [dict removeAllObjects];
//    for (int i = 0; i < 5; ++i) {
//        YYUnifiedTaskStorageSidItem *item = [[YYUnifiedTaskStorageSidItem alloc] init];
//        item.todayTimes = 3;
//        item.totalTimes = 4;
//        item.lastUpdateTime = NSTimeIntervalSince1970;
//        NSString *sid = [NSString stringWithFormat:@"%@", @(i)];
//        dict[sid] = item;
//    }
//
//    YYUnifiedTaskStorageModel *uid2 = [[YYUnifiedTaskStorageModel alloc] init];
//    uid2.uid = 123;
//    uid2.sidDict = dict;
    
//    NSDictionary *savedData = [uid1 yy_modelToJSONObject];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[NSString stringWithFormat:@"%@", @(12)]];
//    [defaults setObject:savedData forKey:@"12_UnifiedTaskStorage"];
//
//    NSDictionary *writedData = [defaults objectForKey:@"12_UnifiedTaskStorage"];
//    YYUnifiedTaskStorageModel *model = [YYUnifiedTaskStorageModel yy_modelWithJSON:writedData];
//    NSDictionary *tempDict = model.sidDict;
//    YYUnifiedTaskStorageSidItem *item = tempDict[@"3"];
//    NSLog(@"model3.item.lastUpdateTime:%@", @(item.lastUpdateTime));
    NSArray *savedData = [temp yy_modelToJSONObject];
    [defaults setObject:savedData forKey:@"12_UnifiedTaskStorage"];
    
    NSArray *writedData = [defaults objectForKey:@"12_UnifiedTaskStorage"];
    NSArray <YYUnifiedTaskStorageModel *> *models = [NSArray yy_modelArrayWithClass:YYUnifiedTaskStorageModel.class json:writedData];
    NSLog(@"%@", @(models[1].item.lastUpdateTime));
   */
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSString *ip = @"sdasfasdf23easdfasdfadsfdf[dyimg]0dfasdfasdfasdfadsfas asdfasdfasdf s dfadsf asdf asd fasdf 0[/dyimg] sdfasd fasd fas r23e2 efasdf adf asdfasdf adsfadsf asdf adf 2 fdsafadsf ads f";
//
//    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
//    for (int i = 0; i < 100000; ++i) {
//        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@".*\\[dyimg\\].*\\[/dyimg\\].*"
//                                                                          options:NSRegularExpressionCaseInsensitive
//                                                                            error:NULL];
//        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:ip options:0 range:NSMakeRange(0, ip.length)];
//        if (result.count) {
////            NSLog(@"--");
//        }
//    }
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        while(1) {
//            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@".*\\[dyimg\\].*\\[/dyimg\\].*"
//                                                                              options:NSRegularExpressionCaseInsensitive
//                                                                                error:NULL];
//            NSArray<NSTextCheckingResult *> *result = [regex matchesInString:ip options:0 range:NSMakeRange(0, ip.length)];
//            if (result.count) {
//    //            NSLog(@"--");
//            }
//        }
//    });

    
//    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - now;
//    NSLog(@"duration:%@, length:%@", @(duration), @(ip.length));
        NSOperationQueue *operationQueue= [[NSOperationQueue alloc]init];
        if (@available(iOS 13.0, *)) {
            operationQueue.progress.totalUnitCount = 100;
        } else {
            // Fallback on earlier versions
        }
        operationQueue.maxConcurrentOperationCount = 1;
        
        for (int i = 0; i < 50; ++i) {
            NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"低优先级任务:%@", @(i+1));
            }];
            blockOperation1.queuePriority = NSOperationQueuePriorityVeryLow;
            [operationQueue addOperation:blockOperation1];
        }
        [operationQueue addBarrierBlock:^{
            NSLog(@"7:%@ progress:%@", [NSThread currentThread] ,operationQueue.progress);
        }];
        for (int i = 0; i < 50; ++i) {
            NSBlockOperation *blockOperation2=[NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"高优先级任务:%@", @(i+1));
            }];
            blockOperation2.queuePriority = NSOperationQueuePriorityHigh;
            [operationQueue addOperation:blockOperation2];
        }
        
        NSBlockOperation *blockOperation3=[NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"超高优先级任务");
        }];
        blockOperation3.queuePriority = NSOperationQueuePriorityVeryHigh;
        [operationQueue addOperation:blockOperation3];

}
@end
