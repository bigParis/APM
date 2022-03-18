//
//  BPWebViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/3/7.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPWebViewController.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WKNavigationDelegate.h>

@interface BPWebViewController ()<WKNavigationDelegate>
@property (nonatomic, weak) WKWebView *wkWebView;
@property (nonatomic, weak) UIButton *goToAnotherPage;
@end

@implementation BPWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebView *wkWebView = [[WKWebView alloc] init];
    wkWebView.navigationDelegate = self;
    [self.view addSubview:wkWebView];
    self.wkWebView = wkWebView;
    
    UIButton *goToAnotherPage = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:goToAnotherPage];
    self.goToAnotherPage = goToAnotherPage;
    goToAnotherPage.backgroundColor = [UIColor redColor];
    [goToAnotherPage addTarget:self action:@selector(onGoToAnotherPageClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.wkWebView.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height * 0.5);
    self.goToAnotherPage.frame = CGRectMake(100, CGRectGetMaxY(self.wkWebView.frame) + 50, 100, 30);
}

- (void)onGoToAnotherPageClicked:(UIButton *)sender
{
    [self.navigationController pushViewController:[BPWebViewController new] animated:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSString *URLString = @"https   ://www.baidu.com";
    NSURL *URL = [NSURL URLWithString:URLString];
    if (!URL) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    if (!request) {
        return;
    }
    [self.wkWebView loadRequest:request];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}
@end
