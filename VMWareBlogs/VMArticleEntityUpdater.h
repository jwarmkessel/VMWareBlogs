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
@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, strong) NSTimer *updateBlogListTimer;
@property (nonatomic, assign) id delegate;

- (void)updateList;
@end

@protocol VMArticleEntityUpdaterDelegate

@optional
- (void)articleEntityUpdaterDidFinishUpdating;

- (void)articleEntityUpdaterDidInsertArticle:(id)entityId;

- (void)articleEntityDidDeleteArticle:(id)entityId;

- (void)articleEntityWillUpdate:(id)deleteId andInsert:(id)insertId;

- (void)articleEntityUpdaterDidError;
@end
