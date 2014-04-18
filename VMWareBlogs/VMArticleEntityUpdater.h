//
//  VMArticleEntityUpdater.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/17/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMArticleEntityUpdater : NSObject
@property (atomic, strong) NSManagedObjectContext *updateContext;
@property (nonatomic, assign) BOOL updateFlag;
@property (nonatomic, strong) NSTimer *updateBlogListTimer;

- (void)updateList;

@end
