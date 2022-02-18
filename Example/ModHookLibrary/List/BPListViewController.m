//
//  BPListViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/1/27.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPListViewController.h"
#import "BPTableViewDiffableDataSource.h"
#import "BPOldTableViewDataSource.h"
#import "BPDiffableModel.h"

typedef NS_ENUM(NSUInteger, MyType) {
    MyTypeNone = 0,
    MyTypeTest1 = (1<<0),
    MyTypeTest2 = (1<<1),
    MyTypeTest3 = (1<<2),
};
@interface BPListViewController ()
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) BPTableViewDiffableDataSource *dataSource API_AVAILABLE(ios(13.0));
@property (nonatomic, strong) BPOldTableViewDataSource *oldDataSource;
@property (nonatomic, strong) NSTimer *dataActionTimer;
@property (nonatomic, assign) BOOL enableNewTable;
@end

@implementation BPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"MyTypeTest1:%@", @(MyTypeTest1));
    NSLog(@"MyTypeTest2:%@", @(MyTypeTest2));
    NSLog(@"MyTypeTest3:%@", @(MyTypeTest3));
    
    NSUInteger value = MyTypeTest1 + MyTypeTest2;
    NSLog(@"value&MyTypeTest1:%@", @(value & MyTypeTest1));
    NSLog(@"value&MyTypeTest3:%@", @(value & MyTypeTest3));
    self.enableNewTable = NO;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    if (@available(iOS 13.0, *)) {
        if (self.enableNewTable) {
            [self initTestData];
            //指定新的代理
            self.tableView.dataSource = self.dataSource;
        } else {
            self.oldDataSource = [[BPOldTableViewDataSource alloc] initWithData:self.objects];
            self.tableView.dataSource = self.oldDataSource;
        }
        
    } else {
        self.oldDataSource = [[BPOldTableViewDataSource alloc] initWithData:self.objects];
        self.tableView.dataSource = self.oldDataSource;
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.dataActionTimer = [NSTimer scheduledTimerWithTimeInterval:1.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (@available(iOS 13.0, *)) {
            if (self.enableNewTable) {
                NSDiffableDataSourceSnapshot *snapshot = self.dataSource.snapshot;
                if (snapshot.numberOfSections == 0) {
                    [snapshot appendSectionsWithIdentifiers:@[@"zero"]];
                }
                BPDiffableModel *identifier = self.objects.firstObject;
                
                if (identifier) {
                    [snapshot appendItemsWithIdentifiers:@[identifier]];
                    
                    [self.objects removeObject:identifier];
                    
                    [self.dataSource applySnapshot:snapshot animatingDifferences:YES completion:^{
                        NSLog(@"%p added numberOfItems:%@", identifier, @(snapshot.numberOfItems));
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:snapshot.numberOfItems-1 inSection:0];
                        NSLog(@"idnexPath = %@", indexPath);
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }];
                }
            } else {
                [self doSomeThingOnLowVersion];
            }
        } else {
            [self doSomeThingOnLowVersion];
        }
        
    }];
    
}

- (void)doSomeThingOnLowVersion
{
    if (self.objects.count >= 30) {
        return;
    }
    BPDiffableModel *model = [[BPDiffableModel alloc] init];
    model.name = [NSString stringWithFormat:@"新数据：%@", @(self.objects.count)];
    model.age = self.objects.count;
    [self.objects addObject:model];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.objects.count-1 inSection:0];
    NSLog(@"idnexPath = %@", indexPath);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    BPDiffableModel *identifier = self.objects.firstObject;
//    if (identifier) {
//        [self.objects removeObject:identifier];
//        [self.tableView reloadData];
//    }
}


- (void)initTestData
{
    for (int i = 0; i < 30; ++i) {
        BPDiffableModel *model = [[BPDiffableModel alloc] init];
        model.name = [NSString stringWithFormat:@"新数据：%@", @(i)];
        model.age = i;
        [self.objects addObject:model];
    }
}
- (UITableViewDiffableDataSource *)dataSource  API_AVAILABLE(ios(13.0))
{
    if (!_dataSource) {
        _dataSource = [[BPTableViewDiffableDataSource alloc] initWithTableView:self.tableView cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id _Nonnull date) {
            //
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

            BPDiffableModel *model = date;
            cell.textLabel.text = [NSString stringWithFormat:@"名字:%@, 年龄:%@", model.name, @(model.age)];
            return cell;
//            NSDate *object = date;
//            cell.textLabel.text = [object description];
//            return cell;
            
        }];
    }
    return _dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
//    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
}

- (void)insertNewObject:(id)sender
{
    if (@available(iOS 13.0, *)) {
        NSDiffableDataSourceSnapshot *snapshot = self.dataSource.snapshot;
//        if (snapshot.numberOfItems >= 10) {
//            [snapshot deleteAllItems];
//            [self.datasource applySnapshot:snapshot animatingDifferences:YES completion:^{
//
//            }];
//            return;
//        }
        
        if (snapshot.numberOfSections == 0) {
            [snapshot appendSectionsWithIdentifiers:@[@"1"]];
        } else {
            if (snapshot.numberOfItems == 5) {
                [snapshot appendSectionsWithIdentifiers:@[@"2"]];
            }
        }
        
        [snapshot appendItemsWithIdentifiers:@[[NSDate date]]];
        
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES completion:^{
            
        }];
    } else {
        // Fallback on earlier versions
    }
}
    
- (NSMutableArray *)objects
{
    if (_objects == nil) {
        _objects = [NSMutableArray array];
    }
    return _objects;
}
@end
