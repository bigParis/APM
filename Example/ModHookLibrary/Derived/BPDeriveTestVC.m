//
//  BPDeriveTestVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/4.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPDeriveTestVC.h"
#import "BPSubView1.h"
#import "BPSubView2.h"

#import <sys/kdebug_signpost.h>

@interface BPDeriveTestVC ()
@property (nonatomic, weak) BPSubView1 *testView1;
@property (nonatomic, weak) BPSubView2 *testView2;
@property (nonatomic, weak) BPBaseView *baseView;
@end

@implementation BPDeriveTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    kdebug_signpost_start(20,0,0,0,3);
    [self initViews];
    kdebug_signpost_end(20,0,0,0,3);
}

- (void)initViews
{
    BPSubView1 *testView1 = [[BPSubView1 alloc] initWithFrame:self.view.frame isGuide:NO];
//    BPSubView1 *testView1 = [[BPSubView1 alloc] init];
    [self.view addSubview:testView1];
    self.testView1 = testView1;
    
    BPSubView2 *testView2 = [[BPSubView2 alloc] init];
    [self.view addSubview:testView2];
    self.testView2 = testView2;
    
    BPBaseView *baseView = [[BPBaseView alloc] init];
    [self.view addSubview:baseView];
    self.baseView = baseView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat height = self.view.bounds.size.height * 0.3;
    self.testView1.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
    self.testView2.frame = CGRectMake(0, height, self.view.bounds.size.width, height);
    self.baseView.frame = CGRectMake(0, height*2, self.view.bounds.size.width, height);
}
@end
