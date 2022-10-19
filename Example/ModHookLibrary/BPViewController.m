//
//  BPViewController.m
//  ModHookLibrary
//
//  Created by wangfei5 on 09/24/2021.
//  Copyright (c) 2021 wangfei5. All rights reserved.
//

#import "BPViewController.h"
#import "BPTableViewCell.h"

static NSString *kTableViewCellIdentifier = @"TableViewCellIdentifier";

@interface BPTableModel : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *jumpViewController;
@end

@implementation BPTableModel

@end

@interface BPViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSArray<BPTableModel *> *dataSource;

@end

@implementation BPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"天生我才";
//    self.view.backgroundColor = [UIColor whiteColor];
//    [self initSubViews];
//    [self initData];
}

- (void)initSubViews
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)initData
{
    NSMutableArray *tempArray = [@[] mutableCopy];
    [tempArray addObject:[self createModelWith:@"任务管理" vcName:@"BPTaskTestViewController"]];
    [tempArray addObject:[self createModelWith:@"AMP测试" vcName:@"BPAPMTestViewController"]];
    [tempArray addObject:[self createModelWith:@"Pod库测试" vcName:@"BPPodLibraryTestViewController"]];
    [tempArray addObject:[self createModelWith:@"动画&特效" vcName:@"BPAnimationVC"]];
    [tempArray addObject:[self createModelWith:@"NSPointerArray" vcName:@"BPPointerArrayVC"]];
    [tempArray addObject:[self createModelWith:@"PrivateModel" vcName:@"BPPrivateModelVC"]];
    [tempArray addObject:[self createModelWith:@"Net" vcName:@"BPNetworkTestVC"]];
    [tempArray addObject:[self createModelWith:@"多线程" vcName:@"BPMultiThreadVC"]];
    [tempArray addObject:[self createModelWith:@"模板" vcName:@"BPTemplateVC"]];
    [tempArray addObject:[self createModelWith:@"继承" vcName:@"BPDeriveTestVC"]];
    [tempArray addObject:[self createModelWith:@"内存" vcName:@"BPMemoryTestVC"]];
    [tempArray addObject:[self createModelWith:@"YYModel" vcName:@"BPYYModelTestVC"]];
    [tempArray addObject:[self createModelWith:@"SVGA" vcName:@"BPSVGAViewController"]];
    [tempArray addObject:[self createModelWith:@"Block" vcName:@"BPBlockViewController"]];
    [tempArray addObject:[self createModelWith:@"Mach-O" vcName:@"BPMachOViewController"]];
    [tempArray addObject:[self createModelWith:@"列表" vcName:@"BPListViewController"]];
    [tempArray addObject:[self createModelWith:@"运行时" vcName:@"BPRuntimeViewController"]];
    [tempArray addObject:[self createModelWith:@"WebView" vcName:@"BPWebViewController"]];
    [tempArray addObject:[self createModelWith:@"TaggedPointer" vcName:@"BPTaggedPointerViewController"]];
    [tempArray addObject:[self createModelWith:@"CollectionView旋转" vcName:@"BPCollectionRotateVC"]];
    [tempArray addObject:[self createModelWith:@"wake up" vcName:@"BPWakeupVC"]];
    self.dataSource = tempArray;
}

- (BPTableModel *)createModelWith:(NSString *)content vcName:(NSString *)vcName
{
    BPTableModel *tm = [[BPTableModel alloc] init];
    tm.content = content;
    tm.jumpViewController = vcName;
    return tm;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[BPTableViewCell alloc] init];
    }
    
    if (indexPath.row < self.dataSource.count) {
        cell.desc = self.dataSource[indexPath.row].content;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dataSource.count) {
        NSString *jumpVC = self.dataSource[indexPath.row].jumpViewController;
        Class cls = NSClassFromString(jumpVC);
        UIViewController *target = [[cls alloc] init];
        [self.navigationController pushViewController:target animated:YES];
    }
}
@end
