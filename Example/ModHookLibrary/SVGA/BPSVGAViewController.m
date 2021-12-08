//
//  BPSVGAViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/8.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPSVGAViewController.h"
#import <SVGAPlayer/SVGA.h>
@interface BPSVGAViewController ()
@property (nonatomic, strong) SVGAPlayer *player;
@end

@implementation BPSVGAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SVGAPlayer *player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(200, 300, 30, 30)];
    self.player = player;
    [self.view addSubview:player]; // Add subview by yourself.
    
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"index_anchor_info_live_animation" ofType:@"svga"];
    
    if (!resPath || resPath.length <= 0) {
        return;
    }

    NSData *data = [[NSData alloc] initWithContentsOfFile:resPath];
    SVGAParser *parser = [[SVGAParser alloc] init];
    __weak SVGAPlayer *aPlayer = self.player;
    [parser parseWithData:data cacheKey:@"index_anchor_info_live_animation" completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
        if (videoItem) {
            [aPlayer setVideoItem:videoItem];
            [aPlayer startAnimation];
        }
        } failureBlock:^(NSError * _Nonnull error) {
            NSLog(@"error:%@", error);
    }];

}

@end
