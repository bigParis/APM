//
//  BPBaseView.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/4.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPBaseView : UIView

@property (nonatomic, weak) UIView *redView;
@property (nonatomic, weak) UIView *blueView;
@property (nonatomic, assign) BOOL redViewDisable;
@property (nonatomic, assign) BOOL blueViewDisable;

- (void)initConfig;
- (void)setupViews;
- (void)setupLayout;

@end

NS_ASSUME_NONNULL_END
