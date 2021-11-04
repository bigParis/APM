//
//  BPTemplateSub.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/28.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPTemplateSub.h"

@implementation BPTemplateSub
- (void)openTheDoor
{
//    [super openTheDoor];
    NSLog(@"sub open the door");
}

- (void)getInTheCar
{
//    [super getInTheCar];
    NSLog(@"sub getInTheCar");
}

- (void)driveTheCar
{
//    [super driveTheCar];
    NSLog(@"sub driveTheCar");
}

- (NSString *)getResult
{
    return @"car template finished";
}
@end
