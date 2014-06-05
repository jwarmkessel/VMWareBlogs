//
//  RecentArticle.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/29/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecentArticle : NSManagedObject

@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * pubDate;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * title;

@end
