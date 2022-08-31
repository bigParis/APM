//
//  BPCollectionRotateVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/7/28.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPCollectionRotateVC.h"
#import <Masonry.h>

@interface BPCollectionRotateVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UIView *testContainer;
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation BPCollectionRotateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *testContainer = [[UIView alloc] init];
    testContainer.backgroundColor = [UIColor redColor];
    [self.view addSubview:testContainer];
    self.testContainer = testContainer;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"BPCollectionRotateVCCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.testContainer addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self setDefaultLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientChange:)  name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)orientChange:(NSNotification *)note
{
//    [self setDefaultLayout];
    NSLog(@"testContainer:%@, collectionView:%@", self.testContainer, self.collectionView);
}

- (void)setDefaultLayout
{
    [self.testContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(100);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.testContainer).offset(10);
        make.right.equalTo(self.testContainer).offset(-10);
        make.top.equalTo(self.testContainer).offset(20);
        make.bottom.equalTo(self.testContainer).offset(-20);
    }];
}

//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    self.testContainer.frame = CGRectMake(15, 100, self.view.bounds.size.width - 30, self.view.bounds.size.height - 200);
//    self.collectionView.frame = CGRectMake(10, 20, self.testContainer.bounds.size.width - 20, self.testContainer.bounds.size.height - 40);
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BPCollectionRotateVCCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(30, 40);
}
@end
