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
    
}
@end
