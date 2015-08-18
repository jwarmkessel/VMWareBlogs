//
//  Blog.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/17/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import "Blog.h"
#import "VMRootItem.h"


@implementation Blog

@dynamic author;
@dynamic community;
@dynamic descr;
@dynamic guid;
@dynamic internal;
@dynamic lastRead;
@dynamic link;
@dynamic objectSyncStatus;
@dynamic order;
@dynamic pubDate;
@dynamic title;
@dynamic vmRootItem;

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
