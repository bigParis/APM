//
//  BPOldTableViewDataSource.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/1/27.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPOldTableViewDataSource.h"
#import "BPDiffableModel.h"
@interface BPOldTableViewDataSource()

@property (nonatomic, copy) NSArray *dataArray;
@end

@implementation BPOldTableViewDataSource
- (instancetype)initWithData:(NSArray *)array;
{
    if (self = [super init]) {
        _dataArray = array;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row < self.dataArray.count) {
        BPDiffableModel *model = self.dataArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"名字:%@, 年龄:%@", model.name, @(model.age)];
        return cell;
    }
    
    return [UITableViewCell new];
}
@end
