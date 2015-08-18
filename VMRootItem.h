//
//  VMRootItem.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/17/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Blog;

@interface VMRootItem : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSSet *blog;
@end

@interface VMRootItem (CoreDataGeneratedAccessors)

- (void)addBlogObject:(Blog *)value;
- (void)removeBlogObject:(Blog *)value;
- (void)addBlog:(NSSet *)values;
- (void)removeBlog:(NSSet *)values;

+ (NSString *)entityName;
+ (instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
