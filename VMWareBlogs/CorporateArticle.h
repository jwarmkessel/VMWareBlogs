//
//  CorporateArticle.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 7/11/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CorporateArticle : NSManagedObject

@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, assign) NSNumber *order;
@property (nonatomic, assign) NSNumber *objectSyncStatus;
@property (nonatomic, assign) NSNumber *community;


@end
