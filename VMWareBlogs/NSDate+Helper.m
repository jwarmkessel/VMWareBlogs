//
//  NSDate+Helper.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/17/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

- (NSDate *)beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:self];
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [NSDateComponents new];
    components.day = 1;
    
    NSDate *date = [calendar dateByAddingComponents:components
                                             toDate:self.beginningOfDay
                                            options:0];
    
    date = [date dateByAddingTimeInterval:-1];
    
    return date;
}

- (NSDate *)dateByAddingDays:(NSInteger)inDays
{
    static NSCalendar *cal;
    static dispatch_once_t once;
    dispatch_once(&once, ^
                  {
                      cal = [NSCalendar currentCalendar];
                  });
    
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self];
    [components setDay:[components day] + inDays];
    return [cal dateFromComponents:components];
}

@end
