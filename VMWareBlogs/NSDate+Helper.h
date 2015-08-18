//
//  NSDate+Helper.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/17/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSDate *)beginningOfDay;
- (NSDate *)endOfDay;
- (NSDate *)dateByAddingDays:(NSInteger)inDays;

@end
