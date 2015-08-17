//
//  VMRootItem.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/16/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface VMRootItem : NSManagedObject

@property (nonatomic, retain) NSDate *lastUpdated;

+ (NSString *)entityName;
+ (instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
