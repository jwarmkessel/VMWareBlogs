//
//  VMSynchronousFeedUpdater.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 6/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMSynchronousFeedUpdater : NSObject
@property (atomic, strong) NSManagedObjectContext *updateContext;
@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, strong) NSTimer *updateBlogListTimer;
@property (nonatomic, assign) id delegate;

- (void)updateList;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end

