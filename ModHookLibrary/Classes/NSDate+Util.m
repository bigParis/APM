//
//  NSDate+Util.m
//  YYMobile
//
//  Created by 马英伦 on 16/8/3.
//  Copyright © 2016年 YY.inc. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

- (BOOL)yy_isToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    // 1. 获得当前时间的年月日

    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];

    // 2. 获得 self 的年月日

    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];

    return

        (selfCmps.year == nowCmps.year) && //直接分别用当前对象和现在的时间进行比较，比较的属性就是年月日

        (selfCmps.month == nowCmps.month) &&

        (selfCmps.day == nowCmps.day);
}
@end
