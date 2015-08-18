//
//  VMSynchronousFeedUpdater.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 6/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMSynchronousFeedUpdater : NSObject

@property (nonatomic, strong)               NSManagedObjectContext* updateContext;
@property (nonatomic, getter = isUpdating)  BOOL                    updating;
@property (nonatomic, strong)               NSTimer*                updateBlogListTimer;
@property (nonatomic, assign)               id                      delegate;
@property (nonatomic, strong)               NSMutableSet*           blogSet;
@property (nonatomic, assign)               BOOL                    internal;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext internal:(BOOL)internal;
- (BOOL)updateList;

@end

@protocol VMSynchronousFeedUpdaterDelegate

@optional
- (void)articleEntityUpdaterDidFinishUpdating;

- (void)articleEntityUpdaterDidInsertArticle:(id)entityId;

- (void)articleEntityDidDeleteArticle:(id)entityId;

- (void)articleEntityWillUpdate:(id)deleteId andInsert:(id)insertId;

- (void)articleEntityUpdaterDidError;
@end
