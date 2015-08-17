//
//  VMRootItem.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/16/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import "VMRootItem.h"

@implementation VMRootItem

@dynamic lastUpdated;

+ (NSString *)entityName
{
    return @"VMRootItem";
}

+ (instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:moc];
}

@end
