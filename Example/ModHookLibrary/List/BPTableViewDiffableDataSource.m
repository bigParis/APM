//
//  BPTableViewDiffableDataSource.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/1/27.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPTableViewDiffableDataSource.h"

@implementation BPTableViewDiffableDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        id item = [self itemIdentifierForIndexPath:indexPath];
        
        NSDiffableDataSourceSnapshot *snapshot = self.snapshot;
        
        [snapshot deleteItemsWithIdentifiers:@[item]];
        
        [self applySnapshot:snapshot animatingDifferences:YES completion:^{
            //
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"UITableViewCellEditingStyleInsert");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%ld", section];
}
@end
